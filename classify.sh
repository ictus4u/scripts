#!/usr/bin/env bash
IFS=$'\n'
declare -a files=()
declare -a prefixes=()
idx=0
for file in $(find $1 -type f|sort); do
	files[$idx]=$file
	((idx++))
done
for i in $(seq 0 $idx); do
	j=0 k=4 count=0
	while : ; do
		prefix=${files[0]:$j:$k}
		last_count=$count
		count=$(printf "%s\n" "${files[@]}" | grep -c "^$prefix")
		if [ ! -z $last_count ] && [ $count -ne $last_count ]; then
			prefixes+=$prefix
		fi
		((k++))
		[[ $count > 1 ]] || break
	done
done
printf "%s\n" "${prefixes[@]}" | sort --unique > prefixes.txt
unset IFS
