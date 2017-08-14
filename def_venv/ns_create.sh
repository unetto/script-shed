#!/bin/bash

if [ ! $1 ]; then
	NS_LIST_FILE="ns_list"
else
	NS_LIST_FILE=$1
fi

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

cat $NS_LIST_FILE | grep -v "#" | while read nss; do
	ip netns add $nss
	echo "[INFO] $nss is created."
done
