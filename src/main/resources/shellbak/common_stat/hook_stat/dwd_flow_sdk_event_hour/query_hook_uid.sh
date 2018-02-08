#!/bin/sh
#source ~/.bashrc #很重要,不然hive指令不执行

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#分隔符
yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi

echo "正在导入${yesterday}的埋点PV和UV数据"

condition="and app_name='CNLePaySDK-EUITV' and props['launchType']=1"
 
hive -e "
set hive.groupby.skewindata=true;
set hive.jobname.length=10;
add jar /home/zhaochunlong/boss_stat/common_stat/hook_stat/boss-hive-1.0-SNAPSHOT.jar;
create temporary function decodeUid as 'com.letv.boss.stat.hive.UidDecodeUDF';
select props['uid'], decodeUid(props['uid']), count(1) from dwd.dwd_flow_sdk_event_hour where dt = '${yesterday}' and app_name='CNLePaySDK-EUITV' and props['launchType']=1 group by props['uid'], decodeUid(props['uid'])
" > ./uid_.${yesterday}
