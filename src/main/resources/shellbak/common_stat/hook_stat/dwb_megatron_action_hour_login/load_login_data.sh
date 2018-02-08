#!/bin/bash
#该脚本用来导入134中的le_card_record到hive中
source ~/.bashrc
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`
if [ $# -eq 1 ]; then
	yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y%m%d"`

file=`pwd`/data/login_data_${yesterday}.csv

hive -e "
select uid_cookie, letv_cookie, props from dwb.dwb_megatron_action_hour where dt = '${yesterday}' and country = 'cn' and app_name = 'vipCashier'
and props in ('ob_ca=loginPV', 'ch=zhifu&pg=tobuy&bk=goLogin&link=regshow', 'ch=zhifu&pg=tobuy&bk=goLogin&link=reghide', 'ob_ca=login1', 'ob_ca=loginSMS', 'ob_ca=login2', 'ob_ca=signUp1', 'ob_ca=qq', 'ob_ca=weixin', 'ob_ca=sina', 'ob_ca=alipay', 'ob_ca=baidu', 'ob_ca=renren')
" > $file

#将文件导入hive表中，覆盖存在的分区
hive -e "LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.dwb_megatron_action_hour_login PARTITION (dt='${yesterday}')"

echo "导入${file}到hive完成"

