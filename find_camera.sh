#! /usr/bin/env bash

## Color constants
BOLD="\e[1m"
NC="\e[0m"
RED="\e[31m"

ip_tpl='%s.0.%s.81'
mask='24'
ifc='enp0s25'

for i in 10 100 111 127 169 192; do
	for ((j=0;j<=255;j++)); do
		cur_ip=$(printf "${ip_tpl}" ${i} ${j})
		sudo ip address flush dev ${ifc}
		sudo ip address add "${cur_ip}/${mask}" dev ${ifc}
		sudo nmap -sn "${cur_ip}/${mask}"\
		 | grep 'Nmap scan report'\
		 | grep -v "${cur_ip}"
	done
done



