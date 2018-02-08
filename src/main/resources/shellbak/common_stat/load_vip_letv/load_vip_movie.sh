#!/bin/bash
#创建日期：2016-10-26
#创建者：亢雄伟
#该脚本用来导入134中的T_NEW_ORDER_4_DATA到hive中
source ~/.bashrc

#common log support
source ~/shell/common/log4bash.sh

BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y-%m-%d"`
if [ $# -eq 1 ]; then
	yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y-%m-%d"`

log_info "开始导入${yesterday}~${today}日的数据到hive中"

db_ip=10.110.94.162    #源数据库IP
db_port=3829            #源数据库端口 
db_user=bosstdy_w       #源数据库用户名
db_pass=4f0aedbb8955ce8 #源数据库密码
db_name=bosstdy         #源数据库名称

file=`pwd`/data/T_NEW_ORDER_4_DATA_${yesterday//-/}.csv


#从mysql查询结果导入到文件中
mysql -N --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "SELECT distinct orderid,money,status,createtime,canceltime,ordertype,aid,orderfrom,aid2,runningnumber,videoid,paytype,left(paytime,10) as paytime,right(paytime,8) as payHour,userip,pakbuycount,payChannel,suborderfrom,model,userid,terminal,terminal2,viptype,orderpaytype,orderpaytype1,neworxufei from T_NEW_ORDER_4_DATA where paytime>='${yesterday}' and paytime<'${today}'" > ${file}

#将文本中\t替换为,号
sed -i 's/\t/,/g' ${file}

log_info "从数据库查询数据结束，文件名为${file}"

#将文件导入hive表中，覆盖存在的分区
hive -e "LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.t_new_order_4_data PARTITION (dt='${yesterday//-/}')" 2>&1 | log

log_info "导入${file}到hive完成,结果${?}"

hive -e"
insert overwrite table dm_boss.tbl_play_day_boss partition(dt=${yesterday//-/})
 select distinct p1,p2,p3,uid,letv_cookie,deviceid,cid,pid,vid,playtype,property,ref,ilu,zid,liveid,time
 from data_raw.tbl_play_hour where dt='${yesterday//-/}' and (property like '%pay=0%' or property like '%pay=1%')
"
log_info "从data_raw.tbl_play_hour中抽取一部分数据到tbl_play_day_boss中完成"
