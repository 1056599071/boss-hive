#!/bin/bash
#该脚本用来导入134中的le_card_record到hive中
source ~/.bashrc
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y-%m-%d"`
if [ $# -eq 1 ]; then
	yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y-%m-%d"`

log_path=./logs/le_card_record_${yesterday}.log

echo "开始导入${yesterday}~${today}日的数据到hive中" > $log_path

db_ip=10.110.94.162    #源数据库IP
db_port=3829            #源数据库端口 
db_user=bosstdy_w       #源数据库用户名
db_pass=4f0aedbb8955ce8 #源数据库密码
db_name=bosstdy         #源数据库名称

file=`pwd`/data/le_card_record_${yesterday//-/}.csv

#从mysql查询结果导入到文件中
mysql -N --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "SELECT batch,result,left(activedate,10) as activedate,right(activedate,8) as activetime,terminal,cardnumber,cardtype,userid,username,chargenumber,chargetype,chargeway,point,ip,meal,paytype,corderid,source,productname,amount,device from le_card_record where activedate>='${yesterday}' and activedate<'${today}'" > ${file}

echo "从数据库查询数据结束，文件名为${file}" >> $log_path

#将文件导入hive表中，覆盖存在的分区
hive -e "LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.le_card_record PARTITION (dt='${yesterday//-/}')"

echo "导入${file}到hive完成" >> $log_path

