#!/bin/sh
timeStart=`date -d "2010-10-18 00:00:00" +%s`
echo $timeStart
hour=3600
timeDiff=13
distance=`expr $hour \* $timeDiff`
echo $distance
time_start=`expr $timeStart \* 1000`
echo $time_start
echo $timeStart


dd=./test
if [ -d "$dd" ]
then
echo "exist"
else
echo "no exist"
mkdir -p $dd
fi


bossStatIp="10.212.23.235"
bossStatUser=big_data_r
bossStatPassword=NTg5ZTdlNGIzNDM
bossStatDatebase=boss_stat
 
BASEDIR=`dirname $0`
cd $BASEDIR
 
#存放hive查询数据的文件目录
dataDir=./data
if [ ! -d $dataDir ] 
then
mkdir -p $dataDir
fi
 
#美国与中国时差
hour=13
 
yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
today=`date -d "+1 day ${yesterday}" +"%Y%m%d"`
 
dateCondition="((dt = '${yesterday}' and hour >= '${hour}') or (dt = '${today}' and hour < '${hour}'))"
splitParams="CONCAT_WS('&&', split(props, '&&')[1], split(props, '&&')[2], split(props, '&&')[3], split(props, '&&')[4])"
echo "正在导入${yesterday}的埋点PV和UV数据"


