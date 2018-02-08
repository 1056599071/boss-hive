#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

hive -e"
select max(t_play.dt),t_play.ref,t_play.pid,count(distinct COALESCE(t_order.userid,0))-1,count(distinct t_play.letv_cookie),sum(COALESCE(t_order.money,0)) from
(select userid,money,dt from dm_boss.t_new_order_4_data where dt='${yesterday}' and  status='1' and money!='0' and terminal='112' and orderpaytype='2')t_order
right outer join
(select distinct t2.dt,t1.uid,t2.ref,t2.letv_cookie,t2.pid from 
(select uid,dt,letv_cookie,pid from data_raw.tbl_pv_hour where dt='${yesterday}' and product='1' and uid !='-' and uid!='' and letv_cookie!='-' and letv_cookie!='0' and letv_cookie!='' and ilu='0')t1
right outer join
(select uid,dt,letv_cookie,parse_url(ref,'HOST') as ref,pid
    from dm_boss.tbl_play_day_boss where dt='${yesterday}' and p1='1' and property like '%pay=0%' and letv_cookie!='-' and letv_cookie!='0' and letv_cookie!='')t2
on(t1.letv_cookie=t2.letv_cookie))t_play
on(t_order.userid=t_play.uid) 
group by t_play.ref,t_play.pid " > ./data/movie_outer_channel.${yesterday}

grep -v NULL ./data/movie_outer_channel.${yesterday} | grep -v letv  > ./data/movie_outer_channel_temp.${yesterday}

python ./getmovienamebypid.sh ${yesterday}

#cat ./data/*.${yesterday} > ./data/page_alldata.${yesterday}

