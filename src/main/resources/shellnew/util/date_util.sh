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
        exit 1
    fi
    date=`date -d "+$2 days $1" +%Y%m%d`
    echo ${date}
}