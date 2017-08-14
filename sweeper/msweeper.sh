#!/bin/bash

# Unix colors
red='\e[0;31m'
green='\e[0;32m'
nocolor='\e[0m'

# Root verification
if [ "`id | grep root`" = "" ]; then
	echo "Error: you are not root"
	exit 1
fi

if [ ! $1 ]; then
	TARGET_IP_LIST_FILE="target_list.csv"
else
	TARGET_IP_LIST_FILE=$1
fi
service_ips=()
declare -A mgmt_ips
declare -A mgmt_nss
cnt=0
for line in `cat $TARGET_IP_LIST_FILE | grep -v "#"`; do
	service_ips[$cnt]=`echo $line | cut -d ',' -f 2`
	service_ips_sed=`echo ${service_ips[$cnt]} | sed -e "s/\./-/g"`
	mgmt_ips[$service_ips_sed]=`echo $line | cut -d ',' -f 1`
	mgmt_nss[$service_ips_sed]=`echo $line | cut -d ',' -f 3`
	cnt=$(( cnt + 1 ))
done

echo "[INFO] Multiple ping sweeper started."

PROC_ID_LIST_FILE="proc_list"
if [ -e $PROC_ID_LIST_FILE ]; then
	rm $PROC_ID_LIST_FILE
fi
echo "# proc_id,src_ip,dst_ip" >> $PROC_ID_LIST_FILE
for src_ip in ${service_ips[@]}; do
	for dst_ip in ${service_ips[@]}; do
		src_ip_sed=`echo $src_ip | sed -e "s/\./-/g"`
		src_ip_ns=`echo $src_ip | sed -e "s/\./-/g"`
		if [ ${#src_ip_ns} -eq 0 ]; then
			ssh ${mgmt_ips[$src_ip_sed]} "ping $dst_ip -I $src_ip -c 1 -i 1 -W 2 > /dev/null" &
		else
			ip netns exec ${mgmt_nss[$src_ip_sed]} ping $dst_ip -I $src_ip -c 1 -i 1 -W 2 > /dev/null &
		fi
		echo "$!,$src_ip,$dst_ip" >> $PROC_ID_LIST_FILE
	done
done

# Test result
RESULT_LIST_FILE="result_list"
if [ -e $RESULT_LIST_FILE ]; then
	rm $RESULT_LIST_FILE
fi
echo -e "# status code(${green}0=icmp reachable${nocolor}/${red}1=icmp unreachable${nocolor}),proc_id,src_ip,dst_ip" | tee $RESULT_LIST_FILE
while read line; do
	echo $line | grep -v "#" > /dev/null
	if [ $? -ne 0 ]; then
		continue
	fi
	pid=`echo $line | cut -d ',' -f 1`
	wait $pid
	if [ $? -eq 0 ]; then
		echo -e "${green}$?,$line" | tee $RESULT_LIST_FILE
	else
		echo -e "${red}$?,$line" | tee $RESULT_LIST_FILE
	fi
done < `echo $PROC_ID_LIST_FILE`

echo -e ${nocolor}"[INFO] Multiple ping sweeper finished."
