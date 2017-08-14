#!/bin/bash

if [ ! $1 ]; then
	BR_LIST_FILE="br_list"
else
	BR_LIST_FILE=$1
fi

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

cat $BR_LIST_FILE | grep -v "#" | while read brs; do
	brctl addbr $brs
	ip link set $brs up
	echo "[INFO] $brs is created."
done
