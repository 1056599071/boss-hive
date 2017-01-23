#!/bin/sh
#计算站外渠道流量收入
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`
if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "开始计算${yesterday}日的站外渠道流量"

hive -e "" > ./data/external_channels_income.$yesterday

select '20170118' as dt, n.url, count(distinct n.dvc_id) as pageUv, count(distinct m.userid) as payUv, sum(m.money) as income from
(select userid, money from dm_boss.t_new_order_4_data where dt = '${yesterday}' and status = 1 and orderpaytype = 2 and terminal = 112 and money > 0) m
right join
(select user_id, dvc_id, parse_url(url, 'HOST') as url from dws.dws_flow_play_day where dt = '${yesterday}' and cc = 'cn' and log_type = 'http' and dvc_type = 'pc') n
 on (m.userid = n.user_id) group by n.url;
