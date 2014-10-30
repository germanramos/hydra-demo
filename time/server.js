var http = require('http');

if (process.argv.length != 7) {
	console.log("Usage: node " + process.argv[1] + " listen_host port minDelay_ms maxDelay_ms varianceDelay_ms");
	console.log("Example: node " + process.argv[1] + " 0.0.0.0 1337 2000 4000 2000");
	process.exit();
}

var host = process.argv[2]; //'0.0.0.0'
var port = parseInt(process.argv[3],10); //1337
var minDelay = parseInt(process.argv[4],10); //2000
var maxDelay = parseInt(process.argv[5],10); //4000
var varDelay = parseInt(process.argv[6],10); //2000
var delay

function updateDelay() {
	delay = minDelay + Math.random() * maxDelay;
	console.log("Delay center changed to " + delay);
	setTimeout(updateDelay, 10000);
};

updateDelay()

http.createServer(function(req, res) {
	res.writeHead(200, {
		'Content-Type' : 'text/plain',
		'Access-Control-Allow-Origin': '*'
	});
	currentDelay = delay + Math.random() * varDelay;
	console.log("Sleeping " + currentDelay);
	setTimeout(function() {
		var now = new Date();
		res.end(now.getUTCHours() + ':' + now.getUTCMinutes() + ':' + now.getUTCSeconds() + '\n');
		req.connection.end();
	}, currentDelay);
}).listen(port, host);
console.log('Server running at http://' + host + ':' + port);
