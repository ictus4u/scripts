#!/bin/bash

project=$1

projects_dir=~/projects/
envs_dir=${projects_dir}.envs/
sudo apt-get install -y python3 python3-pip
sudo apt-get install build-essential libssl-dev libffi-dev python-dev
sudo apt-get install python3-venv
if [[ ! -d ${envs_dir} ]]; then
	mkdir -p ${envs_dir}
fi

pushd ${envs_dir}

tmpproxy=${all_proxy}
TMPPROXY=${ALL_PROXY}

unset all_proxy
unset http_proxy
unset https_proxy
unset ftp_proxy
unset rsync_proxy
unset ALL_PROXY
unset HTTP_PROXY
unset HTTPS_PROXY
unset FTP_PROXY
unset RSYNC_PROXY

pip install --user --upgrade pip
pip install --user --upgrade pysocks
pip install --user --upgrade 'urllib3[socks]'
pip install --user --upgrade requests[socks]

#export all_proxy="socks5h://127.0.0.1:9128"
#export http_proxy="socks5h://127.0.0.1:9128"
#export https_proxy="socks5h://127.0.0.1:9128"
#export ftp_proxy="socks5h://127.0.0.1:9128"
#export rsync_proxy="socks5h://127.0.0.1:9128"
#export ALL_PROXY="socks5h://127.0.0.1:9128"
#export HTTP_PROXY="socks5h://127.0.0.1:9128"
#export HTTPS_PROXY="socks5h://127.0.0.1:9128"
#export FTP_PROXY="socks5h://127.0.0.1:9128"
#export RSYNC_PROXY="socks5h://127.0.0.1:9128"

python3 -m venv ${envs_dir}${project}

source ${envs_dir}${project}/bin/activate
# Distribution archives generation
pip install --user --upgrade setuptools wheel

# python3 setup.py sdist bdist_wheel

# Distribution archives uploading
pip install --user --upgrade twine

#twine upload --repository-url https://test.pypi.org/legacy/ dist/*

#pip install Flask twilio
pip install --user --upgrade flask flask-jsonpify flask-sqlalchemy flask-restful twilio

pip freeze > requirements.txt

#deactivate

popd
