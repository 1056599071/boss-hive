#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "正在合并第一个文件"

awk -F"," 'NR==FNR && $7==1 && length($5)<15{a[$2$3$4$5$6]=$1","$7","$9;}NR!=FNR && a[$3$4$5$6$7]{print "'$yesterday'"","a[$3$4$5$6$7]","$1","$2","$3","$4","$5","$6","$7","$8}'  ./data/mobile_order_name.$yesterday ./data/mobile_pv_uv_name.$yesterday | grep -v % > ./data/mobile_order_name_result.$yesterday

awk -F"," 'NR==FNR && $7==0 && length($5)<15{a[$2$3$4$5$6]=$1","$7","$9;}NR!=FNR && a[$3$4$5$6$7]{print "'$yesterday'"","a[$3$4$5$6$7]","$1","$2","$3","$4","$5","$6","$7","$8}'  ./data/mobile_order_name.$yesterday ./data/mobile_pv_uv_name.$yesterday | grep -v %  >> ./data/mobile_order_name_result.$yesterday

echo "正在合并第二个文件"

awk -F"," 'NR==FNR && $7==1 {a[$2$3$4$5$6]=$1","$7","$9;}NR!=FNR && a[$3$4$5$6$7]{print "'$yesterday'"","a[$3$4$5$6$7]","$1","$2","$3","$4","$5","$6","$7","$8}'  ./data/mobile_order_fragid.$yesterday ./data/mobile_pv_uv_fragid.$yesterday | grep -v http > ./data/mobile_order_fragid_result.$yesterday


awk -F"," 'NR==FNR && $7==0 {a[$2$3$4$5$6]=$1","$7","$9;}NR!=FNR && a[$3$4$5$6$7]{print "'$yesterday'"","a[$3$4$5$6$7]","$1","$2","$3","$4","$5","$6","$7","$8}'  ./data/mobile_order_fragid.$yesterday ./data/mobile_pv_uv_fragid.$yesterday | grep -v http >> ./data/mobile_order_fragid_result.$yesterday
