#!/bin/sh
#计算由播放页带来的付费转化率

#source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

today=`date +"%Y%m%d"`

if [ "$#" -eq 2 ]; then
  yesterday=$1
  today=$2
fi

hive -e "add jar /home/boss/shell/hive/common_stat/boss_stat/inner_channels_rate/boss_filter_url.jar;
         create temporary function filter_ref as 'com.letv.boss.stat.hive.FilterUrlUDF'; 
select distinct tt2.dt,tt2.uid,tt2.money from
(select uid,letv_cookie,dt from data_raw.tbl_pv_hour where  dt>='20150901' and dt<='20150905' and product='1' and cur_url like '%winrarhy%'
)tt1
left outer join
(select t2.uid,t2.letv_cookie,t2.dt,t1.money from
(select userid,dt,money from data_raw.t_new_order_4_data where dt>='20150901' and dt<='20150905' and orderpaytype!='-1' and status='1' and terminal='112' and ordertype not in (1001))t1
join
(select uid,letv_cookie,dt from data_raw.tbl_pv_hour where dt>='20150901' and dt<='20150905' and product='1' and ilu='0' and cur_url!='-' and cur_url!='' and cur_url is not null)t2
on(t1.userid=t2.uid and t1.dt=t2.dt )
)tt2
on(tt1.letv_cookie=tt2.letv_cookie and tt1.dt=tt2.dt);
" > ./data/inner_channels_income.temp
