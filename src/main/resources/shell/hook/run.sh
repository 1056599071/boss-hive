#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#cd tbl_action_hour
#./query_hook.sh $1
#./import_hook.sh $1

cd $BASEDIR
cd dwb_megatron_action_hour
./query_hook.sh $1
./import_hook.sh $1

cd $BASEDIR
cd sum_user_act_day 
./query_hook.sh $1
./import_hook.sh $1

cd $BASEDIR
cd dwd_flow_log_pv_action_day
./query_hook.sh $1
./import_hook.sh $1

cd $BASEDIR
cd dwb_megatron_pv_hour
./query_hook.sh $1
./import_hook.sh $1
