#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

hive -e "insert overwrite table dm_boss.tbl_play_record_all partition(dt='$yesterday') select distinct uid,pid,deviceid,product from dm_boss.tbl_play_record_day where dt<='$yesterday' and uid!='-' and pid!='-'"

#hive -e "use data_raw;ALTER TABLE tbl_play_record_all drop partition(dt='$yesterday')"
