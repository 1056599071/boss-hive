#!/usr/bin/env bash

yesterday=`date -d "1 days ago" +"%Y%m%d"`

hive -e "add jar /home/zhaochunlong/boss_stat/common_stat/inner_channel_stat/boss-hive.jar;
         create temporary function filter_ref as 'com.letv.boss.stat.hive.FilterUrlUDF';
select tt3.dt,tt3.cur_url_ref,coalesce(tt3.neworxufei,-2),count(distinct tt3.letv_cookie),count(distinct coalesce(tt3.uid,0)),sum(tt3.money) from
(select distinct tt1.dt,tt1.cur_url_ref,coalesce(tt2.neworxufei,-2) as neworxufei,tt1.letv_cookie,coalesce(tt2.uid,0) as uid,coalesce(tt2.money,0) as money from
(select t.uid,t.letv_cookie,t.cur_url_ref,t.dt from
   (select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where dt = '${yesterday}' and product='1' and letv_cookie!='-') t
     where t.cur_url_ref is not null)tt1
left outer join
(select distinct t2.uid,t2.letv_cookie,t2.cur_url_ref,t1.neworxufei,t1.money,t2.dt from
(select userid,money,status,neworxufei,dt from dm_boss.t_new_order_4_data where dt = '${yesterday}' and orderpaytype!='-1' and status='1' and terminal='112' and viptype!='-
1' and ordertype not in (0,1,1001))t1
join
(select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where dt = '${yesterday}' and product='1' and ilu='0' and cur_url!='-' and cur_url!=
'' and cur_url is not null)t2
on(t1.userid=t2.uid and t1.dt=t2.dt and t2.cur_url_ref is not null))tt2
on(tt1.letv_cookie=tt2.letv_cookie and tt1.dt=tt2.dt))tt3
group by tt3.dt,tt3.cur_url_ref,tt3.neworxufei" > tt3.txt