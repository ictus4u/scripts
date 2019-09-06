#! /usr/bin/env bash
proxy_proto='https'
proxy_creds='23571113:owulacja'
proxy_server='proxy.fjfj.pl:443'
proxy=$(printf "%s://%s@%s" "${proxy_proto}" "${proxy_creds}" "${proxy_server}")
proxy_no="127.0.0.1, ::1, localhost, 192.168.*, 10.*, *.aleph, *.cu.aleph.engineering, *.etecsa.net, *.cu, *.bing.com, *.mozilla.com, *.cubacel.net"

## Docker
sudo apt-get -y remove docker docker-engine docker.io containerd runc
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl --proxy "${proxy}" --proxy-user "${proxy_creds}" -fsSL http://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
## TODO: fix this repo address to meet direct/cached mode switch
sudo add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y install docker-ce
sudo groupadd docker
sudo usermod -aG docker $USER
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
sudo systemctl enable docker
sudo mkdir -p /etc/systemd/system/docker.service.d
cat << EOT | sudo tee /etc/systemd/system/docker.service.d/https-proxy.conf
[Service]
Environment="HTTPS_PROXY=${proxy}/" "NO_PROXY=${proxy_no}"
EOT
cat <<EOT | sudo tee /etc/docker/daemon.json
{
    "dns": ["10.10.1.43", "8.8.8.8", "8.8.4.4"]
}
EOT
sudo systemctl daemon-reload
sudo systemctl restart docker