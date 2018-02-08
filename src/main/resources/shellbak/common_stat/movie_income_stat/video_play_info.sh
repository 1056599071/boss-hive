#!/usr/bin/env bash

###查询某一天用户付款，但是播放时间在第二天的情况
startDate=`date -d "2 days ago" +"%Y%m%d"`
endDate=`date -d "1 days ago" +"%Y%m%d"`

if [ 1 -eq $# ]; then
    startDate=$1
    startDate=`date -d ${startDate} +%s`
    today_seconds=$[ $startDate+86400 ]
    startDate=`date -d @${startDate} +"%Y%m%d"`
    endDate=`date -d @${today_seconds} +"%Y%m%d"`
fi

echo "查询支付时间$startDate，但播放时间$endDate的用户量" > play_info_${startDate}.log

hive -e "select count(*) from (SELECT userid, money FROM dm_boss.t_new_order_4_data WHERE dt = '${startDate}' AND status = 1
AND money > 0 AND terminal = 112 AND orderpaytype = 2 and paytime like '%${startDate}%') m join
(select * from dm_boss.tbl_play_day_boss where dt = ${endDate} AND p1 = 1 AND property LIKE '%pay=0%' AND uid NOT IN ('-', '')
 AND letv_cookie NOT IN ('-', '0', '') and time like '%${endDate}%') n on (m.userid = n.uid)" >> play_info_${startDate}.log