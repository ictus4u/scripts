#! /bin/bash

# Enable socks proxy
socks_active=$(( $(ps aux | grep "ssh -D 9128"| wc -l) - 1 ))
if [[ ${socks_active} == 0 ]]; then
        ssh -D 9128 -A -fCqN fjfj &
        echo "SOCKS proxy enabled!"
else
        echo "SOCKS proxy already enabled."
fi

socks_active=$(( $(ps aux | grep "delegate.*:9129"| wc -l) - 1 ))
if [[ ${socks_active} == 0 ]]; then
        delegate -Plocalhost:9129 SERVER=http SOCKS=127.0.0.1:9128 ADMIN="baldor@aleph.engineering" RELAY=proxy PREMIT="*:*:localhost.localdomain"
        echo "HTTP proxy enabled!"
else
        echo "HTTP proxy already enabled."
fi
