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

./ns_delete.sh
./ns_create.sh $NS_LIST_FILE
