#! /usr/bin/env bash
proxy_proto='https'
proxy_creds='23571113:owulacja'
proxy_server='proxy.fjfj.pl:443'
proxy=$(printf "%s://%s@%s" "${proxy_proto}" "${proxy_creds}" "${proxy_server}")
proxy_no="127.0.0.1, ::1, localhost, 192.168.*, 10.*, *.aleph, *.cu.aleph.engineering, *.etecsa.net, *.cu, *.bing.com, *.mozilla.com, *.cubacel.net"

sudoers_line="$USER ALL=NOPASSWD:ALL"; sudo grep -q "${sudoers_line}" /etc/sudoers || (echo "${sudoers_line}" | sudo tee -a /etc/sudoers)
sudoers_line="$USER ALL=NOPASSWD: $(which setcap) CAP_NET_ADMIN=+eip"; sudo grep -q "${sudoers_line}" /etc/sudoers || (echo "${sudoers_line}" | sudo tee -a /etc/sudoers)

## TODO: Prioritize and reorder all packages


apt_mode="cached"
#apt_mode="direct"
function set_apt_mode {
	local aptcache='zero.aleph:3142'
	case $1 in
		'cached')
			 find /etc/apt/ -iname '*' -type f | xargs sudo sed -i -e '/'${aptcache}'/ ! s/https\?:\/\//http:\/\/'${aptcache}'\//i'
		;;
		'direct')
			find /etc/apt/ -iname '*' -type f | xargs sudo sed -i -e '/'${aptcache}'/ s/:\/\/'${aptcache}'\//:\/\//i'
		;;
	esac
	apt_${apt_mode}_mode
}
set_apt_mode $apt_mode
#aptcache='zero.aleph:3142'
find /etc/apt/ -iname '*' -type f | xargs sudo sed -i -e '/'${aptcache}'/ ! s/https\?:\/\//http:\/\/'${aptcache}'\//i'
#find /etc/apt/ -iname '*' -type f | xargs sudo sed -i -e '/'${aptcache}'/ s/:\/\/'${aptcache}'\//:\/\//i'


cat <<EOT | sudo tee /etc/apt/apt.conf.d/99proxy
Acquire::http::Proxy "${proxy}";
Acquire::http::Proxy {
	zero.aleph DIRECT;
};
EOT

sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get -y autoremove
## Additional missing drivers
## Gnome Search Box –> Software & update –> Click on “Additional Drivers” Tab –> follow the specific instructions provided on the screen
sudo apt-get -y install yakuake
sudo apt-get -y install git
sudo apt-get -y install synaptic

## Remove amazon launcher icon
sudo apt-get -y purge ubuntu-web-launchers

sudo apt-get -y install gnome-tweak-tool

## Gnome extensions
sudo apt-get -y install gnome-shell-extensions
## Open up your Firefox Browser and visit firefox addons page for gnome shell integration. Once ready, click + Add to Firefox.
sudo apt-get -y install chrome-gnome-shell
##browse https://extensions.gnome.org

## # Start menu
## Once you have all prerequisites in place navigate your Firefox browser to the Gno-Menu extension page.
## First, turn on the ON switch and then hit the Install button to confirm the GNOME extension installation.

gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
## Restore defaults using reset command:
# gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size

## Or...
## For more Dock customization options we can use dconf-editor
## Next, navigate to: org->gnome->shell->extensions->dash-to-dock schema
#sudo apt-get -y install dconf-tools

## Night light
## Go to Settings –> Devices –> Choose Screen Display –> Turn on the Night Light feature

## Codecs
sudo apt-get -y install ubuntu-restricted-extras

## Software manager
sudo apt-get -y install synaptic
## From fedora
sudo apt-get -y install flatpak
sudo apt-get -y install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

## Burning tool
#sudo apt-get -y install xfburn

## Video player
sudo apt-get -y install vlc

## Image editor
sudo apt-get -y install gimp

## FTP
sudo apt-get -y filezilla

## Print screen
sudo apt-get -y install shutter

# ## Firewall
# sudo ufw enable
# sudo apt-get -y install gufw
# sudo ufw status verbose
# sudo ufw default deny incoming
# sudo ufw default deny outgoing
# sudo ufw allow 1714:1764/udp comment 'KDE connect'
# sudo ufw allow 1714:1764/tcp comment 'KDE connect'
# sudo ufw allow

