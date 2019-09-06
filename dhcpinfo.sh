#!/usr/bin/env bash
function get_dhcp_info {
	log_file=/var/log/syslog
	DHCP_INFO['leased_ip']=$(grep "dhclient\[[0-9]\+\]: bound to" ${log_file} | tail -n1 | sed "s/.* \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g" )
	dhcp_request_line=$(grep "DHCPREQUEST of ${leased_ip}" ${log_file} | tail -n1)
	DHCP_INFO['iface']=$(echo ${dhcp_request_line}| sed "/of ${leased_ip}/ s/.*on \(\\w\+\).*/\1/g" )
	DHCP_INFO['dhcp_server']=$(echo ${dhcp_request_line} |sed "/of ${leased_ip}/ s/.* to \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g")
	for i in address plen gateway hostname nameserver; do
		DHCP_INFO[$i]=$(grep "dhcp4 (enp0s20u2):   $i" /var/log/syslog | tail -n1 | sed "s/.*$i \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\|[0-9]\+\|\\w\+\|'[^']*'\).*/\1/")	
	done
}

declare -A DHCP_INFO
get_dhcp_info
for K in "${!DHCP_INFO[@]}"; do echo $K: ${DHCP_INFO[$K]}; done