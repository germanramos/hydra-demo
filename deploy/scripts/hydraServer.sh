#!/bin/bash

INSTANCE_NAME=$1
MASTER=$2

cd /tmp
rm ./libzmq3-3.2.2-13.1.x86_64.rpm ./hydra-core-3-1.x86_64.rpm ./hydra-worker-round-robin-1-1.x86_64.rpm ./hydra-worker-map-by-limit-1-1.x86_64.rpm ./hydra-worker-sort-by-number-1-1.x86_64.rpm ./hydra-worker-map-sort-1-1.x86_64.rpm
wget https://github.com/innotech/hydra/releases/download/3.0.0_alpha/libzmq3-3.2.2-13.1.x86_64.rpm
wget https://github.com/innotech/hydra/releases/download/3.1.3/hydra-core-3-1.x86_64.rpm
wget https://github.com/innotech/hydra-worker-round-robin/releases/download/v1.1.0/hydra-worker-round-robin-1-1.x86_64.rpm
wget https://github.com/innotech/hydra-worker-map-by-limit/releases/download/1.1.1/hydra-worker-map-by-limit-1-1.x86_64.rpm
wget https://github.com/innotech/hydra-worker-sort-by-number/releases/download/v1.1.0/hydra-worker-sort-by-number-1-1.x86_64.rpm
wget https://github.com/innotech/hydra-worker-map-sort/releases/download/1.1.1/hydra-worker-map-sort-1-1.x86_64.rpm
sudo yum remove -y hydra-core hydra-worker-round-robin hydra-worker-map-by-limit hydra-worker-sort-by-number hydra-worker-map-sort 
sudo yum install -y ./libzmq3-3.2.2-13.1.x86_64.rpm ./hydra-core-3-1.x86_64.rpm ./hydra-worker-round-robin-1-1.x86_64.rpm ./hydra-worker-map-by-limit-1-1.x86_64.rpm ./hydra-worker-sort-by-number-1-1.x86_64.rpm ./hydra-worker-map-sort-1-1.x86_64.rpm
cp /tmp/scripts/config/hydra.conf /etc/hydra/

sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra/hydra.conf
if [ $INSTANCE_NAME == $MASTER ]
then # Is master
	cp /tmp/scripts/config/apps.json /etc/hydra/
	sed -i 's/"#{MASTER}:7701"//g' /etc/hydra/hydra.conf
else # Is slave
	sed -i "s/#{MASTER}/${MASTER}/g" /etc/hydra/hydra.conf
fi

sudo rm -rf /usr/local/hydra/snapshot /usr/local/hydra/log /usr/local/hydra/conf 

# Hydra workers
cp /tmp/scripts/config/hydra-worker-map-sort.conf /etc/hydra/
sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra/hydra-worker-map-sort.conf
cp /tmp/scripts/config/hydra-worker-map-by-limit.conf /etc/hydra/
sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra/hydra-worker-map-by-limit.conf
cp /tmp/scripts/config/hydra-worker-round-robin.conf /etc/hydra/
sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra/hydra-worker-round-robin.conf
cp /tmp/scripts/config/hydra-worker-sort-by-number.conf /etc/hydra/
sed -i "s/#{INSTANCE_NAME}/${INSTANCE_NAME}/g" /etc/hydra/hydra-worker-sort-by-number.conf

# Start up scripts
for i in hydra-core hydra-worker-map-by-limit hydra-worker-map-sort hydra-worker-round-robin hydra-worker-sort-by-number
do  
	sudo chkconfig $i on
	sudo /etc/init.d/$i restart
done

