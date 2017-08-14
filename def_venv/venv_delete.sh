#!/bin/bash

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

if [ ! $1 ]; then
	NS_LIST_FILE="ns_list"
else
	NS_LIST_FILE=$1
fi
if [ ! $2 ]; then
	BR_LIST_FILE="br_list"
else
	BR_LIST_FILE=$2
fi
if [ ! $3 ]; then
	VETH_LIST_FILE="veth_list.csv"
else
	VETH_LIST_FILE=$3
fi

# Delete virtual environment
./ns_delete.sh
./br_delete.sh
./veth_delete.sh