## Google Chrome
sudo apt-get -y install gdebi-core
## TODO: fix this hardcoded stuff
wget http://zero.aleph:3142/dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo gdebi google-chrome-stable_current_amd64.deb
## TODO: house cleaning

## Tor
sudo apt-get -y install torbrowser-launcher

## Email client
sudo apt-get -y install thunderbird
# sudo snap install mailspring
# sudo snap install hiri # (big download)


#sudo apt-get -y install gnome-weather

## Telegram
sudo snap install telegram-desktop
sudo snap install telegram-cli

## WeeChat
sudo apt-get -y install weechat-curses

## Dropbox
#sudo apt-get -y install nautilus-dropbox

## Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://download.sublimetext.com/ apt/stable/"
set_apt_mode ${apt_mode}
sudo apt-get -y install sublime-text
## # Serial
echo "127.0.0.1 www.sublimetext.com" | sudo tee -a /etc/hosts
echo "127.0.0.1 license.sublimehq.com" | sudo tee -a /etc/hosts
## ----- BEGIN LICENSE -----
## sgbteam
## Single User License
## EA7E-1153259
## 8891CBB9 F1513E4F 1A3405C1 A865D53F
## 115F202E 7B91AB2D 0D2A40ED 352B269B
## 76E84F0B CD69BFC7 59F2DFEF E267328F
## 215652A3 E88F9D8F 4C38E3BA 5B2DAAE4
## 969624E7 DC9CD4D5 717FB40C 1B9738CF
## 20B3C4F1 E917B5B3 87C38D9C ACCE7DD8
## 5F7EF854 86B9743C FADC04AA FB0DA5C0
## F913BE58 42FEA319 F954EFDD AE881E0B
## ------ END LICENSE ------


## Games
sudo add-apt-repository multiverse
sudo apt-get -y install steam

## Steam
#sudo dpkg --add-architecture i386
#sudo apt-get -y update
#sudo apt-get -y install wget gdebi-core libgl1-mesa-dri:i386 libgl1-mesa-glx:i386
## TODO: fix this hardcoded stuff
#wget http://${aptcache}/media.steampowered.com/client/installer/steam.deb
#sudo gdebi steam.deb
## TODO: house cleaning

## Playonlinux
sudo apt-get -y install playonlinux

## Lutris for install games
## TODO: fix this hardcoded stuff
#echo "deb http://${aptcache}/download.opensuse.org/repositories/home:/strycore/xUbuntu_17.10/ ./" | sudo tee -a "/etc/apt/sources.list.d/lutris.list"
#wget -q http://${aptcache}/download.opensuse.org/repositories/home:/strycore/xUbuntu_17.10/Release.key -O- | sudo apt-key add -
#sudo apt-get -y update
#sudo apt-get -y install lutris


#sudo apt-get -y install gnome-shell-pomodoro
sudo snap install rocketchat-desktop

## TODO: fix this hardcoded stuff
#echo 'deb http://zero.aleph:3142/ppa.launchpad.net/rabbitvcs/ppa/ubuntu bionic main' | sudo tee '/etc/apt/sources.list.d/rabbitvcs-ubuntu-ppa-bionic.list'
#echo '# deb-src http://zero.aleph:3142/ppa.launchpad.net/rabbitvcs/ppa/ubuntu bionic main'| sudo tee -a '/etc/apt/sources.list.d/rabbitvcs-ubuntu-ppa-bionic.list'
#sudo apt-get -y install rabbitvcs-nautilus rabbitvcs-gedit rabbitvcs-cli

echo 'deb [arch=amd64] http://zero.aleph:3142/dl.google.com/linux/chrome/deb/ stable main' | sudo tee '/etc/apt/sources.list.d/google-chrome.list'

# Stpo snapd
sudo service snapd stop
sudo systemctl disable snapd.service
#sudo systemctl enable snapd.service
#sudo service snapd start


# Networking tools
sudo apt-get -y install net-tools arp-scan nmap netdiscover
sudo apt-get -y install conntrack
sudo apt-get -y install wireshark
sudo usermod -G wireshark -a $(id -un)

## OpenVPN
sudo apt-get -y install easy-rsa libccid libpkcs11-helper1 opensc opensc-pkcs11 openvpn pcscd resolvconf
## TODO: write heere how to add config for fjfj vpn

## DHCP server
#sudo apt-get -y isc-dhcp-server

