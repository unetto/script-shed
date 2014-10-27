#!/bin/bash

# STATIC VALUES
TRUE=0
FALSE=1
LINUX_BRIDGE=0
OVS_BRIDGE=1

#BRIDGE_TYPE=$LINUX_BRIDGE
BRIDGE_TYPE=$OVS_BRIDGE

# Data files
FILE_BR_LIST="br_list"
FILE_VETH_LIST="veth_list"
FILE_NS_LIST="ns_list"

##
# Root verification
##
if [ "`id | grep root`" = "" ]
then
	echo "Error: Not root"
	exit 1
fi

# Verify the number of Arguments
arg_check(){
	echo "The number of arguments: $#"
	return $#
}

# Init Linux Bridge
linux_br_init(){
	sum=0
	for i in `linux_br_show`; do
		linux_br_is $i
		if [ $? -eq $TRUE ]; then
			linux_br_delete $i
			let sum=$sum+1
		fi
	done

	echo "The number of deleted linux bridge: $sum"
}

# Verify Linux Bridge
linux_br_is(){
	br=$1
	if [ -z "$br" ]; then
		echo "Error::linux_br_is: An argument linux bridge name needs to be specified."
		exit
	fi

	if [ -n "`linux_br_show $br`" ]; then
		return $TRUE
	else
		return $FALSE
	fi
}


# Show Linux Bridges
linux_br_show(){
	br=$1
	if [ -n "$br" ]; then
		brctl show | grep -w $br | awk '{print $1}'
	else
		brctl show | awk 'NR>1 {print $1}'
	fi
}

# Create Linux Bridges
linux_br_create(){
	br=$1
	if [ -z "$br" ]; then
		echo "Error::linux_br_create: An argument linux bridge name needs to be specified."
		exit
	fi

	brctl addbr $br
	echo "Created Linux Bridge: $br"
}

# Delete Linux Bridges
linux_br_delete(){
	br=$1
	if [ -z "$br" ]; then
		return
	fi
			
	brctl delbr $br
	echo "Deleted Linux Bridge: $br"
}

# Init OVS Bridge
ovs_br_init(){
	sum=0
	for i in `ovs_br_show`; do
		ovs_br_is $i
		if [ $? -eq $TRUE ]; then
			ovs_br_delete $i
			let sum=$sum+1
		fi
	done

	echo "The number of deleted ovs bridge: $sum"
}

# Verify OVS Bridges
ovs_br_is(){
	br=$1
	if [ -z "$br" ]; then
		echo "Error::ovs_br_is: An argument OVS bridge name needs to be specified."
		exit
	fi

	if [ -n "`ovs_br_show $br`" ]; then
		return $TRUE
	else
		return $FALSE
	fi
}

# Show OVS Bridges
ovs_br_show(){
	br=$1
	if [ -n "$br" ]; then
		ovs-vsctl list-br | grep -w $br
	else
		ovs-vsctl list-br
	fi
}

# Create OVS Bridges
ovs_br_create(){
	br=$1
	if [ -z "$br" ]; then
		echo "Error::ovs_br_create: An argument OVS bridge name needs to be specified."
		exit
	fi

	ovs-vsctl add-br $br
	echo "Created OVS Bridge: $br"
}

# Delete OVS Bridges
ovs_br_delete(){
	br=$1
	if [ -z "$br" ]; then
		return
	fi

	ovs-vsctl del-br $br
	echo "Deleted OVS Bridge: $br"
}

# Init OVS Port
ovs_port_init(){	
	sum=0
	for br in `ovs-vsctl list-br`; do
		for port in `ovs_port_show $br`; do
			ovs_port_is $br $port
			if [ $? -eq $TRUE ]; then
				ovs_port_delete $br $port
				let sum=$sum+1
			fi
		done
	done

	echo "The number of deleted ovs port: $sum"
}

