#!/bin/bash
echo Starting time server.............
source /vagrant/vagrant-deploy-common/scripts/createExecUser.sh


# Copy init scripts
sudo cp /vagrant/vagrant-deploy-common/scripts/forever.sh /usr/bin/forever.sh && sudo chmod a+x /usr/bin/forever.sh
sudo cp /vagrant/scripts/startup/time /etc/init.d && sudo chmod a+x /etc/init.d/time
sudo cp /vagrant/scripts/startup/stress /etc/init.d && sudo chmod a+x /etc/init.d/stress


# Change permissions and go to deploy directory
sudo chmod 777 /opt
cd /opt

# Clone hydra-demo repository
export GIT_SSH=/vagrant/vagrant-deploy-common/scripts/git_ssh.sh
sudo chmod a+x $GIT_SSH
rm -rf /opt/hydra-demo
echo ssh cloning hydra-demo.git...
cd /opt && git clone -b hydra-go git@github.com:innotech/hydra-demo.git && cd /opt/hydra-demo
# && git checkout tags/latest
cd /opt/hydra-demo/time/hydra-node && npm install
cd /opt/hydra-demo/time && npm install

# Create time user
echo "Creating user"
createExecUser time /opt/hydra-demo/time
echo "Ending user"

sudo chkconfig time on
sudo chkconfig stress on

sudo /etc/init.d/time restart
sudo /etc/init.d/stress restart

echo Ending time server.............