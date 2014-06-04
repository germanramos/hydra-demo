var hydra = require('./hydra-node'),
	http = require('http'),
	request = require('request'),
	express = require('express'),
	app = express();

http.globalAgent.maxSockets = 100000;
//http.globalAgent = false;

var port = parseInt(process.argv[2],10) || 5000;

var service = "time",
	hydraRefreshWait = 1000,
	errorWait = 2000,
	ajaxTimeout = 4000,
	randomWait = 5000,
	blacklistTime = 5000,
	servers = [],
	blacklist = [],
	stop = true,
	conns = 0;

app.configure(function() {
	app.use( express.static(__dirname + '/www') );
	app.use(express.bodyParser());
	app.use(express.methodOverride());
	app.use(app.router);
	app.use(express.errorHandler({
		dumpExceptions : true,
		showStack : true
	}));
});

app.get('/start/:connections', function(req, res){
	var hydraServers = req.query.hydras.split(',');
	service = req.query.app || 'time';
	console.log("Start order: " + req.params.connections + " connections");
	startRequests((parseInt(req.params.connections,10) || 1), hydraServers);
	res.send(200, {host: req.headers.host, app: service, connections: conns, started: !stop});
});

app.get('/info', function(req, res){
	res.send(200, {host: req.headers.host, app: service, connections: conns, started: !stop});
    console.log("Info order");
});

app.get('/stop', function(req, res){
	stop = true;
	console.log('Stopping connections');
	res.send(200, {host: req.headers.host, app: service, connections: conns, started: !stop});
});

app.listen(port);
console.log('Stress-time listening on port', port);

function startRequests(connections, hydraServers) {
	console.log('Starting', connections, 'connections for', service, 'on', hydraServers);
	stop = false;
	console.log("HYDRASERVERS", hydraServers);
	hydra.config(hydraServers);
	updateServers();

	for ( var i = 0; i < connections; i++) {
		setTimeout(makeRequest, Math.floor(Math.random()*randomWait));
	}
	
}

function blacklistAdd(url) {
	for (var i=0; i<blacklist.length; i++) {
		if (blacklist[i].url == url) {
			blacklist[i].timestamp = Date.now();
			return;
		}
	}
	console.log("Adding " + url + " to blacklist");
	blacklist.push({ url: url, timestamp : Date.now()});
}

function updateServers() {
	//Get servers from hydra
	hydra.get(service, true, function(err, result) {
		if (result !== null){
			//Clean blacklist and filter servers
			var newblacklist = [];
			var now = Date.now();
			for (var i=0; i<blacklist.length; i++) {
				if (now - blacklist[i].timestamp < blacklistTime) {
					newblacklist.push(blacklist[i]);
				} else {
					console.log("Removing " + blacklist[i].url + " from blacklist");
					continue;
				}
				var index = result.indexOf(blacklist[i].url);
				if (index >= 0) {
					console.log("Removing " + blacklist[i].url + " from updated server list");
					result.splice(index, 1);
				}
			}
			blacklist = newblacklist;
			servers = result;
		}
	});

	if(!stop) setTimeout(updateServers, hydraRefreshWait);
}

function postToTopic(method, errorCode, duration) {
	data = {
		"appName": "time",
		"method": "getTime",
		"status": errorCode,
		"responseTime" : duration.toString()
	};
	console.log("Posting to topic:", data);	
	request.post({
		headers: {'content-type' : 'application/json'},
		url:     'https://listener3.topicthunder.io',
		body:    JSON.stringify(data)
	}, function(error, response, body){
	  console.log(body);
	});
}

function makeRequest() {
	//console.log("Making request")
	if (servers === null || servers.length < 1) {
		console.log("Servers null");
		if(!stop) setTimeout(makeRequest, errorWait);
		return;
	}

	var url = servers[0];
	var options = {
		url : url,
		timeout : 6000,
		//agent: false
	};
	conns++;
	var start = Date.now();
	request(options, function(error, response, body) {
		conns--;
		var duration = Date.now() - start;
		postToTopic("time", response && response.statusCode && response.statusCode == 200 ? "6" : "3", duration);
		var customWait = 0;
		if (response && response.statusCode && response.statusCode == 200) {
			customWait = randomWait;
		} else {
			//blacklistAdd(url);
		}

		if(!stop) setTimeout(makeRequest, Math.floor(Math.random()*customWait));
	});
}
