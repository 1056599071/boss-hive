#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#classpath优先当前目录
#CLASSPATH=$CLASSPATH:./
#classpath再次是lib目录下面的所有jar包
for f in `find ./lib -type f -name "*.jar"`
do
    CLASSPATH=$CLASSPATH:$f
done

sdate=`date -d "1 days ago" +"%Y-%m-%d"`
edate=`date +"%Y-%m-%d"`

if [ "$#" -eq 2 ]; then
  sdate=$1
  edate=$2
fi

echo $sdate $edate

JAVA_BIN=java

#OPT="-Xms2048m -Xmx2048m -cp $cLASSPATH"
OPT="-Xms2048m -Xmx2048m  -cp $CLASSPATH "

$JAVA_BIN $OPT com.letv.boss.zcl.main.DeleteOrderExcutor yuanxian_order_old $sdate $edate

#echo "xxxxxxxx" > log.txt
$JAVA_BIN $OPT com.letv.boss.zcl.main.ExportOrderExcutor yuanxian_order_online1 yuanxian_order_old $sdate $edate
$JAVA_BIN $OPT com.letv.boss.zcl.main.ExportOrderExcutor yuanxian_order_online2 yuanxian_order_old $sdate $edate
$JAVA_BIN $OPT com.letv.boss.zcl.main.ExportOrderExcutor yuanxian_order_online3 yuanxian_order_old $sdate $edate
$JAVA_BIN $OPT com.letv.boss.zcl.main.ExportOrderExcutor yuanxian_order_online4 yuanxian_order_old $sdate $edate