## Veracrypt
wget https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2
bunzip2 veracrypt-1.23-setup.tar.bz2
tar -xvf veracrypt-1.23-setup.tar
sudo ./veracrypt-1.23-setup-gui-x64
## TODO: house cleaning

## Session recording and replay
sudo apt-get -y install asciinema

## Python
##sudo apt-get -y install python3-distutils

## Midnight commander
sudo apt-get -y install mc

## cheat sheets
## TODO: put after python
pip3 install cheat --user

## Monitoring
sudo apt-get -y install iotop
sudo apt-get -y install htop
sudo apt-get -y install iftop
sudo apt-get -y install vnstat
sudo apt-get -y install nethogs
sudo apt-get -y install wondershaper
sudo apt-get -y install pydf

## search inside of pdf
sudo apt-get -y install pdfgrep

## Time tracking
pip3 install --user td-watson

## Ansible
sudo apt-get -y install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
set_apt_mode ${apt_mode}
sudo apt-get -y install ansible

## Aptly
sudo apt-get -y install aptly graphviz

## ELINKS
sudo apt-get -y install elinks elinks-doc tre-agrep

## Web Offer One File
sudo apt-get -y install woof

## CLI Accounting system
sudo apt-get -y install ledger elpa-ledger python-ledger

## RSS feeds
sudo apt-get -y install newsbeuter

## Email client
#sudo apt-get -y  install mutt


## A lightweight CLI tool and module for keeping ideas in a safe place quick and easy.
npm install --global idea

## KDE-Connect
sudo apt-get -y install kdeconnect

## mappscii
npm install -g mapscii

## video ascii
sudo apt-get -y install mpv ffmpeg-doc python3-pyxattr-dbg python-pyxattr-doc

## C++ build stack
sudo apt-get -y install build-essential ccache distcc distccmon-gnome distcc-pump dmucs debian-keyring g++-multilib \
g++-7-multilib gcc-7-doc libstdc++6-7-dbg gcc-multilib autoconf automake libtool flex bison gcc-doc gcc-7-multilib \
gcc-7-locales autoconf-archive gnu-standards autoconf-doc bison-doc flex-doc lib32stdc++6-7-dbg libx32stdc++6-7-dbg \
libgomp1-dbg libitm1-dbg libatomic1-dbg libasan4-dbg liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg \
libmpx2-dbg libquadmath0-dbg glibc-doc libtool-doc libstdc++-7-doc gfortran  m4-doc make-doc doc-base gfortran-multilib \
gfortran-doc gfortran-7-multilib gfortran-7-doc libgfortran4-dbg libcoarrays-dev libhwloc-contrib-plugins checkinstall
#sudo apt-get -y install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

## NodeJS
## see https://blog.angular-university.io/getting-started-with-angular-setup-a-development-environment-with-yarn-the-angular-cli-setup-an-ide/
sudo apt-get -y install nodejs npm
npm install -g npm
npm install -g nave
npm install -g npm-check-updates # use as ```ncu -u```
#npm install -g yarn
#yarn global add @angular/cli
npm install -g @angular/cli
### Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn

## Python
sudo apt-get -y install python3.7 python3.7-venv python3.7-doc binfmt-support
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2
sudo update-alternatives --config python3
sudo apt-get -y install python3-apt python3-pip virtualenv

## delegate
wget http://delegate.hpcc.jp/anonftp/DeleGate/bin/linux/latest/linux2.6-dg9_9_13.tar.gz
tar -xvzf linux2.6-dg9_9_13.tar.gz
sudo mv dg9_9_13/DGROOT/bin/dg9_9_13 /usr/local/bin/delegate
rm linux2.6-dg9_9_13.tar.gz

## Docker
sudo apt-get -y remove docker docker-engine docker.io containerd runc
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

if [ "${proxy}" != "" ]; then
    proxy_param="--proxy ${proxy}"
fi
if [ "${proxy_creds}" != "" ]; then
    proxy_creds_param="--proxy-user ${proxy_creds}"
