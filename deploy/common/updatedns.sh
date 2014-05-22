#!/bin/bash

#chkconfig: 345 99 03

### BEGIN INIT INFO
# Provides:          custom resolv.conf
# Required-Start:
# Required-Stop:
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description: update dns entry and edit resolv.conf
# Description:
### END INIT INFO</pre>

file="updatedns.sh"

IPADDRS=$(ifconfig eth0 | grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed -n 1p)
HOSTNAME=$(hostname)
HOSTNAME2=$1
CLOUDID=$(echo $IPADDRS|cut -d"." -f2)
KEY="1Dqihcarq80o+QCshf3tvw=="

# 0. Configuracion de los DNSs

DNSLAB="192.168.10.224"
DNSGCE="10.111.254.49"
DNSAWS="10.110.26.11"
DNSAWSSAO="10.113.193.171"
DNSAWSIRE="10.112.70.219"
DOMAIN="innotech.lib"

# 1. Conocer el cloud para posterior conf

if [ "$CLOUDID" -eq "0" ] # Solo para el lab, que tiene eth0 y eth1
then
	IPADDRS=""
	IPADDRS=$(ifconfig eth1 | grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed -n 1p)
	echo $IPADDRS
fi

# 1.1 Ordemanos los servidores DNS

case "$CLOUDID" in
"0")  DNS_LIST=($DNSLAB $DNSGCE $DNSAWS $DNSAWSSAO $DNSAWSIRE)
    ;;
"110") DNS_LIST=($DNSAWS $DNSAWSSAO $DNSGCE $DNSLAB $DNSAWSIRE)
    ;;
"111") DNS_LIST=($DNSGCE $DNSLAB $DNSAWS $DNSAWSSAO $DNSAWSIRE)
    ;;
"112") DNS_LIST=($DNSAWSIRE $DNSLAB $DNSAWSSAO $DNSAWS $DNSGCE)
   ;;
"113") DNS_LIST=($DNSAWSSAO $DNSAWS $DNSGCE $DNSLAB $DNSAWSIRE)
   ;;
esac

# 2. Actualizamos el fichero /etc/hosts si no esta actualizado ya
# echo "Paso 2"

cd /tmp/common

cat /etc/hosts | grep -v dns | sort -k2,2 -r -u > /tmp/hosts
mv /tmp/hosts /etc/hosts
echo "$DNSAWS		dns0.$DOMAIN" >> /etc/hosts
echo "$DNSGCE		dns1.$DOMAIN" >> /etc/hosts
echo "$DNSLAB        dns2.$DOMAIN" >> /etc/hosts
echo "$DNSAWSSAO	dns3.$DOMAIN" >> /etc/hosts
#echo "$DNSVINU	dns4.$DOMAIN" >> /etc/hosts
echo "$DNSAWSIRE      dns5.$DOMAIN" >> /etc/hosts

# 3. Instalamos BIND9 si no esta instalado ya
if [ -n "$(command -v yum)" ]
then
	yum -y install bind bind-libs bind-utils
else
        if ! [[ $(dpkg-query -l 'dnsutils') ]]; then
		apt-get update
		apt-get -y install dnsutils
	fi
fi;

# 4. Actualizamos la instancia para que resuelva con el servidor DNS interno modificando el /etc/resolv.conf

echo "search	$DOMAIN" > /etc/resolv.conf
for item in ${DNS_LIST[*]}
do
    echo "nameserver	$item" >> /etc/resolv.conf
done
echo "nameserver	8.8.8.8" >> /etc/resolv.conf


if [ ! -f /etc/init.d/${file} ]; then
        sudo cp /tmp/common/${file} /etc/init.d/
        sudo chmod +x /etc/init.d/${file}

        sudo echo "[RESOLV.CONF] : ${file} moved to startup"

        if [ -n "$(command -v yum)" ]
        then
                sudo chkconfig --add ${file}
        else
                sudo update-rc.d ${file} defaults 15
        fi;
fi


# 5. Creamos el fichero para ejecutar nsupdate y darse de alta en el dns dinamico

for DNS in 0 1 2 3 5
do

echo "dns$DNS.$DOMAIN"

cat > $HOSTNAME$DNS.txt << EOF
server dns$DNS.$DOMAIN
key updatename $KEY
zone $DOMAIN
update delete $HOSTNAME.$DOMAIN. A
update add $HOSTNAME.$DOMAIN. 300 A $IPADDRS
show
send
EOF

# 5.1. Ejecutamos nsupdate para actualizar la entrada en el DNS.
nsupdate $HOSTNAME$DNS.txt
# Comprobamos que se haya hecho correctamente. Si no, paramos el provision.
if [[ $? -ne 0 ]]; then
	echo "Exit status:" $?
	exit 1
fi

done


# 6 Creamos un nuevo fichero si estamos en Amazon (Oregon, SaoPaulo, Irlanda, respectivamente,
# para dar de alta en el DNS el "hostname" indicado en Vagrant.

if [ "$CLOUDID" -eq "110" ] || [ "$CLOUDID" -eq "112" ] || [ "$CLOUDID" -eq "113" ];
then

for DNS in 0 1 2 3 5
do

cat > $HOSTNAME2.txt << EOF
server dns$DNS.$DOMAIN
key updatename $KEY
zone $DOMAIN
update delete $HOSTNAME2.$DOMAIN. A
update add $HOSTNAME2.$DOMAIN. 300 A $IPADDRS
show
send
EOF

# 6.1. Ejecutamos nsupdate para actualizar la entrada en el DNS
nsupdate $HOSTNAME2.txt
# Comprobamos que se haya hecho correctamente. Si no, paramos el provision.
if [[ $? -ne 0 ]]; then
        echo "Exit status:" $?
        exit 1
fi

done

fi
