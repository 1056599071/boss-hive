#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
CLASSPATH=$CLASSPATH:../../common/config
#classpath再次是lib目录下面的所有jar包
for f in `find ../../common/lib -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done

sdate=`date -d '1 days ago' +%Y-%m-%d`
edate=`date +%Y-%m-%d`

if [ "$#" -eq 4 ]; then
  sdate=$2
  edate=$4
fi

JAVA_BIN=java

OPT="-Xms512m -Xmx512m  -cp $CLASSPATH "
$JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file stat-sql-boss-order-fail_export.xml $1 $2 $3 $4

sed -i "s/md,//g" data/boss_order_fail_${sdate}.csv 
cp data/boss_order_fail_${sdate}.csv  data/boss_order_fail.${sdate}


$JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file stat-sql-boss-order-fail_import.xml $1 $2 $3 $4
