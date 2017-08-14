#!/bin/bash

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

if [ ! $1 ]; then
	BR_LIST_FILE="br_list"
else
	BR_LIST_FILE=$1
fi

./br_delete.sh
./br_create.sh $BR_LIST_FILE
