#!/bin/bash
echo Starting Hydra.............
source /vagrant/vagrant-deploy-common/scripts/createExecUser.sh

HYDRA_NODE_NAME=$1
HYDRA_PEERS=$2

# Copy init scripts
sudo cp /vagrant/vagrant-deploy-common/scripts/forever.sh /usr/bin/forever.sh && sudo chmod a+x /usr/bin/forever.sh
sudo cp /vagrant/scripts/startup/hydra /etc/init.d && sudo chmod a+x /etc/init.d/hydra

# Change permissions and go to deploy directory
sudo chmod 777 /opt
cd /opt

# Clone Hydra repositories and build
export GIT_SSH=/vagrant/vagrant-deploy-common/scripts/git_ssh.sh
sudo chmod a+x $GIT_SSH
if [ ! -d /opt/hydra ]
then
    echo ssh cloning hydra.git...
	cd /opt && git clone -b 3.0.0 git@github.com:innotech/hydra.git && cd /opt/hydra && ./build2
fi

# Make configuration files
echo Copy and set config files
sudo chmod 777 /opt
sudo cp /vagrant/scripts/config/hydra.conf /etc/hydra/hydra.conf
sed -i "s/#{name}/${HYDRA_NODE_NAME}/g" /etc/hydra/hydra.conf
sed -i "s/#{peers}/${HYDRA_PEERS}/g" /etc/hydra/hydra.conf

# Create Hydra user
echo "Creating user"
createExecUser hydra /opt/hydra
echo "Ending user"

sudo chkconfig hydra on

sudo /etc/init.d/hydra restart

echo Ending Hydraserver.............