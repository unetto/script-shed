#!/bin/bash

# Unix colors
red='\e[0;31m'
green='\e[0;32m'
nocolor='\e[0m'

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

echo "[INFO] Ping sweeper started."
echo "---"

if [ -e "result.csv" ]; then
	rm "result.csv"
fi
for src_ip in ${service_ips[@]}; do
	ping_result_oneline=()
	num_target=0
	for dst_ip in ${service_ips[@]}; do
		src_ip_sed=`echo $src_ip | sed -e "s/\./-/g"`
		src_ip_ns=`echo $src_ip | sed -e "s/\./-/g"`
		if [ ${#src_ip_ns} -eq 0 ]; then
			ssh ${mgmt_ips[$src_ip_sed]} "ping $dst_ip -I $src_ip -c 1 -i 1 -W 2 > /dev/null"
		else
			sudo ip netns exec ${mgmt_nss[$src_ip_sed]} ping $dst_ip -I $src_ip -c 1 -i 1 -W 2 > /dev/null
		fi
		
		if [ $? -eq 0 ]; then
			echo -e "${green}icmp reachable: mgmt_ip=${mgmt_ips[$src_ip_sed]}, src_ip=$src_ip, dst_ip=$dst_ip${nocolor}"
			ping_result_oneline[$num_target]="o"
		else
			echo -e "${red}icmp unreachable: mgmt_ip=${mgmt_ips[$src_ip_sed]}, src_ip=$src_ip, dst_ip=$dst_ip${nocolor}"
			ping_result_oneline[$num_target]="x"
		fi
		
		num_target=$(( num_target + 1 ))
	done
	echo
	echo ${ping_result_oneline[@]} | tr -s ' ' ',' >> result.csv
done

echo "---"
echo "[INFO] Ping sweeper finished."
