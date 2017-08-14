#!/bin/bash

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

BR_LIST_FILE=$1
if [ ! $BR_LIST_FILE ]; then
	brctl show | cut -f 1 | grep -v "bridge name" | while read brs; do
		if [ `echo ${#brs}` -ne 0 ]; then
			ip link set $brs down
			brctl delbr $brs
			echo "[INFO] $brs is deleted."
		fi
	done
else
	cat $BR_LIST_FILE | grep -v "#" |  while read brs; do
		ip link set $brs down
		if [ $? -ne 0 ]; then
			continue
		fi
		brctl delbr $brs
		echo "[INFO] $brs is deleted."
	done
fi
