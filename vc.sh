#!/bin/bash

declare -A tr_list
declare -a a
volumesFolder="/media/baldor/WEGM/SALVAS/Walter/datos/VC/"
mountfolder="/media/baldor/"

#tr1_a=abcdefghijklmnopqrstuvwxyz
#tr1_b=ABCDEFGHIJKLMNOPQRSTUVWXYZ

#tr2_a=abeilostz
#tr2_b=483110572

tr1_a=c
tr1_b=C

tr2_a=lo
tr2_b=10

function newPasswd(){
	declare idx
	declare builtStr
	declare callback
	pwRoot=$1
	idx=$2
	builtStr=$3
	callback=$4

	len=$(( $(echo $pwRoot |wc -c) - 1 ))
	if [[ $idx -lt $len ]] ; then
		declare c
		declare newIdx
		c=${pwRoot:$idx:1}
		newIdx=$(( ++idx ))

		gen=$c
		newBuiltStr=${builtStr}${gen}
		newPasswd "$pwRoot" $newIdx "$newBuiltStr" "$callback"

                gen=$(echo $c | tr ${tr1_a} ${tr1_b})
		if [[ $gen != $c ]]; then
	                newBuiltStr=${builtStr}${gen}
			newPasswd "$pwRoot" $newIdx "$newBuiltStr" "$callback"
		fi

                gen=$(echo $c | tr ${tr2_a} ${tr2_b})
                if [[ $gen != $c ]]; then
                        newBuiltStr=${builtStr}${gen}
                        newPasswd "$pwRoot" $newIdx "$newBuiltStr" "$callback"
                fi
	else
		dst=${mountfolder}$(basename -s.vc $callback)
		if [[ ! -d $dst ]]; then
			sudo mkdir -p $dst
		fi
		echo "$builtStr"
		exec -c veracrypt -t -k "" --non-interactive --protect-hidden=no  -p "$builtStr" "$callback" "$dst" &
	fi
}

#for i in $(ls -b ${volumesFolder=}*.vc); do
#	newPasswd "secret" 0 "" "$i"
#done

newPasswd "secret" 0 "" "/media/baldor/WEGM/SALVAS/Walter/datos/VC/Vol1.vc
