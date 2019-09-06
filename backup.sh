#!/usr/bin/env bash

if [[ $1 == "" ]]; then
	echo "Usage: $(basename $0) <backup hd>" 1>&2; exit 1
fi

destHD=$(realpath $1)
hostname=$(uname -n)
destpath=${destHD}/backup/${hostname}
if [[ ! -d "${destpath}" ]]; then
        mkdir -p "${destpath}"
fi

tar=$(which tar)

ignorelist=/var/tmp/ignorelist
if [ ! -f ${ignorelist} ]; then
	wget https://raw.githubusercontent.com/rubo77/rsync-homedir-excludes/master/rsync-homedir-excludes.txt -O ${ignorelist}
fi 
tar_exclude=$(cat ${ignorelist} | grep -v '^#\|^$' | sed 's/History Index \*/History/'| sed 's/\(.*\)/--exclude="\1"/'| xargs)

function compress(){
	src=$(realpath $1)
	if [ -f ${src} ]; then
		src=$(dirname $src)
	fi
	name=$(basename $1)
	dst="${destpath}${src}"
	if [[ ! -d "${dst}" ]]; then
        mkdir -p "${dst}"
	fi
	backup_cmd="tar --listed-incremental='${dst}/snapshot.file' ${tar_exclude} --wildcards --totals -zcf '${dst}/${name}-backup-$(date +%d-%m-%Y).tgz' '${src}'"
	eval ${backup_cmd}
	sync
}

compress /home/
# backup /etc/
# backup /usr/lib/flutter
# backup /usr/lib/android-sdk
