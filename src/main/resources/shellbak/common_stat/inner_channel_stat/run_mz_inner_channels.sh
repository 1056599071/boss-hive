#!/bin/sh
#计算由播放页带来的付费转化率

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

today=`date +"%Y%m%d"`

if [ "$#" -eq 2 ]; then
  yesterday=$1
  today=$2
fi

hive -e "add jar /home/membership02/boss_stat_new/common_stat/inner_channel_stat/boss_filter_url.jar;
         create temporary function filter_ref as 'com.letv.boss.stat.hive.FilterUrlUDF'; 
select tt1.dt,tt1.cur_url_ref,coalesce(tt2.neworxufei,-2),count(distinct tt1.letv_cookie),count(distinct coalesce(tt2.uid,0)) from
(select t.uid,t.letv_cookie,t.cur_url_ref,t.dt from
   (select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where  dt>='${yesterday}' and dt<'${today}' and product='0')t 
     where t.cur_url_ref is not null)tt1
left outer join
(select t2.uid,t2.letv_cookie,t2.cur_url_ref,t1.neworxufei,t2.dt from
(select userid,status,neworxufei,dt from data_raw.t_new_order_4_data where dt>='${yesterday}' and dt<'${today}' and orderpaytype!='-1' and status='1' and terminal='113' and ordertype not in (0,1,1001))t1
join
(select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where dt>='${yesterday}' and dt<'${today}' and product='0' and ilu='0' and cur_url!='-' and cur_url!='' and cur_url is not null)t2
on(t1.userid=t2.uid and t1.dt=t2.dt and t2.cur_url_ref is not null))tt2
on(tt1.letv_cookie=tt2.letv_cookie and tt1.dt=tt2.dt)
group by tt1.dt,tt1.cur_url_ref,tt2.neworxufei" > ./data/mz_inner_channels_income.$yesterday
