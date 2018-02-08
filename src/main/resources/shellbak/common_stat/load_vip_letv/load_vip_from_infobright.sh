#!/bin/bash
#创建日期：2017-08-18
#创建者：zhenghao
#该脚本用来导入infobright库中的T_NEW_ORDER_4_DATA到hive中
#bosstdy库中的同名表为临时数据，老数据没有，因此导入更早数据到hive中时，使用此脚本


source ~/.bashrc
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y-%m-%d"`
if [ $# -eq 1 ]; then
	yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y-%m-%d"`

echo "开始导入${yesterday}~${today}日的数据到hive中"

db_ip=10.110.154.80      #源数据库IP
db_port=3307             #源数据库端口 
db_user=infobright       #源数据库用户名
db_pass=infobright       #源数据库密码
db_name=boss_stat          #源数据库名称

file=`pwd`/data/T_NEW_ORDER_4_DATA_${yesterday//-/}.csv

EXPORT_SQL="SELECT DISTINCT
    orderid,
    money,
    status,
    createtime,
    canceltime,
    ordertype,
    aid,
    orderfrom,
    aid2,
    runningnumber,
    videoid,
    paytype,
    paytime,
    paytime_hour,
    userip,
    pakbuycount,
    payChannel,
    suborderfrom,
    model,
    userid,
    terminal,
    terminal2,
    viptype,
    orderpaytype,
    orderpaytype1,
    neworxufei
FROM
    T_NEW_ORDER_4_DATA
WHERE
    paytime >= '${yesterday}'
        AND paytime < '${today}'"

#从mysql查询结果导入到文件中
mysql -N --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "${EXPORT_SQL}" > ${file}

#将文本中\t替换为,号
sed -i 's/\t/,/g' ${file}

echo "从数据库查询数据结束，文件名为${file}"

#将文件导入hive表中，覆盖存在的分区
hive -e "LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.t_new_order_4_data PARTITION (dt='${yesterday//-/}')"

echo "导入${file}到hive完成"

