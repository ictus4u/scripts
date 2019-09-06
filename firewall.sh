#!/usr/bin/env bash

### network interfaces
# todo: find the current network interface
ifaces=$(ip address | grep '^[0-9]\+: .*\?:.*'| sed 's/^[0-9]\+: \(.*\)\?:.*/\1/'| grep -v 'lo'| sort --unique | xargs)
declare -A DHCP_INFO
function get_dhcp_info {
	iface=$1
	log_file=/var/log/syslog
	leased_ip=$(grep "dhclient\[[0-9]\+\]: bound to" ${log_file} | tail -n1 | sed "s/.* \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g" )
	dhcp_request_line=$(grep "DHCPREQUEST of ${leased_ip}" ${log_file} | tail -n1)
	DHCP_INFO['iface']=$(echo ${dhcp_request_line}| sed "/of ${leased_ip}/ s/.*on \(\\w\+\).*/\1/g" )
	DHCP_INFO['dhcp_server']=$(echo ${dhcp_request_line} |sed "/of ${leased_ip}/ s/.* to \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/g")
	for i in address plen gateway hostname nameserver; do
		DHCP_INFO[$i]=$(grep "dhcp4 (${iface}):   $i" /var/log/syslog | tail -n1 | sed "s/.*$i \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\|[0-9]\+\|\\w\+\|'[^']*'\).*/\1/")	
	done
}
#################################
#	PRIVATE NETWORKS:			#
#	=================			#
#	10.0.0.0/8 -j (A)			#
#	172.16.0.0/12 (B)			#
#	192.168.0.0/16 (C)			#
#	224.0.0.0/4 (MULTICAST D)	#
#	240.0.0.0/5 (E)				#
#	127.0.0.0/8 (LOOPBACK)		#
#################################

INTERNET_GROUP=internet
DNS_SERVER="10.10.1.43 10.10.1.50 10.10.1.65 10.10.1.200 8.8.8.8 8.8.4.4"
private_nets="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/5 127.0.0.0/8"
WAN_CONFIG="DHCP"
WAN_IFACE="enp0s20f0u4u3" # "wlp4s0" # <- <- <- Change this <- <- <- 
WAN_NET="DHCP" # if DHCP enabled put DHCP, it will detect Network configuration
WAN_IP=$(echo $WAN_NET| cut -d'/' -f1)
if [ "$WAN_CONFIG"=='DHCP' ]; then
	get_dhcp_info ${WAN_IFACE}
	WAN_NET="${DHCP_INFO['address']}/${DHCP_INFO['plen']}"
	WAN_IP="${DHCP_INFO['address']}"
	WAN_IFACE="${DHCP_INFO['iface']}"
	DHCP_SERVER="${DHCP_INFO['dhcp_server']}"
	DNS_SERVER=$(echo "${DHCP_INFO['nameserver']} ${DNS_SERVER}" |tr " " "\n"| sort --unique| xargs)
fi
LAN_IFACE= # "wlp3s0" # wlp3s0 enp0s20u2 
LAN_NET= # "10.10.0.0/16"
LAN_IP=$(echo $LAN_NET| cut -d'/' -f1)
# TODO: allow to enable DHCP server on LAN
DMZ_IFACE=""
DMZ_NET=""
DMZ_IP=$(echo $DMZ_NET| cut -d'/' -f1)


if [ ! -z ${WAN_IFACE} ]; then
	WAN_MODE=on
fi

if [ ! -z ${LAN_IFACE} ]; then
	LAN_MODE=on
fi

if [ ! -z ${DMZ_IFACE} ]; then
	DMZ_MODE=on
fi

###############
# VARIABLE DEFINITIONS
ipt="sudo $(which iptables)"
mod="sudo $(which modprobe)" 


#Your DHCP Server for input of ICMP packets
if [ "${WAN_MODE}" == 'on' ]; then
	PUBLIC_IFACE=${WAN_IFACE}
elif [ "${LAN_MODE}" == 'on' ]; then
	PUBLIC_IFACE=${LAN_IFACE}
else
	PUBLIC_IFACE=lo
fi
if [ "${LAN_MODE}" == 'on' ]; then
	PRIVATE_IFACE=${LAN_IFACE}
elif [ "${WAN_MODE}" == 'on' ]; then
	PRIVATE_IFACE=${WAN_IFACE}
else
	PRIVATE_IFACE=lo
fi

function CUSTOM_INPUT_RULES {
	### KDE connect
	$ipt -A INPUT -m state --state NEW -m tcp -p tcp --dport 1714:1764 -j ACCEPT -m comment --comment "Allow KDE connect"
	$ipt -A INPUT -m state --state NEW -m udp -p udp --dport 1714:1764 -j ACCEPT -m comment --comment "Allow KDE connect"
	### SSH connectios
	$ipt -A INPUT -p tcp --dport 22 --sport 1024:65535 -m state --state NEW -j ACCEPT -m comment --comment "Allow SSH connection"
}

