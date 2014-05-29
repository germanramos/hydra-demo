#!/bin/bash

# 1. Obtenemos la IP de la maquina para saber en que cloud esta
IPADDRS=$(ifconfig eth0 |grep 255 |cut -d":" -f2|cut -d" " -f1)
HOSTNAME=$(hostname)
CLOUDID=$(echo $IPADDRS|cut -d"." -f2)

# 2. Segun el cloud, se conecta a un terminador VPN
case "$CLOUDID" in
"0")	VPN_IP="192.168.10.224"
	VPN_URL="lab.innotechapp.com"
    ;;
"110")	VPN_IP="10.110.26.11"
        VPN_URL="aws-oregon.innotechapp.com"
    ;;
"111")	VPN_IP="10.111.254.49"
        VPN_URL="gce.innotechapp.com"
    ;;
"112")	VPN_IP="10.112.70.219"
        VPN_URL="aws-ireland.innotechapp.com"
   ;;
"113")	VPN_IP="10.113.193.171"
        VPN_URL="aws-saopaulo.innotechapp.com"
   ;;
esac

# 3. Redirigimos el trafico a nuestra maquina.
HOST=$1
PORT_PUBLIC=$2
PORT_PRIVATE=$3

curl  -d '' ${VPN_IP}:6666/${HOST}.${VPN_URL}/${PORT_PUBLIC}/${HOST}/${PORT_PRIVATE}
