#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
CLASSPATH=$CLASSPATH:./config/
#classpath再次是lib目录下面的所有jar包
for f in `find ./lib -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done


JAVA_BIN=java

OPT="-Xms2048m -Xmx2048m  -cp $CLASSPATH "
$JAVA_BIN $OPT com.letv.boss.main.Main -file stat-sql-boss-order.xml $1 $2 $3 $4