function CUSTOM_OUTPUT_RULES {
	# # accept outgoing packets on private interface for internal traffic 
	# # (not needed as default policy is accept output on wifi, but it can change in order to reduce/conteol internet traffic)
	# for net in $(echo $private_nets $LAN_NET | tr " " "\n" | sort --unique); do
	# 	$ipt -A OUTPUT -o ${PRIVATE_IFACE} -d ${net} -j ACCEPT
	# done
	: # noop
}

function default_accept_everything {
	$ipt -P INPUT ACCEPT
	$ipt -P FORWARD ACCEPT
	$ipt -P OUTPUT ACCEPT
	$ipt -t nat -P OUTPUT ACCEPT
	$ipt -t nat -P PREROUTING ACCEPT
	$ipt -t nat -P POSTROUTING ACCEPT
	$ipt -t mangle -P INPUT ACCEPT
	$ipt -t mangle -P OUTPUT ACCEPT
	$ipt -t mangle -P FORWARD ACCEPT
	$ipt -t mangle -P PREROUTING ACCEPT
	$ipt -t mangle -P POSTROUTING ACCEPT
}

function default_secure_policy {	
	OUTPUT_DEFAULT=ACCEPT

	case $1 in 
		'ACCEPT')
			OUTPUT_DEFAULT=ACCEPT
		;;
		'DROP')
			OUTPUT_DEFAULT=LOGNDROP
		;;
		'REJECT')
			OUTPUT_DEFAULT=LOGNRJCT
		;;
	esac

	# $ipt -P INPUT DROP
	$ipt -A INPUT -j LOGNDROP
	# $ipt -P FORWARD DROP
	$ipt -A FORWARD -j LOGNDROP
	# $ipt -P OUTPUT ACCEPT	
	$ipt -A OUTPUT -j ${OUTPUT_DEFAULT}
	$ipt -t nat -P OUTPUT ACCEPT
	$ipt -t nat -P PREROUTING ACCEPT
	$ipt -t nat -P POSTROUTING ACCEPT
	$ipt -t mangle -P INPUT ACCEPT
	$ipt -t mangle -P OUTPUT ACCEPT
	$ipt -t mangle -P FORWARD ACCEPT
	$ipt -t mangle -P PREROUTING ACCEPT
	$ipt -t mangle -P POSTROUTING ACCEPT
}

function reset_counters {
	$ipt -Z
	$ipt -t nat -Z
	$ipt -t mangle -Z
}

function flush_n_delete {	
	$ipt -F
	$ipt -t nat -F
	$ipt -t mangle -F
	$ipt -t filter -F
	$ipt -X
	$ipt -t nat -X
	$ipt -t mangle -X
	$ipt -t filter -X
}

function firewall_clean {
	reset_counters
	flush_n_delete
}

function firewall_flush {
	default_accept_everything
	firewall_clean
}

function system_security {
	sctl=$(which sysctl)
	# KERNEL PARAMETER CONFIGURATION
	#
	# DROP ICMP ECHO-REQUEST MESSAGES SENT TO BROADCAST OR MULTICAST ADDRESSES
	echo 1 | sudo tee /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts >/dev/null
	#
	# DONT ACCEPT ICMP REDIRECT MESSAGES
	echo 0 | sudo tee /proc/sys/net/ipv4/conf/all/accept_redirects >/dev/null
	#
	# DONT SEND ICMP REDIRECT MESSAGES
	echo 0 | sudo tee /proc/sys/net/ipv4/conf/all/send_redirects >/dev/null
	#
	# DROP SOURCE ROUTED PACKETS 
	echo 0 | sudo tee /proc/sys/net/ipv4/conf/all/accept_source_route >/dev/null
	#
	# ENABLE TCP SYN COOKIE PROTECTION FROM SYN FLOODS
	echo 1 | sudo tee /proc/sys/net/ipv4/tcp_syncookies >/dev/null
	#
	# ENABLE SOURCE ADDRESS SPOOFING PROTECTION
	echo 1 | sudo tee /proc/sys/net/ipv4/conf/all/rp_filter >/dev/null

	# LOG PACKETS WITH IMPOSSIBLE ADDRESSES (DUE TO WRONG ROUTES) ON YOUR NETWORK
	echo 1 | sudo tee /proc/sys/net/ipv4/conf/all/log_martians >/dev/null

	# DISABLE IPV4 FORWARDING
	if [ "${WAN_MODE}" == 'on' ] && [ "${LAN_MODE}" == 'on' ]; then
		echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
	else
		echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward >/dev/null
	fi
	# TODO: uptade this to use /etc/sysctl.conf in order to make configuration to be persistent
	sudo $sctl -p
}

