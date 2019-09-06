#!/usr/bin/env bash



function norm(){
	local name

	mypath="."
	if [ "$1" != "" ]; then
		mypath=$1
	fi
	pushd $mypath >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		exit 1
	fi

	for name in  $(ls); do
		if [ $name = "." ] || [ $name = ".." ]; then
			continue
		fi

		if [ -d $mypath/$name ]; then
			norm $mypath/$name
		fi

		new=$(echo $name| sed 's/[^0-9A-Za-z_ .-]//g' | sed 's/^ *\| *$//')
		if [ "$name" != "$new" ]; then
			echo "- $name"
			echo "+ $new"
		fi
	done

	popd >/dev/null 2>&1
}

IFS=$'\n'
norm $1
unset IFS
