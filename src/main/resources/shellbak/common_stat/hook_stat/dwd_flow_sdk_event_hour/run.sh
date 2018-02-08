#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#sh /home/zhaochunlong/boss-stat/boss-stat-script/shell/push/push_t_mmall_order.sh $1

./query_hook.sh ${1//-/}
./import_hook.sh ${1//-/}

