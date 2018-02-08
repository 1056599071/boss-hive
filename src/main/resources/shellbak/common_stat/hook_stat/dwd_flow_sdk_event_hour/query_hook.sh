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
select ${yesterday}, tt1.widget_id, tt1.event_id, tt1.cps_no, tt1.pv, tt1.uv, coalesce(tt2.pay_pv, 0), coalesce(tt2.pay_uv, 0), coalesce(tt2.income, 0) from 
(select widget_id, event_id, props['CPS_no'] as cps_no, count(1) as pv, count(distinct props['uid']) as uv from dwd.dwd_flow_sdk_event_hour
where dt = '${yesterday}' $condition group by widget_id, event_id, props['CPS_no']) tt1 
left join (
select t1.widget_id, t1.event_id, t1.cps_no, count(1) as pay_pv, count(distinct t2.user_id) as pay_uv, coalesce(sum(t2.pay_price), 0) as income from 
(select distinct widget_id, event_id, props['CPS_no'] as cps_no, decodeUid(props['uid']) as uid from dwd.dwd_flow_sdk_event_hour where dt = '${yesterday}' $condition) t1
inner join
(select cps_id, user_id, pay_price from dm_boss.t_mmall_order where dt='${yesterday}' and status>0 and pay_channel > 0 and (package_name not in ('com.le.zhixin.h5') or package_name is null)) t2
on t1.uid = t2.user_id and t1.cps_no = t2.cps_id group by t1.widget_id, t1.event_id, t1.cps_no
) tt2 on tt1.widget_id = tt2.widget_id and tt1.event_id = tt2.event_id and tt1.cps_no = tt2.cps_no
" > ./data/query_hook_data.${yesterday}
