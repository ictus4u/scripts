#!/usr/bin/env bash

####################################################
###  Usage:                                      ###
###  1. $ crontab -e                             ###
###  2. Add: * * * * * path_to_this_script       ###
####################################################

VPN_SERVICE="openvpn@baldor"
iface=tun0

for i in {1..2}; do
  ifconfig ${iface} > /dev/null 2>&1
  if [ $? == 0 ]; then
    sudo service ${VPN_SERVICE} stop
    sudo service ${VPN_SERVICE} start
  fi
  sleep 30;
done
