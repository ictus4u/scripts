#!/usr/bin/env bash

# yes | no | unknown
value=$1

for iface in $(ip a | grep "^[0-9]\+:" | cut -d" " -f2| cut -d":" -f1 | grep -v "^lo$" | xargs); do
  connection=$(nmcli -t -f GENERAL.CONNECTION --mode tabular device show ${iface} | head -n1)
  if [ "${connection}" != "" ]; then
    nmcli connection modify "${connection}" connection.metered ${value}
  fi
done