# Verify OVS Port
ovs_port_is(){
	br=$1
	port=$2
	if [ -z "$br" -o -z "$port" ]; then
		echo "Error::ovs_port_is: Two arguments, which are (1)bridge name and (2)port name, need to be specified."
		exit
	fi

	if [ -n "`ovs_port_show $br $port`" ]; then
		return $TRUE
	else
		return $FALSE
	fi
}

# Show OVS Ports
ovs_port_show(){
	br=$1
	port=$2
	if [ -z "$br" ]; then
		for i in `ovs-vsctl list-br`; do
			ovs-vsctl list-ports $i
		done
	elif [ -z "$port" ]; then
		ovs-vsctl list-ports $br
	else
		ovs-vsctl list-ports $br | grep -w $port
	fi
}

# Create OVS Port
ovs_port_create(){
	br=$1
	port=$2
	if [ -z "$br" -o -z "$port" ]; then
		echo "Error::ovs_port_create: Two arguments, which are (1)bridge name and (2)port name, need to be specified."
		exit
	fi

	ovs-vsctl add-port $br $port
	echo "Created OVS Port: $br of OVS Bridge:$br"
}

# Delete OVS Port
ovs_port_delete(){
	br=$1
	port=$2
	if [ -z "$br" -o -z "$port" ]; then
		return
	fi

	ovs-vsctl del-port $br $port
	echo "Deleted OVS Port: $port of $br"
}

# Init veth
veth_init(){
	sum=0
	for i in `veth_show`; do
		veth_is $i
		if [ $? -eq $TRUE ]; then
			veth_delete $i
			let sum=$sum+1
		fi
	done

	echo "The number of deleted veth: $sum"
}

# Verify veth
veth_is(){
	veth=$1
	if [ -z "$veth" ]; then
		echo "Error::veth_is: An argument veth name needs to be specified."
		exit
	fi

	if [ -n "`veth_show $veth`" ]; then
		return $TRUE
	else
		return $FALSE
	fi
}

# Show veth
veth_show(){
	#declare -A ovs_br_declare
	#for i in `ovs-vsctl list-br`; do
	#	ovs_br_declare["$i"]="$i"
	#done
	
	veth=$1
	if [ -n "$veth" ]; then
		ip link show | grep -w $veth | awk '{print $2}' | sed -e 's/://g'
	else
		array=("`ip link show | grep mtu | awk '{print $2}' | sed -e 's/://g'`")
		linux_br_array=("`brctl show | awk 'NR>1 {print $1}'`")
		ovs_br_array=("`ovs-vsctl list-br`" "ovs-system")
		linux_if_array=("lo" "`ip link show | grep mtu | awk '{print $2}' | sed -e 's/://g' | grep eth*`")
		elimi_array=()
		for elm in ${linux_br_array[@]} ${ovs_br_array[@]} ${linux_if_array[@]}; do
			elim_array+=("$elm")
		done

		IFS=$'\n'
		# Get common elements
		both=(`{ echo "${array[*]}"; echo "${elim_array[*]}"; } | sort | uniq -d`)
			
		# array - both
		only_array=(`{ echo "${array[*]}"; echo "${both[*]}"; } | sort | uniq -u`)
		echo "${only_array[*]}"
	fi
}

# Create veth
veth_create(){
	veth=$1
	veth_peer=$2
	if [ -z "$veth" -o -z "$veth_peer" ]; then
		echo "Error::veth_create: Two arguments, which are (1)veth name and (2)veth peer name, need to be specified."
		exit
	fi

	ip link add $veth type veth peer name $veth_peer	
	echo "Created veth:      $veth"
	echo "Created veth peer: $veth_peer"
}

# Delete veth
veth_delete(){
	veth=$1
	if [ -z "$veth" ]; then
		return
	fi

	ip link delete $veth
	echo "Deleted veth:      $veth"
	echo "Deleted veth peer: -"
}

