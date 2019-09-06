#! /usr/bin/env bash

ssh=$(which ssh)
ssh_server='root@fjfj.pl'

remote="${ssh} -A ${ssh_server} --"

$remote sudo cat /etc/openvpn/ipp.txt | less

read -p"User [$USER]: " user
if [ -z ${user} ]; then
	user=$USER
fi
echo
read -p"Host [$HOSTNAME]: " host
if [ -z ${host} ]; then
	host=$HOSTNAME
fi

# read password twice
echo
read -sp"Password: " password
echo 
read -sp"Password (again): " password2
# check if passwords match and if not ask again
while [ "$password" != "$password2" ];
do
    echo 
    echo "Please try again"
    read -sp"Password: " password
    echo
    read -sp"Password (again): " password2
done

echo
read -p"Ip: " ip

#$remote << EOSSH
cat << EOSSH
echo "${user}-${host},${ip}" | sudo tee -a "/etc/openvpn/ipp.txt"
echo "ifconfig-push ${ip} 255.255.255.0" | sudo tee "/etc/openvpn/ccd/${user}-${host}"
#hash=$(python -c "import crypt; print crypt.crypt('${password}',crypt.mksalt(crypt.METHOD_SHA512))")
hash=$(python -c "import hashlib; import base64; h=hashlib.sha512(); h.update('foobar'); print base64.b64encode(h.digest())")
echo "${user}-${host}:${hash}" | sudo tee -a "/etc/openvpn/passwd"
EOSSH
