#!/bin/sh
# Firewall apps - only allow apps run from "internet" group to run

## At first add internet group, just once
# sudo groupadd internet 

# clear previous rules
sudo iptables -F

# accept packets for internet group
sudo iptables -A OUTPUT -p tcp -m owner --gid-owner internet -j ACCEPT

# also allow local connections
sudo iptables -A OUTPUT -p tcp -d 127.0.0.1/8 -j ACCEPT
sudo iptables -A OUTPUT -p tcp -d 10.0.0.1/8 -j ACCEPT
sudo iptables -A OUTPUT -p tcp -d 192.168.0.1/16 -j ACCEPT

# reject packets for other users
sudo iptables -A OUTPUT -p tcp -j REJECT

### restart service
sudo service iptables save
sudo service iptables restart

# open a shell with internet access
sudo -g internet -s