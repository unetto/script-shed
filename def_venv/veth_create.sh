#!/bin/bash

if [ ! $1 ]; then
	VETH_LIST_FILE="veth_list.csv"
else
	VETH_LIST_FILE=$1
fi

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

# Create veths
cat $VETH_LIST_FILE | grep -v "#" | while read line; do
	veth=`echo $line | cut -d ',' -f 1`
	veth_peer=`echo $line | cut -d ',' -f 3`
	ip link add $veth type veth peer name $veth_peer

#	veth_ipaddr=`echo $line | cut -d ',' -f 2`
#	ip link set $veth up
#	if [ ${#veth_ipaddr} -ne 0 ]; then
#		ip addr add $veth_ipaddr dev $veth
#	else
#		ip link set $veth up
#	fi
	
	veth_peer_ipaddr=`echo $line | cut -d ',' -f 4`
	if [ ${#veth_peer_ipaddr} -ne 0 ]; then
		ip addr add $veth_peer_ipaddr dev $veth_peer
	fi
	ip link set $veth_peer up

	echo "[INFO] $veth <- $veth_ipaddr"
	echo "[INFO] $veth_peer <- $veth_peer_ipaddr"
done
