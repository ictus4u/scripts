#! /usr/bin/env bash

for ((j=1;j<255;j++)); do
	cur_ip=192.168.1.${j}
	nc -zv ${cur_ip} 80
	if [ -z 0 ]; then 
		echo -e "\e[31m${cur_ip}\e[0m"; 
	fi;
done

