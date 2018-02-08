#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
CLASSPATH=$CLASSPATH:../common/config/
#classpath再次是lib目录下面的所有jar包
for f in `find /home/membership02/boss_stat/common/lib/ -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

JAVA_BIN=java

OPT="-Xms2048m -Xmx2048m  -cp $CLASSPATH "
$JAVA_BIN $OPT com.letv.boss.main.Main -file stat-sql-error.xml -sdate $yesterday
