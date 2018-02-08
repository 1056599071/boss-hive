#!/bin/bash
# 埋点统计

bossStatIp=10.110.94.162
bossStatPort=3829
bossStatUser=bosstdy_w
bossStatPassword=4f0aedbb8955ce8
bossStatDatebase=bosstdy
tableName=hook_stat_day

jdbcUrl="jdbc:mysql://10.110.94.162:3829/bosstdy?useUnicode=true&amp;amp;characterEncoding=UTF-8"
jdbcUser="bosstdy_w"
jdbcPassword="4f0aedbb8955ce8"
dbTable="hook_stat_day"
output="/user/hive/warehouse/temp.db/hook_stat_day"

yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
today=`date -d "+1 day ${yesterday}" +"%Y%m%d"`

#美国与中国时差
hour=13

dateCondition="((dt = '${yesterday}' and hour >= '${hour}') or (dt = '${today}' and hour < '${hour}'))"
splitParams="CONCAT_WS('&&', split(props, '&&')[1], split(props, '&&')[2], split(props, '&&')[3], split(props, '&&')[4])"

echo "正在导入${yesterday}的埋点PV和UV数据" 
#hive -e"
#use temp;
#create table hook_stat_day as
#SELECT ${yesterday}, count(1), count(distinct session_id), 'PcCashier' FROM dwb.dwb_megatron_pv_hour WHERE $dateCondition and cur_url like 'https://uspay.le.com/us/showcashier%';
#insert into hook_stat_day
#SELECT ${yesterday}, count(1), count(distinct session_id), 'MSiteCashier' FROM dwb.dwb_megatron_pv_hour WHERE $dateCondition and cur_url like 'https://uspay.le.com/us/wap/showcashier%';
#insert into hook_stat_day
#SELECT ${yesterday}, count(1), count(distinct letv_cookie), $splitParams from dwb.dwb_megatron_action_hour where $dateCondition and cur_url like 'https://uspay.le.com/us%' group by $splitParams;
#"

mysql -h $bossStatIp -P $bossStatPort -u $bossStatUser -p$bossStatPassword -e "delete from $tableName where date = ${yesterday}"

echo "mysql delete complete"

#导入数据到hook_stat
echo "load data into boss_stat.hook_stat date=${yesterday}";
sqoop-export --connect $jdbcUrl --username $jdbcUser --password $jdbcPassword --table $dbTable --export-dir $output --update-mode allowinsert --input-fields-terminated-by '\001'
echo "数据导入完成"


