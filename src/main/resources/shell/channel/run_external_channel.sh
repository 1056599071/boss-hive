#!/bin/sh
#计算外部渠道带来收入 PC端

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 2 ]; then
  yesterday=$1
fi

hive -e "select ${yesterday},t_play.ref,count(distinct COALESCE(t_order.userid,0))-1,count(distinct t_play.letv_cookie),sum(COALESCE(t_order.money,0)) from
(select userid,money from dm_boss.t_new_order_4_data where dt='${yesterday}' and  status='1' and money!='0' and terminal='112' and orderpaytype='2')t_order
right outer join
(select distinct t1.uid,t2.ref,t2.letv_cookie from
(select uid,dt,letv_cookie from data_raw.tbl_pv_hour where dt='${yesterday}' and product='1' and uid !='-' and uid!='' and letv_cookie!='-' and letv_cookie!='0' and letv_cookie!='' and ilu='0')t1
right outer join
(select uid,letv_cookie,parse_url(ref,'HOST') as ref
    from dm_boss.tbl_play_day_boss where dt='${yesterday}' and p1='1' and property like '%pay=0%' and letv_cookie!='-' and letv_cookie!='0' and letv_cookie!='')t2
on(t1.letv_cookie=t2.letv_cookie))t_play
on(t_order.userid=t_play.uid)
group by t_play.ref" > ./data/external_channels_income.$yesterday

#1. 从tbl_pv_hour中抽取PC端合法登录用户的letv_cookie
#2. 从tbl_play_hour中抽取PC端付费播放的用户ID， letv_cookie， parse_url(ref, 'HOST') as ref
#3. 步骤1右连接步骤2，得到所有播放的uid，ref，letv_cookie
#4. 从t_new_order_4_data查询昨日PC端现金支付成功的会员订单，得到userid，money
#5. 根据用户ID步骤4右连接步骤3， 按照ref分组，得到dt、ref、count(distinct userid)、count(distinct letv_cookie)、sum(money)


#优化方案，查询登录用户播放视频的ref，用户量，播放量，会员收入
hive -e "select n.ref, count(distinct m.userid) as payUv, count(distinct n.user_id) as pageUv, sum(m.money) as income from
(select userid, money from dm_boss.t_new_order_4_data
 where dt = '${yesterday}' and money > 0 and status = 1 and orderpaytype = 2 and userid > 0 and terminal = 112) m
right join
(select distinct user_id, parse_url(ref, 'HOST') as ref, cv
 from dws.dws_flow_play_day
 where cc='cn' and dt='${yesterday}' and pf='pc' and dvc_type='pc' and log_type='http'
  and cv > 0 and user_id > 0 and ref != '' and ref != '-' and ref is not null) n
on (m.userid = n.user_id)
group by n.ref;"



