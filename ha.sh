#!/usr/bin/env bash

## Usage:
## Modify variables bellow and then call it like this:
## $ ENV_KEEPALIVE_AUTH_PASSWD=<put your password here> ./ha.sh

## Uncomment and update at will

# ## Raul 
# CLUSTER_MEMBER_ID=1
# CLUSTER_MEMBER_TYPE=MASTER
# CLUSTER_MEMBER_PRIORITY=150
# CLUSTER_IFACE=eth0

# ## Zero server
# CLUSTER_MEMBER_ID=2
# CLUSTER_MEMBER_TYPE=BACKUP
# CLUSTER_MEMBER_PRIORITY=100
# CLUSTER_IFACE=p2p1

# ## One Server
# CLUSTER_MEMBER_ID=3
# CLUSTER_MEMBER_TYPE=BACKUP
# CLUSTER_MEMBER_PRIORITY=99
# CLUSTER_IFACE=eno1

## Baldor laptop
CLUSTER_MEMBER_ID=4
CLUSTER_MEMBER_TYPE=BACKUP
CLUSTER_MEMBER_PRIORITY=101
CLUSTER_IFACE=wlp3s0

## Common cluster config
CLUSTER_IP=10.10.90.1
EMAIL_TO=all@aleph.engineering
EMAIL_FROM=lb${CLUSTER_MEMBER_ID}@aleph.engineering
SMTP_SERVER=localhost
AUTH_TYPE=PASS
AUTH_PASSWD=${ENV_KEEPALIVE_AUTH_PASSWD}

## !!! DO NOT CHANGE AFTER THIS LINE IF NOT ACTUALLY NEEDED !!!

if [ "${CLUSTER_MEMBER_ID}" = "" ]; then
	echo "Please, read the comments, and modify the script variables properly" 1>&2
	exit 1;
fi

if [ "${AUTH_PASSWD}" = "" ]; then
	echo -e "Please, call it like this:\n$ ENV_KEEPALIVE_AUTH_PASSWD=<put your password here> ./ha.sh" 1>&2
	exit 1;
fi

## Install keepalive
sudo apt-get install -y linux-headers-$(uname -r)
sudo apt-get install -y keepalived

## Generate configuration

cat <<EOT | sudo tee /etc/keepalived/keepalived.conf >/dev/null 2>&1
! Configuration File for keepalived

global_defs {
   notification_email {
     ${EMAIL_TO}
   }
   notification_email_from lb${CLUSTER_MEMBER_ID}@aleph.engineeering
   smtp_server ${SMTP_SERVER}
   smtp_connect_timeout 30
}

vrrp_instance VI_1 {
    state ${CLUSTER_MEMBER_TYPE}
    interface ${CLUSTER_IFACE}
    virtual_router_id 101
    priority ${CLUSTER_MEMBER_PRIORITY}
    advert_int 1
    authentication {
        auth_type ${AUTH_TYPE}
        auth_pass ${AUTH_PASSWD}
    }
    virtual_ipaddress {
        ${CLUSTER_IP}
    }
}
EOT

sudo service keepalived restart


## Watch
echo "Keepalived service has been started."
echo -e "\nYou can try bellow commands for test what happend:\n"
echo "$ ip addr show ${CLUSTER_IFACE}"
echo "$ sudo tail -n 40 /var/log/syslog"
