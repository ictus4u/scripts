#!/bin/bash
#Filename: convert_video.sh
#Description: Convert video files from one format to another
#Usage convert_video src_ext dst_ext

case $2 in
  "3gp")
    o="-f 3gp -vcodec h263 -vf scale=176x144 -acodec amr_nb -ar 8000 -ac 1 -b:v 130k -b:a 12.2k -pixel_format yuv420p"
    ;;
  *)
   o=""
    ;;
esac

find . -type f -iname "*.$1" -exec bash -c 'for arg; do if [ -n "$arg" ] && [ "$arg" != "${arg%.*}.$0" ] ; then echo ffmpeg -y -i \"$arg\" $1 \"${arg%.*}.$0\"; fi; done' "$2" "$o" {} +
