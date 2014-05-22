#!/bin/bash

INSTANCE_NAME=$1
MASTER=$2

cd /tmp
rm *.rpm
wget https://github.com/innotech/hydra/releases/download/3.0.0_alpha/libzmq3-3.2.2-13.1.x86_64.rpm
wget https://github.com/innotech/hydra/releases/download/3.0.0_alpha/hydra-3-0.x86_64.rpm
wget https://github.com/innotech/hydra-worker-round-robin/releases/download/v1.0.0/hydra-worker-round-robin-1-0.x86_64.rpm
wget https://github.com/innotech/hydra-worker-map-by-limit/releases/download/v1.0.0/hydra-worker-map-by-limit-1-0.x86_64.rpm
wget https://github.com/innotech/hydra-worker-sort-by-number/releases/download/v1.0.0/hydra-worker-sort-by-number-1-0.x86_64.rpm
wget https://github.com/innotech/hydra-worker-map-sort/releases/download/v1.0.0/hydra-worker-map-sort-1-0.x86_64.rpm
wget https://github.com/innotech/hydra-basic-probe/releases/download/v2.0.1/python-psutil-0.6.1-1.el6.x86_64.rpm
wget https://github.com/innotech/hydra-basic-probe/releases/download/v2.0.1/hydra-basic-probe-2-0.noarch.rpm

sudo yum install -y libzmq3-3.2.2-13.1.x86_64.rpm hydra-3-0.x86_64.rpm hydra-worker-round-robin-1-0.x86_64.rpm hydra-worker-map-by-limit-1-0.x86_64.rpm hydra-worker-sort-by-number-1-0.x86_64.rpm hydra-worker-map-sort-1-0.x86_64.rpm python-psutil-0.6.1-1.el6.x86_64.rpm hydra-basic-probe-2-0.noarch.rpm
cp /tmp/scripts/config/hydra.conf /etc/hydra/
cp /tmp/scripts/config/hydra-basic-probe.cfg /etc/hydra-basic-probe/

sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra/hydra.conf
sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra-basic-probe/hydra-basic-probe.cfg
if [ $INSTANCE_NAME == $MASTER ]
then # Is master
	cp /tmp/scripts/config/apps.json /etc/hydra/
	sed -i 's/"#{MASTER}:7701"//g' /etc/hydra/hydra.conf
else # Is slave
	sed -i "s/#{MASTER}/${MASTER}/g" /etc/hydra/hydra.conf
fi

sudo rm -rf /usr/local/hydra/snapshot /usr/local/hydra/log /usr/local/hydra/conf 

# Start up scripts
for i in hydra hydra-worker-map-by-limit hydra-worker-map-sort hydra-worker-round-robin hydra-worker-sort-by-number hydra-basic-probe
do  
	sudo chkconfig $i on
	sudo /etc/init.d/$i restart
done

