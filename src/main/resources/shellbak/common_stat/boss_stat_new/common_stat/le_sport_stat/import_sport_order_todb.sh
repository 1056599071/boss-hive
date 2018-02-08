#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

sdate=`date +"%Y-%m-%d" -d "-1 days"`
edate=`date +"%Y-%m-%d"`
if [ "$#" -eq 2 ]; then
  sdate=$1
  edate=$2
fi
echo "统计的时间范围是：$sdate - $edate"

#classpath优先当前目录
CLASSPATH=$CLASSPATH:../../common/config
#classpath再次是lib目录下面的所有jar包
for f in `find ../../common/lib -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done


JAVA_BIN=java

OPT="-Xms512m -Xmx512m  -cp $CLASSPATH "
$JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file stat-sql-sport-order.xml -sdate $sdate -edate $edate
