#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

awk -F"," 'NR==FNR && $6==1 {a[$2$3$4$5]=$1","$6","$8;}NR!=FNR && a[$3$4$5$6]{print "'$yesterday'"","a[$3$4$5$6]","$1","$2","$3","$4","$5","$6",all,"$7}'  ./data/mobile_order_fragid_all.$yesterday ./data/mobile_pv_uv_fragid_all.$yesterday | grep -v http > ./data/mobile_order_fragid_result_all.$yesterday


awk -F"," 'NR==FNR && $6==0 {a[$2$3$4$5]=$1","$6","$8;}NR!=FNR && a[$3$4$5$6]{print "'$yesterday'"","a[$3$4$5$6]","$1","$2","$3","$4","$5","$6",all,"$7}'  ./data/mobile_order_fragid_all.$yesterday ./data/mobile_pv_uv_fragid_all.$yesterday | grep -v http >> ./data/mobile_order_fragid_result_all.$yesterday
