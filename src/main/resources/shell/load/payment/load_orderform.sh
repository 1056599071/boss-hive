#!/bin/bash
#创建日期：2016-10-26
#创建者：亢雄伟
#该脚本用来导入134中的t_letv_vip_payment_all到hive中
source ~/.bashrc
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y-%m-%d"`
if [ $# -eq 1 ]; then
	yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y-%m-%d"`

echo "开始导入${yesterday}~${today}日的数据到hive中"

#db_ip=117.121.54.134    #源数据库IP
#db_port=3829            #源数据库端口 
#db_user=bosstdy_w       #源数据库用户名
#db_pass=4f0aedbb8955ce8 #源数据库密码
#db_name=bosstdy         #源数据库名称
db_ip=10.183.196.100
db_port=3306
db_user=boss_stat_w
db_pass=6b9b3#2137F
db_name=boss_stat


file=`pwd`/data/t_letv_vip_payment_all_${yesterday//-/}.txt

#从mysql查询结果导入到文件中
mysql -N --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "SELECT ordernumber, orderid, user_id, user_name, ip, paymentdate, pay_position, paytype, signnumber, status, is_renew, product_id, product_name, pid, vid, deviceid, companyid, terminal, device, svip, chargetype, lepayorderno, activity_id, phone, p1, p2, p3, version FROM t_letv_vip_payment_all t WHERE t.paymentdate >= '${yesterday}' AND t.paymentdate < '${today}'" > ${file}

echo "从数据库查询数据结束，文件名为${file}"

#将文件导入hive表中，覆盖存在的分区
hive -e "LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.t_letv_vip_payment_all PARTITION (dt='${yesterday//-/}')"

echo "导入${file}到hive完成"

