#!/usr/bin/env bash
#日期工具类

#获取昨天日期，yyyyMMdd格式
function getYesterday {
    yesterday=`date -d "1 days ago" +%Y%m%d`
    echo ${yesterday}
}

#给指定日期增加指定天数，返回yyyyMMdd格式日期
function addDays {
    if [ $# != 2 ]; then
        echo "必须输入两个参数，第一个为日期，第二个为增加多少天"
        return 1
    fi
    date=`date -d "+$2 days $1" +%Y%m%d`
    echo ${date}
}

#执行某段时间范围内的指定脚本，日期格式yyyyMMdd
function execute {
    if [ $# -ne 3 ]; then
        echo "必须传入三个参数[startDate,endDate,shellFile]"
        return 1
    fi
    date=`date -d "+0 day $1" +"%Y-%m-%d"`
    while [[ ${date} < $2 ]];
    do
        echo "开始执行${date}日的脚本"
        sh $3 ${date}
        date=`date -d "+1 day ${date}" +"%Y-%m-%d"`
    done
    return 0
}

execute $1 $2 $3