# Init Linux network namespace
ns_init(){
	sum=0
	for i in `ns_show`; do
		ns_is $i
		if [ $? -eq $TRUE ]; then
			ns_delete $i
			let sum=$sum+1
		fi
	done

	echo "The number of deleted namespace: $sum"
}

# Verify Linux network namespace
ns_is(){
	ns=$1
	if [ -z "$ns" ]; then
		echo "Error::ns_is: An argument name of linux network namespace needs to be specified."
		exit
	fi

	if [ -n "`ns_show $ns`" ]; then
		return $TRUE
	else
		return $FALSE
	fi
}

# Show Linux network namespace
ns_show(){
	ns=$1
	if [ -n "$ns" ]; then
		ip netns show | grep -w $ns
	else
		ip netns show
	fi
}

# Create Linux network namespace
ns_create(){
	ns=$1
	if [ -z "$ns" ]; then
		echo "Error::ns_create: An argument name of linux network namespace need to be specified."
		exit
	fi

	ip netns add $ns
	echo "Created Linux network namespace: $ns"	
}

# Delete Linux network namespace
ns_delete(){
	ns=$1
	if [ -z "$ns" ]; then
		return
	fi

	ip netns delete $ns
	echo "Deleted Linux network namespace: $ns"
}

##
# Init
##
echo -e "Initialize ...\n"

echo "Init OVS Ports..."
ovs_port_init
echo -e "done.\n"

echo "Init Linux Bridges..."
linux_br_init
echo -e "done.\n"

echo "Init OVS Bridges..."
ovs_br_init
echo -e "done.\n"

echo "Init veths..."
veth_init
echo -e "done.\n"

echo "Init Linux network namespaces..."
ns_init
echo -e "done.\n"

echo -e "Initialize is done.\n"

##
# Check Command line argument
##
while getopts "i" opts
do
	case $opts in
		i)
			echo "Done. (Init only)"
			exit
			;;
	esac
done

##
# Create vSW
##
if [ $BRIDGE_TYPE -eq $LINUX_BRIDGE ]; then
	# Create vSW using Linux Bridges
	echo "Create vSW using Linux Bridges..."
	IFS=$'\n'  # Store "a line" as "an element of array"
	array=(`cat "$FILE_BR_LIST" | grep -v "#"`)
	for i in ${array[@]}; do
		linux_br_create $i
	done
	echo -e "done.\n"
elif [ $BRIDGE_TYPE -eq $OVS_BRIDGE ]; then
	# Create vSW using OVS Bridges
	echo "Create vSW using OVS Bridges..."
	IFS=$'\n'  # Store "a line" as "an element of array"
	array=(`cat "$FILE_BR_LIST" | grep -v "#"`)
	for i in ${array[@]}; do
		ovs_br_create $i
	done
	echo -e "done.\n"
else
	echo "Error: BRIDGE_TYPE need to be which $LINUX_BRIDGE(0) or $OVS_BRIDGE(1)."
	exit
fi

##
# Create vNodes and vLinks
##
echo "Create vNodes and vLinks using veth..."
pair=0
VETH=0
VETH_PEER=1
IFS=$'\n'
array=(`cat "$FILE_VETH_LIST"`)
for veth_pair in ${array[@]}; do
	veth=`echo "$veth_pair" | grep -v "#" | cut -d ',' -f 1`
	veth_peer=`echo "$veth_pair" | grep -v "#" | cut -d ',' -f 2`
	if [ -z "$veth" -o -z "$veth" ]; then
		continue
	fi
	veth_create $veth $veth_peer
done
echo -e "done.\n"

##
# Create isolated reagion
##
echo "Create isolated reagion..."
IFS=$'\n'
array=(`cat "$FILE_NS_LIST" | grep -v "#"`)
for ns in ${array[@]}; do
	ns_create $ns
done
echo -e "done.\n"

##
# Attach vNodes to vSW
##
echo "Attach vNodes to vSW..."

veth_show
