#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

grep -v % ./data/mobile_pv_uv_name.$yesterday | awk -F, '{if(length($6)<10 && $2>5) print "'$yesterday'"","$0}' > ./data/mobile_pv_uv_name_fragid.$yesterday


grep -v http ./data/mobile_pv_uv_fragid.$yesterday | awk -F, '{if($2>5) print "'$yesterday'"","$0}' >> ./data/mobile_pv_uv_name_fragid.$yesterday



grep -v % ./data/mobile_order_name.$yesterday | awk -F, '{if(length($5)<10) print "'$yesterday'"","$0}' > ./data/mobile_order_name_fragid.$yesterday

grep -v http ./data/mobile_order_fragid.$yesterday |awk -F, '{print  "'$yesterday'"","$0}'  >> ./data/mobile_order_name_fragid.$yesterday
