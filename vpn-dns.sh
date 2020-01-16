#!/usr/bin/env bash

###
### This script scans for last ip assignations in an OpenVPN log file and updates /etc/hosts for DNS emulation
###

HOSTS_FILE=/etc/hosts
HOSTS_BACUP_FILE=/etc/hosts.tpl
SSH_CREDS="-lroot vpn00.aleph.engineering"
VPN_LOGS_FULL_PATH="/root/docker-openvpn/vpnlog.log"
MAIN_SERVER=one.aleph
MAIN_ALIASES="netreg zero bionic ns1 xenial ubuntu-lts lambda ubuntu debian stack nexus nexus-sonatype mcu-server maven devdocs w3schools python pip pypi stuff doc docs public github geminabox hound code redmine wordpress wpae wordpressm mentoring pp pinkfloyd-poker-planning deb grapher gallery jira aria git gogs jenkins sonar docker-registry iot-demo zerowebtoolkit packagist meet ce ubuntu-all monitor sonar7 portainer ce-ui-mocked wpad prometheus zabbix kita ip capitolio capitol raul camera001"

set_alias() {
    sudo sed -i '/ '$1' / s/\([0-9.]*\)\(.*\)/\0\n\1 '$2'.aleph '$2'.cu.aleph.engineering/' ${HOSTS_FILE}
}

start() {
    [ -f "${HOSTS_BACUP_FILE}" ] || sudo cp "${HOSTS_FILE}" "${HOSTS_BACUP_FILE}"
    if [ -f "${HOSTS_BACUP_FILE}" ]; then 
        sudo cp "${HOSTS_BACUP_FILE}" "${HOSTS_FILE}"

        ssh ${SSH_CREDS} -- tail -n99999 "${VPN_LOGS_FULL_PATH}" | grep 'MULTI: Learn:' | sed 's@\(.*\) Learn: \(.*\) -> \([^ :/]*\)/\([^ :]*\).*@\3 \4 \2@g' | awk '{idx[$1]=NR; rev[NR]=$0} END {for (i in idx) printf "%d\t%s\n",idx[i],rev[idx[i]]}' | sort -n | cut -f2- | awk '{print $3" "$1".aleph "$1".cu.aleph.engineering"}' | sudo tee -a "${HOSTS_FILE}"
    fi
    for name in ${MAIN_ALIASES}; do
        set_alias ${MAIN_SERVER} ${name}
    done
}

stop() {
    [ -f "${HOSTS_BACUP_FILE}" ] && sudo cp "${HOSTS_BACUP_FILE}" "${HOSTS_FILE}" && sudo rm "${HOSTS_BACUP_FILE}"
}

case "$1" in
    "start")
        start;;
    "stop")
        stop;;
    *)
        echo "Usage: $(basename $0) [start|stop]"
        exit 1;;
esac