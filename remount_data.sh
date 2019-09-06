#!/usr/bin/env bash

UUID_LIST="96CC0D18CC0CF3F1 346C5A236C59DFE2"

for UUID in ${UUID_LIST}; do
  dev="/dev/disk/by-uuid/${UUID}"

  sudo umount -f ${dev}
  sudo ntfsfix -d ${dev}
done
sudo mount -a
