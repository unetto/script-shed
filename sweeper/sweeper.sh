#!/bin/bash

# Unix colors
red='\e[0;31m'
green='\e[0;32m'
nocolor='\e[0m'

# Data files
CSV_FILE_IP_LIST="mdplane.csv"

target_ips=()
declare -A mgmt_ips

cnt=0
for line in `cat ${CSV_FILE_IP_LIST} | grep -v ^#`; do
	target_ips[$cnt]=`echo $line | cut -d ',' -f 2`
	target_ips_sed=`echo ${target_ips[$cnt]} | sed -e "s/\./-/g"`
	mgmt_ips[$target_ips_sed]=`echo $line | cut -d ',' -f 1`

	cnt=$(( cnt + 1 ))
done

for src_ip in ${target_ips[@]}; do
	ping_result_oneline=()
	num_target=0
	for dst_ip in ${target_ips[@]}; do
		src_ip_sed=`echo $src_ip | sed -e "s/\./-/g"`
		ssh ${mgmt_ips[$src_ip_sed]} "ping $dst_ip -I $src_ip -c 1 -i 1 -W 2 > /dev/null"
		if [ $? -eq 0 ]
			#then echo -e "${green}icmp reachable: mgmt_ip=${mgmt_ips[$src_ip_sed]}, src_ip=$src_ip, dst_ip=$dst_ip${nocolor}"
			#else echo -e "${red}icmp unreachable: mgmt_ip=${mgmt_ips[$src_ip_sed]}, src_ip=$src_ip, dst_ip=$dst_ip${nocolor}"
			then
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
