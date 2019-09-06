#! /usr/bin/env bash

function loc(){
	local utility=$(which $1)

	if [ -z "${utility}" ] ; then 
		echo "Error: Cannot reach the '$1' utility" 1>&2
		exit 1
	fi

	echo ${utility}
}

ipt=$(loc ip)
echo "found $ipt $?"