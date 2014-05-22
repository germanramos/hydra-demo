#!/bin/bash

#chkconfig: 2345 99 03

### BEGIN INIT INFO
# Provides:          routes
# Required-Start:
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: routes init script
# Description:
#
### END INIT INFO

#file=$0
file="routes_allregions.sh"

# 1. Conocer el cloud para posterior configuracion

IPADDRS=$(ifconfig eth0 |grep 255 |cut -d":" -f2|cut -d" " -f1)
HOSTNAME=$(hostname)
CLOUDID=$(echo $IPADDRS|cut -d"." -f2)

# 1.0 Resolvemos nuestro hostname con nuestra IP privada.
EXIST_IP_INHOSTS=$(awk "/$IPADDRS/{x++;}END{print x}" /etc/hosts )
if [ "$EXIST_IP_INHOSTS" == "" ]; then
	echo "$IPADDRS	$HOSTNAME" >> /etc/hosts
fi

# 1.1 Modificamos las rutas

case "$CLOUDID" in
"0")	sudo route add default gw 192.168.10.1
	sudo route del default gw 10.0.2.2
    ;;
"110")	sudo route add default gw 10.110.26.11
	sudo route del default gw 10.110.0.1
    ;;
"111")	#GOOGLE no necesita rutas
    ;;
"112")	sudo route add default gw 10.112.70.219
	sudo route del default gw 10.112.0.1
   ;;
"113")	sudo route add default gw 10.113.193.171
	sudo route del default gw 10.113.0.1
   ;;
esac

sudo echo "[ROUTES] : $HOSTNAME - Routes configured"

# 2. Ponemos el script al inicio

if [ ! -f /etc/init.d/${file} ]; then
	sudo cp /tmp/common/${file} /etc/init.d/
	sudo chmod +x /etc/init.d/${file}

	sudo echo "[ROUTES] : ${file} moved to startup"

        if [ -n "$(command -v yum)" ]
        then
                sudo chkconfig --add ${file}
        else
                sudo update-rc.d ${file} defaults 15
        fi;
fi

# 3. Configurar el MTU de la red.
ifconfig eth0 mtu 1390
