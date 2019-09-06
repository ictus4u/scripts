#!/bin/bash

read -p "link name: " filename
displayName="${filename}"
#read -p "full name: " displayName
read -p "commmand: " execCommand
read -p "icon: " iconPath

output=$(echo ~/.local/share/applications/${filename}.desktop)

cat << EOF > "${output}"
[Desktop Entry]
Exec=${execCommand} %f
GenericName=${displayName}
Icon=${iconPath}
Name=${displayName}
StartupNotify=true
Terminal=false
Type=Application
EOF

chmod 744 "${output}"
ln -sf -t ~/Desktop/ "${output}"
for file in ~/Desktop/*.desktop
do
  gio set "${file}" "metadata::trusted" yes
done
