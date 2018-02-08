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
 
#埋点统计
hive -e "
set hive.groupby.skewindata=true;
set hive.jobname.length=10;
add jar /home/zhaochunlong/boss_stat/common_stat/hook_stat/boss-hive-1.0-SNAPSHOT.jar;
create temporary function filter_url as 'com.letv.boss.stat.hive.FilterCashierUrlUDF';
select filter_url(cur_url) as ref from dwb.dwb_megatron_pv_hour
where dt = '${yesterday}' and prod = 'vipCashier' and country = 'cn' and platform = '0' and (cur_url like '%zhifu.le.com/tobuy/pro%' or cur_url like '%zhifu.le.com/tobuy/regular%') and filter_url(cur_url) is not null
group by filter_url(cur_url)
" > ./query_hook_data_udf.${yesterday}
