#!/bin/bash
#Filename: remove_duplicate.sh
#Description: Find and duplicate files and keep one sample of each file.

ls -lS --time-style=long-iso | awk 'BEGIN{
  getline; getline;
  name1=$8; size1=$5;
  print "debug1:"name1" "size1
}
{
  name2=$8;
  size2=$5;
  if ( size1==size2 )
  {
    "md5sum "name1 | getline; csum1=$1;
    "md5sum "name2 | getline; csum2=$1;
    if ( csum1 == csum2 )
    {
      print name1; print name2
    }
  }
  size1=size2; name1=name2
}' | sort -u > duplicate_files

cat duplicate_files | xargs -I {} md5sum {} | sort | uniq -w 32 | awk '{ print $2 }' | sort -u > duplicate_sample

echo Removing...

comm duplicate_files  duplicate_sample -2 -3 | tee /dev/stderr | xargs rm

echo Removed duplicated files succesfully.
