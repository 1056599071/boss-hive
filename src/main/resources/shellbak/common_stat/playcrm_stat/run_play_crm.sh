#! /bin/sh
#该脚本用来循环导入指定日期范围内的体育会员数据
#export JAVA_HOME=/data/web/softs/jdk1.6.0_41
#export PATH=$JAVA_HOME/bin:$PATH
#export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

date=`date -d "+0 day $1" +%Y-%m-%d`
enddate=`date -d "+0 day $2" +%Y-%m-%d`

while [[ $date < $enddate  ]]
do
echo "正在同步${date}日的影片分成数据"
sh ./playCRM.sh ${date}
date=`date -d "+1 day $date" +%Y-%m-%d`
done
