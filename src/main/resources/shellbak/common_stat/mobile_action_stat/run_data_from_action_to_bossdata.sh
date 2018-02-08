#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

hive -e "
insert overwrite table dm_boss.boss_action_day partition(dt='${yesterday}',product='0')
select ip,time,country,area,province,city,p1,p2,p3,act_code,str_to_map(act_property,'&','='),uid,deviceid,ilu
  from data_raw.tbl_action_hour
 where dt = '${yesterday}'
   and product = '0' and act_code in('0','17','19','25') and deviceid!='-'
   and act_property like '%pageid=%'"
