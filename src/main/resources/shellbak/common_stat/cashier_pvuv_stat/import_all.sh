#!/bin/sh
#该脚本用来同步TV活跃度用户数据
#同步周期为2014/01/01-2016/01/30
#之前脚本为执行每一天，只需遍历每一天，调用之前脚本就行

#首先计算两个时间之间所差的总天数
sdate=`date -d "2016-04-24 00:00:00" +%s`
edate=`date -d "2016-05-25 00:00:00" +%s`
days=$[ ($edate-$sdate)/3600/24 ]

#获取每一天的日期
for((i=0;i<$days;i++));do
    today_seconds=$[ $sdate+86400*$i ]
    today=`date -d @${today_seconds} "+%Y%m%d"`
    #调用脚本来导入数据
    #echo "正在导入$today日数据"
    sh ./run.sh $today
done
