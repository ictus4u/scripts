#!/usr/bin/env bash

####################################################
###  Usage:                                      ###
###  1. $ crontab -e                             ###
###  2. Add: * * * * * path_to_this_script       ###
####################################################

# Google DNS
testIp="8.8.8.8"

# www.cubdebate.cu
testLocalIp="190.92.127.78"

for i in {1..2}; do
  (ping -q -n -c 3 -w 6 ${testIp} >/dev/null);
  if [ ! $? ]; then
    (ping -q -n -c 3 -w 6 ${testLocalIp} >/dev/null);
    if [ $? ]; then
      vpn-restart;
    fi
  fi
  sleep 30;
done
