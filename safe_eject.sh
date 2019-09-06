#! /bin/bash

usbtag=WEGM

# Eject USB drive once buffer transfer has completed

echo "Flushing USB drive buffer"

sync
echo "sync complete"

# Identify the device name for the $usbtag USB drive
usbname=$(lsblk -l | grep ${usbtag} | cut -d' ' -f1)

# Unmount the USB drive
echo "dev: /dev/${usbname}"
if [[ "${usbname}" != "" ]]; then
	sudo udisksctl unmount -b /dev/${usbname}
	echo "unmount complete"

	sleep 2

	# Power off the USB drive

	sudo udisksctl power-off -b /dev/${usbname}
	echo "power off complete"
else
	echo "device not found or already unmounted"
fi

# Script complete

echo "Shell command complete"
#read
