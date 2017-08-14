#!/bin/bash

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

NS_LIST_FILE=$1
if [ ! $NS_LIST_FILE ]; then
	ip netns | cut -d ' ' -f 1 | while read nss; do
		ip netns delete $nss
		echo "[INFO] $nss is deleted."
	done
else
	cat $NS_LIST_FILE | grep -v "#" | while read nss; do
		ip netns delete $nss
		if [ $? -ne 0 ]; then
			continue
		fi
		echo "[INFO] $nss is deleted."
	done
fi
