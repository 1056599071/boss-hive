#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
CLASSPATH=$CLASSPATH:../../common/config/
#classpath再次是lib目录下面的所有jar包
for f in `find ../../common/lib/ -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "开始计算${yesterday}日的流量数据"

JAVA_BIN=java

OPT="-Xms512m -Xmx512m -cp $CLASSPATH "

sh ./t_letv_cashier_flow.sh $yesterday

$JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file t_letv_cashier_flow.xml -sdate $yesterday

sh ./t_letv_cashier_result.sh $yesterday

$JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file t_letv_cashier_result.xml -sdate $yesterday
