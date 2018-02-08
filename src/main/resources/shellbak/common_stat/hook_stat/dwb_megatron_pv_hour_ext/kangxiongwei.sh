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
hive -e "select * from 
(select distinct uid  from dwb.dwb_megatron_pv_hour
where dt = '${yesterday}' and prod = 'vipCashier' and country = 'cn' and platform = '0' and (cur_url like '%zhifu.le.com/tobuy/pro%' or cur_url like '%zhifu.le.com/tobuy/regular%')) t1
join
(select userid, neworxufei, money from dm_boss.t_new_order_4_data where dt='${yesterday}' and status='1' and terminal='112' and orderpaytype in ('0', '2') and viptype!='-1' and ordertype not in (0,1,1001)) t2
on t1.uid = t2.userid" > ./query_hook_data2.${yesterday}
