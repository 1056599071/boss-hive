#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
CLASSPATH=$CLASSPATH:../../common/config/
#CLASSPATH=$CLASSPATH:../../common/lib/
#classpath再次是lib目录下面的所有jar包
for f in `find ../../common/lib/ -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

JAVA_BIN=java
OPT="-Xms2048m -Xmx2048m  -cp $CLASSPATH "

for line in `sed '/^[ \t]*$/d' config_data/rec_config_pid_$yesterday.csv |awk -F, '{print "\x27"$1"\x27"",""\x27"$2"\x27"}'`
do
    pid=`echo $line | awk -F"'" '{print $2}'`
    #echo $pid config_data/rec_config_configid_$yesterday.csv
    configid=`grep $pid config_data/rec_config_configid_$yesterday.csv | awk -F',' '{print $2}'`
    #echo $configid 
    sed -i "s/$/&\t${configid}/g" result_data/pid_uid_phone_result.$pid
    $JAVA_BIN $OPT com.celery.stat.main.CeleryMain -file stat_rec_result_todb.xml -pid $pid
done

#$JAVA_BIN $OPT com.letv.boss.main.Main -file stat_rec_config.xml -pid $pid
