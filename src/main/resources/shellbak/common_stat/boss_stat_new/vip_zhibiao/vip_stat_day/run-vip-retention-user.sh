#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
CLASSPATH=$CLASSPATH:../../../../common/config
#classpath再次是lib目录下面的所有jar包
for f in `find ../../../../common/lib -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done

#sdate=`date -d '1 days ago' +%Y-%m-%d`
#edate=`date +%Y-%m-%d`



sdate_1=`date -d "1 days ago" +"%Y-%m-%d"`
edate_1=`date +%Y-%m-%d`

if [ "$#" -eq 2 ]; then
  sdate_1=$1
  edate_1=$2
fi

sdate_2=`date -d "${sdate_1} 1 days ago" +"%Y-%m-%d"`
sdate_3=`date -d "${sdate_1} 2 days ago" +"%Y-%m-%d"`
sdate_7=`date -d "${sdate_1} 6 days ago" +"%Y-%m-%d"`
sdate_15=`date -d "${sdate_1} 14 days ago" +"%Y-%m-%d"`
sdate_30=`date -d "${sdate_1} 29 days ago" +"%Y-%m-%d"`

edate_2=`date -d "${edate_1} 1 days ago" +"%Y-%m-%d"`
edate_3=`date -d "${edate_1} 2 days ago" +"%Y-%m-%d"`
edate_7=`date -d "${edate_1} 6 days ago" +"%Y-%m-%d"`
edate_15=`date -d "${edate_1} 14 days ago" +"%Y-%m-%d"`
edate_30=`date -d "${edate_1} 29 days ago" +"%Y-%m-%d"`


#if [ "$#" -eq 4 ]; then
#  sdate_1=$1
#  edate_1=$2
#fi

JAVA_BIN=java

OPT="-Xms512m -Xmx512m  -cp $CLASSPATH "
for sdate in $sdate_2 $sdate_3 $sdate_7 $sdate_15 $sdate_30
#for sdate in  $sdate_7
do
        day=$(((`date +%s -d ${sdate_1}`-`date +%s -d ${sdate}`)/86400))
        edate=`date -d "${edate_1} $day days ago" +"%Y-%m-%d"` 
        echo $sdate $edate #####################################
        $JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file stat-vip-retention_user_day-${day}.xml -sdate $sdate -edate $edate
done