function iptables_secure_base {
	###############
	system_security
	###############
	firewall_clean
	###############
	#basic set of kernel modules
	$mod ip_tables
	$mod ip_conntrack
	$mod iptable_filter
	$mod iptable_nat
	$mod iptable_mangle
	$mod ipt_LOG
	$mod ipt_limit
	$mod ipt_state
	$mod ipt_MASQUERADE
	$mod ipt_comment

	#add these for IRC and FTP
	$mod ip_nat_ftp
	$mod ip_nat_irc
	$mod ip_conntrack_ftp
	$mod ip_conntrack_irc

	# add these for owner filter
	$mod ipt_owner

	# $mod ip_queue	# it fails
	# $mod ipt_MARK
	# $mod ipt_REDIRECT
	# $mod ipt_REJECT
	# $mod ipt_TCPMSS
	# $mod ipt_TOS
	# $mod ipt_mac
	# $mod ipt_mark
	# $mod ipt_multiport
	# $mod ipt_tcpmss
	# $mod ipt_tos

	# LOGDROPPER
	$ipt -N LOGNDROP > /dev/null 2> /dev/null 
	$ipt -F LOGNDROP
	$ipt -A LOGNDROP -j LOG --log-prefix "LOGNDROP: "
	$ipt -A LOGNDROP -j DROP
	###############
	# LOGREJECTER
	$ipt -N LOGNRJCT > /dev/null 2> /dev/null 
	$ipt -F LOGNRJCT
	$ipt -A LOGNRJCT -j LOG --log-prefix "LOGNRJCT: "
	$ipt -A LOGNRJCT -j REJECT

	# #custom tcp allow chain
	# $ipt -N ALLOW
	# $ipt -A ALLOW -p TCP --syn -j ACCEPT
	# $ipt -A ALLOW -p TCP -m state --state ESTABLISHED,RELATED -j ACCEPT
	# $ipt -A ALLOW -p TCP -j LOGNDROP

	###############
	# loopback interface
	$ipt -A INPUT -i lo -j ACCEPT
	$ipt -A OUTPUT -o lo -j ACCEPT

	#Enable IP masquerading
	if [ "${WAN_MODE}" == 'on' ]; then
		# Enable ip masquerading
		if [ "${WAN_CONFIG}" == 'DHCP' ]; then
			$ipt -t nat -A POSTROUTING -o $WAN_IFACE -j MASQUERADE
		else
			$ipt -t nat -A POSTROUTING -o $WAN_IFACE -j SNAT --to-source ${WAN_IP}
		fi
	fi

	###############
	# Only bring what you need to survive
	if [ ! -z $DHCP_SERVER ]; then
		$ipt -A INPUT -p icmp -s ${DHCP_SERVER} -j ACCEPT -m comment --comment "DHCP server"
		$ipt -A INPUT -i ${PUBLIC_IFACE} -s ${DHCP_SERVER} -p tcp --sport 68 --dport 67 -j ACCEPT -m comment --comment "DHCP server"
		$ipt -A INPUT -i ${PUBLIC_IFACE} -s ${DHCP_SERVER} -p udp --sport 68 --dport 67 -j ACCEPT -m comment --comment "DHCP server"
	fi
	for ip in $DNS_SERVER
	do
		$ipt -A OUTPUT -p udp -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
		$ipt -A INPUT  -p udp -s $ip --sport 53 -m state --state ESTABLISHED     -j ACCEPT
		$ipt -A OUTPUT -p tcp -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
		$ipt -A INPUT  -p tcp -s $ip --sport 53 -m state --state ESTABLISHED     -j ACCEPT
	done
	###############
	# INPUT
	#
	# DROP INVALID
	$ipt -A INPUT -m state --state INVALID -j LOGNDROP

	#Enable unrestricted outgoing traffic, incoming is restricted to locally-initiated sessions only
	$ipt -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	if [ "${WAN_MODE}" == 'on' ] && [ "${LAN_MODE}" == 'on' ]; then
		$ipt -A FORWARD -i $WAN_IFACE -o $LAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
		$ipt -A FORWARD -i $LAN_IFACE -o $WAN_IFACE -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
		#allow traffic to route from VPN subnet to specific host in subnet
		# $ipt -A FORWARD -i tun+ -j ACCEPT
		$ipt -A INPUT -i tun+ -j ACCEPT
		$ipt -A OUTPUT -o tun+ -j ACCEPT
		#allow traffic from host in server subnet back to VPN subnet
		iptables -A FORWARD -o tun0 -s {host in server subnet} -d {VPN subnet}
		if [ "${DMZ_MODE}" == 'on' ]; then
			$ipt -A FORWARD -i $LAN_IFACE -o $DMZ_IFACE -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
			$ipt -A FORWARD -i $DMZ_IFACE -o $LAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
			$ipt -A FORWARD -i $WAN_IFACE -o $DMZ_IFACE -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
			$ipt -A FORWARD -i $DMZ_IFACE -o $WAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
		fi
	fi

	# Accept important ICMP messages
	$ipt -A INPUT -p icmp --icmp-type echo-request -j ACCEPT -m comment --comment "Ping"
	$ipt -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT -m comment --comment "Ping"
	$ipt -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT -m comment --comment "Ping"

	# DROP INVALID SYN PACKETS
	$ipt -A INPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j LOGNDROP
	$ipt -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOGNDROP
	$ipt -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOGNDROP

	# MAKE SURE NEW INCOMING TCP CONNECTIONS ARE SYN PACKETS; OTHERWISE WE NEED TO DROP THEM
	$ipt -A INPUT -p tcp ! --syn -m state --state NEW -j LOGNDROP

	# DROP PACKETS WITH INCOMING FRAGMENTS. THIS ATTACK RESULT INTO LINUX SERVER PANIC SUCH DATA LOSS
	$ipt -A INPUT -f -j LOGNDROP

	# DROP INCOMING MALFORMED XMAS PACKETS
	$ipt -A INPUT -p tcp --tcp-flags ALL ALL -j LOGNDROP

	# DROP INCOMING MALFORMED NULL PACKETS
	$ipt -A INPUT -p tcp --tcp-flags ALL NONE -j LOGNDROP

	CUSTOM_INPUT_RULES

	# IP SPOOFING DROP INCOMING PACKETS VIA PUBLIC INTERFACE FROM INTERNAL/PRIVATE NETWORKS
	if [ "${WAN_MODE}" == 'on' ] && [ "${LAN_MODE}" == 'on' ];  then
		for net in $(echo ${private_nets} ${LAN_NET} ${DMZ_NET} | tr " " "\n" | sort --unique); do
			$ipt -A INPUT -i ${WAN_IFACE} -s ${net} -j LOGNDROP
		done
	fi

	###############
	# OUTPUT

	# DROP INVALID
	$ipt -A OUTPUT -m state --state INVALID -j LOGNDROP

	# DROP INVALID SYN PACKETS
	$ipt -A OUTPUT -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j LOGNDROP
	$ipt -A OUTPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOGNDROP
	$ipt -A OUTPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOGNDROP

	# DROP PACKETS WITH OUTGOING FRAGMENTS. THIS ATTACK RESULT INTO LINUX SERVER PANIC SUCH DATA LOSS
	$ipt -A OUTPUT -f -j LOGNDROP

	# DROP OUTGOING MALFORMED XMAS PACKETS
	$ipt -A OUTPUT -p tcp --tcp-flags ALL ALL -j LOGNDROP

	# DROP OUTGOING MALFORMED NULL PACKETS
	$ipt -A OUTPUT -p tcp --tcp-flags ALL NONE -j LOGNDROP

	# ALLOW OUTGOING ON PRIVATE INTERFACES
	# $ipt -A OUTPUT -o ${PRIVATE_IFACE} -j ACCEPT
	CUSTOM_OUTPUT_RULES
}

