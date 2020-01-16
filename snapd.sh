#!/usr/bin/env bash

sudo systemctl enable snapd.service >/dev/null 2>&1
sudo systemctl enable snapd.socket >/dev/null 2>&1
sudo service snapd start

sudo snap $@

sudo service snapd stop
sudo systemctl disable snapd.socket >/dev/null 2>&1
sudo systemctl disable snapd.service >/dev/null 2>&1
