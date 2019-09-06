#! /bin/bash

gateway=$1
if [[ ${gateway} == "" ]]; then
 	echo "Usage: $(basename $0) <gateway>"
	exit 1
fi

ssh -A zero@zero.aleph -- sudo /home/zero/engineering/network/openvpn/route-client.sh ${gateway}
#ssh -A dell@one.aleph -- sudo /home/dell/engineering/network/openvpn/route-client.sh ${gateway}
ssh -A dell@one.aleph -- sudo ip route del default
ssh -A dell@one.aleph -- sudo ip route add default via ${gateway}

#~/scripts/proxy.sh
