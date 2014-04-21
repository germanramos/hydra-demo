#!/bin/bash
echo Starting Hydraserver.............
source /vagrant/vagrant-deploy-common/scripts/createExecUser.sh

INSTANCE_NAME=$1
ETCD_PEERS=$2

# Copy init scripts
sudo cp /vagrant/vagrant-deploy-common/scripts/forever.sh /usr/bin/forever.sh && sudo chmod a+x /usr/bin/forever.sh
sudo cp /vagrant/scripts/startup/hydra_server_api /etc/init.d && sudo chmod a+x /etc/init.d/hydra_server_api
sudo cp /vagrant/scripts/startup/hydra_client_api /etc/init.d && sudo chmod a+x /etc/init.d/hydra_client_api
sudo cp /vagrant/scripts/startup/etcd /etc/init.d && sudo chmod a+x /etc/init.d/etcd

# Hacer backups de la config????

# Change permissions and go to deploy directory
sudo chmod 777 /opt
cd /opt

# Download and extract etcd
if [ ! -d ./etcd ]
then
	#wget https://github.com/coreos/etcd/releases/download/v0.2.0/etcd-v0.2.0-Linux-x86_64.tar.gz && tar -zxf etcd-v0.2.0-Linux-x86_64.tar.gz && mv etcd-v0.2.0-Linux-x86_64 etcd
	wget https://github.com/coreos/etcd/releases/download/v0.3.0/etcd-v0.3.0-linux-amd64.tar.gz && tar -zxf etcd-v0.3.0-linux-amd64.tar.gz && mv etcd-v0.3.0-linux-amd64 etcd
	
fi

# Clone Hydra repositories and checkout a specific tag
export GIT_SSH=/vagrant/vagrant-deploy-common/scripts/git_ssh.sh
sudo chmod a+x $GIT_SSH
if [ ! -d /opt/hydra_server ]
then
    echo ssh cloning hydra_server.git...
	cd /opt && git clone -b etcd git@github.com:innotech/hydra_server.git && cd /opt/hydra_server && git checkout tags/latest
	cd /opt/hydra_server/src/lib && npm install
fi

echo Copy and set config files
sudo chmod 777 /opt
sudo cp /vagrant/scripts/config/hydra_server_config.json /opt/hydra_server/src/lib/config/pro.json
sed -i "s/#{public_ip}/${INSTANCE_NAME}/g" /opt/hydra_server/src/lib/config/pro.json
sudo mkdir /etc/etcd
sudo cp /vagrant/scripts/config/etcd.conf /etc/etcd/etcd.conf

sed -i "s/#{public_ip}/${INSTANCE_NAME}/g" /etc/etcd/etcd.conf
sed -i "s/#{name}/${INSTANCE_NAME}/g" /etc/etcd/etcd.conf
sed -i "s/#{peers}/${ETCD_PEERS}/g" /etc/etcd/etcd.conf

# Create Hydra user
echo "Creating user"
createExecUser hydra /opt/hydra_server /opt/etcd
echo "Ending user"

# Auto restart hydra_client_api (it rewrite log file)
alreadyDone=$(crontab -l | grep hydra_client_api |  wc -l)
if [[ "$alreadyDone" < 1 ]]; then
	line="0 4 * * *  /etc/init.d/hydra_client_api restart"
    (crontab -l; echo "$line" ) | crontab -
	echo "[CRONTAB]: Crontab updated"
else
	echo "[CRONTAB]: Crontab already updated"
fi

# Start up scripts
sudo chkconfig hydra_server_api on
sudo chkconfig hydra_client_api on
sudo chkconfig etcd on

sudo /etc/init.d/etcd restart
sudo /etc/init.d/hydra_server_api restart
sudo /etc/init.d/hydra_client_api restart

echo Ending Hydraserver.............