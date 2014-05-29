#!/bin/bash

# Copy init scripts
sudo cp /tmp/scripts/startup/time /etc/init.d && sudo chmod a+x /etc/init.d/time
sudo cp /tmp/scripts/startup/stress /etc/init.d && sudo chmod a+x /etc/init.d/stress

# Change permissions and go to deploy directory
sudo chmod 777 /opt
cd /opt

# Clone Hydra repositories and checkout a specific tag
export GIT_SSH=/tmp/common/git_ssh.sh
sudo chmod a+x $GIT_SSH
rm -rf /opt/hydra-demo
echo ssh cloning hydra-demo.git...
cd /opt && git clone -b etcd git@github.com:innotech/hydra-demo.git && cd /opt/hydra-demo
# && git checkout tags/latest
cd /opt/hydra-demo/time/hydra-node && npm install
cd /opt/hydra-demo/time && npm install

sudo chkconfig time on
sudo chkconfig stress on

sudo /etc/init.d/time restart
sudo /etc/init.d/stress restart