function iptables_mobile {
	iptables_secure_base
	# accept outgoing packets for internet group
	$ipt -A OUTPUT -m owner --gid-owner ${INTERNET_GROUP} -j ACCEPT -m comment --comment "Allow output traffic for proccess owned by ${INTERNET_GROUP} group"
	default_secure_policy DROP
}

function iptables_wifi {
	iptables_secure_base
	default_secure_policy ACCEPT
}

function iptables_restore {
	firewall_clean
	sudo cat /root/firewall.rules | sudo iptables-restore 
}

function iptables_save {
	sudo iptables-save | sudo tee /root/firewall.rules >/dev/null
}

function iptables_start {
	iptables_restore
}

function iptables_stop {
	iptables_save
	firewall_flush
}

function iptables_show {
	$ipt -t filter -L -n -v --line-numbers
	$ipt -t nat -L -n -v --line-numbers
	$ipt -t mangle -L -n -v --line-numbers
}

case $1 in
	'start')
		iptables_start	
	;;
	'stop')
		iptables_stop
	;;
	'list')
		iptables_show
	;;
	'profile-wifi')
		iptables_wifi
	;;
	'profile-mobile')
		# sudo group add
		iptables_mobile
		# open a shell with internet access
		sudo -g internet -s
	;;
	'trace')
		tail -f /var/log/kern.log
	;;
	*)
		echo -e "Usage: $(basename $0) [start|stop|list|profile-wifi|profile-mobile|trace]"
	;;
esac