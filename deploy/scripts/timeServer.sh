#!/bin/bash
echo Starting time server.............
source /vagrant/vagrant-deploy-common/scripts/createExecUser.sh


# Copy init scripts
sudo cp /vagrant/vagrant-deploy-common/scripts/forever.sh /usr/bin/forever.sh && sudo chmod a+x /usr/bin/forever.sh
sudo cp /vagrant/scripts/startup/time /etc/init.d && sudo chmod a+x /etc/init.d/time


# Change permissions and go to deploy directory
sudo chmod 777 /opt
cd /opt

# Clone Hydra repositories and checkout a specific tag
export GIT_SSH=/vagrant/vagrant-deploy-common/scripts/git_ssh.sh
sudo chmod a+x $GIT_SSH
if [ ! -d /opt/hydra-demo ]
then
    echo ssh cloning hydra_server.git...
	cd /opt && git clone -b etcd git@github.com:innotech/hydra-demo.git && cd /opt/hydra-demo
	# && git checkout tags/latest
	cd /opt/hydra-demo/time && npm install
fi

# Create Hydra user
echo "Creating user"
createExecUser time /opt/hydra-demo/time
echo "Ending user"

sudo chkconfig time on

sudo /etc/init.d/time restart

echo Ending time server.............