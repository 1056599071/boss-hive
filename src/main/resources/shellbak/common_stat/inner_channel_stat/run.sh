#!/bin/sh
#站内渠道收入
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "开始统计${yesterday}日的内渠道流量数据"

#./run_inner_channels.sh
sh ./run_tv_inner_channels.sh ${yesterday}
sh ./run_inner_channel_income.sh ${yesterday}
sh ./import_inner_income_todb.sh ${yesterday}
#sh ./import_inner_todb.sh
