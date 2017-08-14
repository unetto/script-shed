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

# Define virtual environment
./ns_create.sh $NS_LIST_FILE
./br_create.sh $BR_LIST_FILE
./veth_create.sh $VETH_LIST_FILE

# Management Plane
brctl addif br-mgmt peer-h1
brctl addif br-mgmt peer-h2
brctl addif br-mgmt peer-h3
ip link set h1 netns host1
ip link set h2 netns host2
ip link set h3 netns host3
ip netns exec host1 ip addr add 172.16.228.10/24 dev h1
ip netns exec host2 ip addr add 172.16.228.20/24 dev h2
ip netns exec host3 ip addr add 172.16.228.30/24 dev h3
ip netns exec host1 ip link set h1 up
ip netns exec host2 ip link set h2 up
ip netns exec host3 ip link set h3 up

# Data Plane
brctl addif br-service peer-h1-srv
brctl addif br-service peer-h2-srv
brctl addif br-service peer-h3-srv
ip link set h1-srv netns host1
ip link set h2-srv netns host2
ip link set h3-srv netns host3
ip netns exec host1 ip addr add 192.168.0.10/24 dev h1-srv
ip netns exec host2 ip addr add 192.168.0.20/24 dev h2-srv
ip netns exec host3 ip addr add 192.168.0.30/24 dev h3-srv
ip netns exec host1 ip link set h1-srv up
ip netns exec host2 ip link set h2-srv up
ip netns exec host3 ip link set h3-srv up