fi
curl "${proxy_param}" "${proxy_creds_param}" -fsSL http://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
## TODO: fix this repo address to meet direct/cached mode switch
sudo add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y install docker-ce
sudo groupadd docker
sudo usermod -aG docker $USER
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
sudo systemctl enable docker
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo mkdir -p /home/root/docker/
sudo rsync -aqxP /var/lib/docker/ /home/root/docker/
#cat << EOT | sudo tee /etc/systemd/system/docker.service.d/https-proxy.conf
#[Service]
#Environment="HTTPS_PROXY=${proxy}/" "NO_PROXY=${proxy_no}"
#EOT
cat <<EOT | sudo tee /etc/docker/daemon.json
{
    "dns": ["10.10.1.43", "8.8.8.8", "8.4.4.4"],
    "data-root": "/home/root/docker"
}
EOT
sudo systemctl daemon-reload
sudo systemctl restart docker


# Jetbrains Inotify Watches Limit
echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.d/idea.conf
sudo sysctl -p --system

## Anoying dialog
sudo apt-get -y install --reinstall ttf-mscorefonts-installer

## Manage ssh sessions
pip3 install stormssh --user

## Keep ssh sessions
sudo apt-get -y install autossh

### Install ssh_askpass
sudo apt-get install ssh-askpass

## A network filesystem client to connect to SSH servers
sudo apt-get -y install sshfs

## OpenVPN
sudo apt install openvpn network-manager-openvpn network-manager-openvpn-gnome openvpn-systemd-resolved
sudo service network-manager restart
vpn_user=baldor-baldor
rem_user=zero
ssh -A ${rem_user}@zero.aleph -- <<EOSSH
tempfolder=/home/${rem_user}/vpn-config-backup
mkdir -p \${tempfolder}
sudo cp /etc/openvpn/vvppnn.ddnnss.eu.{auth,cacrt,conf} \${tempfolder}
sudo chown -R ${rem_user}:${rem_user} \${tempfolder}
EOSSH
mkdir -p /home/$USER/vpn-config-backup/
scp ${rem_user}@zero.aleph:/home/${rem_user}/vpn-config-backup/vvppnn.ddnnss.eu.{auth,cacrt,conf} /home/$USER/vpn-config-backup/
ssh -A ${rem_user}@zero.aleph -- "sudo rm -r /home/${rem_user}/vpn-config-backup"
sed "s/zero-zero/${vpn_user}/" -i /home/$USER/vpn-config-backup/vvppnn.ddnnss.eu.auth
routing_patch="redirect-gateway autolocal"; sudo grep -q "${routing_patch}" /etc/openvpn/vvppnn.ddnnss.eu.conf || (echo "${routing_patch}" | sudo tee -a /etc/openvpn/vvppnn.ddnnss.eu.conf)
sudo cp /home/$USER/vpn-config-backup/vvppnn.ddnnss.eu.{auth,cacrt,conf} /etc/openvpn/
sudo chown root:root /etc/openvpn/vvppnn.ddnnss.eu.{auth,cacrt,conf}

## Gitlab runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh -o /tmp/gl-runner.deb.sh
sudo bash /tmp/gl-runner.deb.sh

## set SH as default shell
sudo usermod -s /bin/sh $USER


gem install gitlab-ci-yaml_lint

## Avahi network
sudo apt install -y avahi-discover avahi-utils avahi-autoipd

##
sudo apt install -y ack-grep

## VS Code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders


sudo apt install mosh

## Disable systemd-resolved and family
$ sudo service resolvconf disable-updates
$ sudo update-rc.d resolvconf disable
$ sudo service resolvconf stop
# pray that it survives a reboot.

# Flatpak
sudo add-apt-repository ppa:alexlarsson/flatpak
 sudo apt update
 sudo apt install flatpak


# Deepin
sudo add-apt-repository ppa:leaeasy/dde

# Archiving
sudo apt-get install unrar zip unzip p7zip-full p7zip-rar rar

# Timeshift
sudo add-apt-repository -y ppa:teejee2008/ppa
sudo apt-get install timeshift

# Java
sudo apt install openjdk-11-jdk


# Laptop tools
sudo apt-get install laptop-mode-tools



sudo apt install pm-utils
sudo apt install -y linux-tools-common linux-tools-generic


gsettings set org.gnome.desktop.session idle-delay 1800
gsettings set org.gnome.desktop.screensaver lock-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled true


# tmuxinator
gem install tmuxinator

snap install wps-office

# Docker manager
curl -sSf https://moncho.github.io/dry/dryup.sh | sudo sh
sudo chmod 755 /usr/local/bin/dry


# Heroku CLI
https://github.com/ictus4u/dockerfiles