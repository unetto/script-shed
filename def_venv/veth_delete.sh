#!/bin/bash

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

VETH_LIST_FILE=$1
if [ ! $VETH_LIST_FILE ]; then
	ip link show type veth | cut -d " " -f 2 | cut -d "@" -f 1 | while read veths; do
		if [ ${#veths} -eq 0 ]; then
			continue
		fi
		ip link delete $veths
		if [ $? -ne 0 ]; then
			continue
		fi
		echo "[INFO] $veths is deleted."
	done
else
	cat $VETH_LIST_FILE | grep -v "#" | while read veths; do
		ip link delete $veths
		if [ $? -ne 0 ]; then
			continue
		fi
		echo "[INFO] $veths is deleted."
	done
fi
