#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

while read line
do
 awk '{print $2}' >  
done < ./config_data/rec_config_configid_$yesterday.csv 
