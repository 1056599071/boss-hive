#!/bin/bash
# 埋点统计
ip="10.110.94.162"
port="3829"
username="bosstdy_w"
password="4f0aedbb8955ce8"
database="bosstdy"
table="hook_stat_test"
mysqlConnection="mysql -h$ip -P$port -u$username -p$password $database"

jdbcUrl="jdbc:mysql://$ip:$port/$database?useUnicode=true&amp;amp;characterEncoding=UTF-8"
tmpTablePath="/user/hive/warehouse/temp.db/hook_stat_day"

yesterday=`date -d "1 day ago" +"%Y%m%d"`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
today=`date -d "+1 day ${yesterday}" +"%Y%m%d"`

#美国与中国时差
hour=13

dateCondition="((dt = '${yesterday}' and hour >= '${hour}') or (dt = '${today}' and hour < '${hour}'))"
dateCondition="TSConvertPSTTime(dt,hour,'PST','GMT+8') >= ${yesterday} and TSConvertPSTTime(dt,hour,'PST','GMT+8') < ${today}"
splitParams="CONCAT_WS('&&', split(props, '&&')[1], split(props, '&&')[2], split(props, '&&')[3], split(props, '&&')[4])"

echo "正在导入${yesterday}的埋点PV和UV数据" 

#查询页面PC端数据	页面M站数据	收银台各按钮埋点点击数据(包括PC端和M站) 上报埋点例如props="bussiness_id=1104&&page=uspay&&button_name=payment&&isreturn=0&&type=click" 第一个参数是业务参数 取后四个参数拼接的字符串为key
hive -e"
add jar /letv/release/fbr_dailycomputing/comm_tool/fbrudf-1.0-jar-with-dependencies.jar;
create temporary function TSConvertPSTTime as 'com.bigdata.roi.hive.udf.TSConvertPSTTime';
use temp;
create table hook_stat_day as SELECT ${yesterday}, count(1), count(distinct session_id), 'PcCashier' FROM dwb.dwb_megatron_pv_hour WHERE $dateCondition and cur_url = 'https://ipay.le.com/pcapi/showcashier';
insert into hook_stat_day SELECT ${yesterday}, count(1), count(distinct session_id), 'MSiteCashier' FROM dwb.dwb_megatron_pv_hour WHERE $dateCondition and cur_url = 'https://ipay.le.com/wap/showcashier';
"
#删除mysql库中相应数据 避免重复
$mysqlConnection -e "delete from $table where date = '${yesterday}'";
#导入数据到hook_stat
sqoop-export --connect $jdbcUrl --username $username --password $password --table $table --export-dir $tmpTablePath --update-mode allowinsert --input-fields-terminated-by '\001';
echo "数据导入完成"


