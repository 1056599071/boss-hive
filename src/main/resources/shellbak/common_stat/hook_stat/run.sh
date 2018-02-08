#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR
echo $BASEDIR
#PC和M站按钮点击上报
#cd tbl_action_hour
#./query_hook.sh $1
#./import_hook.sh $1

#PC和M站按钮点击上报
cd $BASEDIR
cd dwb_megatron_action_hour
./query_hook.sh $1
./import_hook.sh $1
echo $BASEDIR
#Android和Iphone埋点上报
cd $BASEDIR
echo `pwd`
cd sum_user_act_day 
./query_hook.sh $1
./import_hook.sh $1

#TV埋点上报
cd $BASEDIR
cd dwd_flow_log_pv_action_day
./query_hook.sh $1
./import_hook.sh $1

#收银台各自渠道流量统计
cd $BASEDIR
cd dwb_megatron_pv_hour
./query_hook.sh $1
./import_hook.sh $1

#乐购订单渠道流量统计
sh /home/zhaochunlong/boss-stat/boss-stat-script/shell/push/push_t_mmall_order.sh
sh /home/zhaochunlong/boss-stat/boss-stat-script/shell/push/push_t_sku_vendor_mapping.sh
cd $BASEDIR
cd dwd_flow_sdk_event_hour
./query_hook.sh $1
./import_hook.sh $1
