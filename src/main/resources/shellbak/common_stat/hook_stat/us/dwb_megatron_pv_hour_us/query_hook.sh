#!/bin/sh
#source ~/.bashrc #很重要,不然hive指令不执行
source ~/.bash_profile;

bossStatIp="10.212.23.235"
bossStatUser=big_data_r
bossStatPassword=NTg5ZTdlNGIzNDM
bossStatDatebase=boss_stat

BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
today=`date -d "+1 day ${yesterday}" +"%Y%m%d"`

#存放hive查询数据的文件目录
dataDir=./data
if [ ! -d $dataDir ]; then
   mkdir -p $dataDir  
fi
dataFile=$dataDir/query_hook_data.${yesterday}

#美国与中国时差
hour=13

dateCondition="((dt = '${yesterday}' and hour >= '${hour}') or (dt = '${today}' and hour < '${hour}'))"
splitParams="CONCAT_WS('&&', split(props, '&&')[1], split(props, '&&')[2], split(props, '&&')[3], split(props, '&&')[4])"

echo "正在导入${yesterday}的埋点PV和UV数据" 
#查询页面PC端数据
hive -e "SELECT ${yesterday}, count(1), count(distinct session_id), 'PcCashier' FROM dwb.dwb_megatron_pv_hour WHERE $dateCondition and cur_url like 'https://uspay.le.com/us/showcashier%'" > $dataFile
#查询页面M站数据
hive -e "SELECT ${yesterday}, count(1), count(distinct session_id), 'MSiteCashier' FROM dwb.dwb_megatron_pv_hour WHERE $dateCondition and cur_url like 'https://uspay.le.com/us/wap/showcashier%'" >> $dataFile
#查询收银台各按钮埋点点击数据(包括PC端和M站) 上报埋点例如props="bussiness_id=1104&&page=uspay&&button_name=payment&&isreturn=0&&type=click" 第一个参数是业务参数 取后四个参数拼接的字符串为key
hive -e "SELECT ${yesterday}, count(1), count(distinct letv_cookie), $splitParams from dwb.dwb_megatron_action_hour where $dateCondition and cur_url like 'https://uspay.le.com/us%' group by $splitParams" >> $dataFile

#导入数据到hook_stat
echo "load data into boss_stat.hook_stat date=${yesterday}";
mysql --default-character-set=utf8  -P 3307 -h $bossStatIp -u $bossStatUser -p$bossStatPassword $bossStatDatebase -s -N --local-infile=1 -e "delete from hook_stat where date='${yesterday}'; load data local infile '$dataFile' IGNORE into table hook_stat fields terminated by '\t' (date, pv, uv, hook);"
echo "数据导入完成"

