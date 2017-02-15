#!/bin/sh
#计算外部渠道带来收入 PC端

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

today=`date +"%Y%m%d"`

if [ "$#" -eq 2 ]; then
  yesterday=$1
  today=$2
fi


hive -e "select t_play.dt,t_play.ref,count(distinct COALESCE(t_order.userid,0))-1,count(distinct t_play.letv_cookie),sum(COALESCE(t_order.money,0)) from
(select userid,money,dt from dm_boss.t_new_order_4_data where dt>='${yesterday}' and dt<'${today}' and  status='1' and money!='0' and terminal='112' and orderpaytype='2')t_order
right outer join
(select distinct t2.dt,t1.uid,t2.ref,t2.letv_cookie from 
(select uid,dt,letv_cookie from data_raw.tbl_pv_hour where dt>='${yesterday}' and dt<'${today}' and product='1' and uid !='-' and uid!='' and letv_cookie!='-' and letv_cookie!='0' and letv_cookie!='' and ilu='0')t1
right outer join
(select uid,dt,letv_cookie,parse_url(ref,'HOST') as ref
    from dm_boss.tbl_play_day_boss where dt>='${yesterday}' and dt<'${today}' and p1='1' and property like '%pay=0%' and letv_cookie!='-' and letv_cookie!='0' and letv_cookie!='')t2
on(t1.letv_cookie=t2.letv_cookie and t1.dt=t2.dt))t_play
on(t_order.userid=t_play.uid and t_order.dt=t_play.dt) 
group by t_play.dt,t_play.ref" > ./data/external_channels_income.$yesterday
