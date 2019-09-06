#!/bin/bash
#Filename: to3gp
#Desc: Convert video files to 3gp format

src_ext='asf avi mp4 mkv mpeg mpg'

count=0
for ext in ${src_ext}; do
  if [ ${count} = 0 ]; then
    srch_params="-iname \"*.${ext}\""
  else
    srch_params="${srch_params} -o -iname \"*.${ext}\""
  fi
  let count++
done
#srch_cmd="ls -R1 | grep -e '\(g\|3\)$'"
srch_cmd="find ./ \\( ${srch_params} \\) -type f -exec printf \"\\\"%s\\\"\\n\" {} \\; | awk -F \0 '{print \$1}'"
files=$(eval ${srch_cmd})
echo $files #| uniq -z | xargs -0 -d \0 echo
