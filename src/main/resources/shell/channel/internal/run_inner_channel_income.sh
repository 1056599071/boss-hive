#!/bin/sh
#计算由播放页带来的付费转化率
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "开始计算${yesterday}日的内部渠道流量PC端数据"

##########################增加站内渠道收入#####################################
hive -e "add jar /home/zhaochunlong/boss_stat/common_stat/inner_channel_stat/boss-hive.jar;
         create temporary function filter_ref as 'com.letv.boss.stat.hive.FilterUrlUDF'; 
select tt3.dt,tt3.cur_url_ref,coalesce(tt3.neworxufei,-2),count(distinct tt3.letv_cookie),count(distinct coalesce(tt3.uid,0)),sum(tt3.money) from
(select distinct tt1.dt,tt1.cur_url_ref,coalesce(tt2.neworxufei,-2) as neworxufei,tt1.letv_cookie,coalesce(tt2.uid,0) as uid,coalesce(tt2.money,0) as money from
(select t.uid,t.letv_cookie,t.cur_url_ref,t.dt from
   (select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where dt = '${yesterday}' and product='1' and letv_cookie!='-') t 
     where t.cur_url_ref is not null)tt1
left outer join
(select distinct t2.uid,t2.letv_cookie,t2.cur_url_ref,t1.neworxufei,t1.money,t2.dt from
(select userid,money,status,neworxufei,dt from dm_boss.t_new_order_4_data where dt = '${yesterday}' and orderpaytype!='-1' and status='1' and terminal='112' and viptype!='-1' and ordertype not in (0,1,1001))t1
join
(select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where dt = '${yesterday}' and product='1' and ilu='0' and cur_url!='-' and cur_url!='' and cur_url is not null)t2
on(t1.userid=t2.uid and t1.dt=t2.dt and t2.cur_url_ref is not null))tt2
on(tt1.letv_cookie=tt2.letv_cookie and tt1.dt=tt2.dt))tt3
group by tt3.dt,tt3.cur_url_ref,tt3.neworxufei" > ./data/pc_inner_channel_income.${yesterday}

echo "开始计算${yesterday}日的内部渠道流量MSite端数据"

hive -e "add jar /home/zhaochunlong/boss_stat/common_stat/inner_channel_stat/boss-hive.jar;
         create temporary function filter_ref as 'com.letv.boss.stat.hive.FilterUrlUDF'; 
select tt3.dt,tt3.cur_url_ref,coalesce(tt3.neworxufei,-2),count(distinct tt3.letv_cookie),count(distinct coalesce(tt3.uid,0)),sum(tt3.money) from
(select distinct tt1.dt,tt1.cur_url_ref,coalesce(tt2.neworxufei,-2) as neworxufei,tt1.letv_cookie,coalesce(tt2.uid,0) as uid,coalesce(tt2.money,0) as money from
(select t.uid,t.letv_cookie,t.cur_url_ref,t.dt from
   (select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where  dt = '${yesterday}' and product='0')t 
     where t.cur_url_ref is not null)tt1
left outer join
(select distinct t2.uid,t2.letv_cookie,t2.cur_url_ref,t1.neworxufei,t1.money,t2.dt from
(select userid,status,neworxufei,money,dt from dm_boss.t_new_order_4_data where dt = '${yesterday}' and orderpaytype!='-1' and status='1' and viptype!='-1' and terminal='113' and ordertype not in (0,1,1001))t1
join
(select uid,letv_cookie,filter_ref(cur_url) as cur_url_ref,dt from data_raw.tbl_pv_hour where dt = '${yesterday}' and product='0' and ilu='0' and cur_url!='-' and cur_url!='' and cur_url is not null)t2
on(t1.userid=t2.uid and t1.dt=t2.dt and t2.cur_url_ref is not null))tt2
on(tt1.letv_cookie=tt2.letv_cookie and tt1.dt=tt2.dt))tt3
group by tt3.dt,tt3.cur_url_ref,tt3.neworxufei" > ./data/mz_inner_channel_income.${yesterday}
