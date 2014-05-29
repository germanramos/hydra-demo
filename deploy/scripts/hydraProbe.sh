#!/bin/bash

INSTANCE_NAME=$1
ID=$2
URI=$3
PORT=$4
COST=$5
CLOUD=$6
HYDRA=$7

cd /tmp
rm python-psutil-0.6.1-1.el6.x86_64.rpm hydra-basic-probe-2-0.noarch.rpm
wget https://github.com/innotech/hydra-basic-probe/releases/download/v2.0.1/python-psutil-0.6.1-1.el6.x86_64.rpm
wget https://github.com/innotech/hydra-basic-probe/releases/download/v2.0.1/hydra-basic-probe-2-0.noarch.rpm

sudo yum install -y python-psutil-0.6.1-1.el6.x86_64.rpm hydra-basic-probe-2-0.noarch.rpm
cp /tmp/scripts/config/hydra-basic-probe.cfg /etc/hydra-basic-probe/

sed -i "s%#{INSTANCE_NAME}%${INSTANCE_NAME}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
sed -i "s%#{ID}%${ID}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
sed -i "s%#{URI}%${URI}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
sed -i "s%#{PORT}%${PORT}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
sed -i "s%#{COST}%${COST}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
sed -i "s%#{COST}%${CLOUD}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
sed -i "s%#{HYDRA}%${HYDRA}%g" /etc/hydra-basic-probe/hydra-basic-probe.cfg

# Start up scripts
sudo chkconfig hydra-basic-probe on
sudo /etc/init.d/hydra-basic-probe restart
