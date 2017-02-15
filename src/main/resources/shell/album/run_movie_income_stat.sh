#!/bin/sh
#导入影片统计相关信息
echo "开始导入影片收入数据到bosstdy中";

bosstdyIp="117.121.54.134"
bosstdyUser=bosstdy_w
bosstdyPassword=4f0aedbb8955ce8
bosstdyDatebase=bosstdy

today=`date -d"0 days ago " "+%Y%m%d"`
startDate=`date -d"1 days ago " "+%Y%m%d"`
endDate=`date -d"1 days ago " "+%Y%m%d"`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   startDate=$1
   endDate=$1
fi
if [ "$#" -eq 2 ]; then
   startDate=$1
   endDate=$2
fi

sys_s_date=`date -d  "$startDate" +%s`
sys_e_date=`date -d   "$endDate" +%s`
sys_t_date=`date -d   "$today" +%s`

interval_s=`expr $sys_t_date - $sys_s_date`
interval_e=`expr $sys_t_date - $sys_e_date`

daycount_s=`expr $interval_s / 3600 / 24`
daycount_e=`expr $interval_e / 3600 / 24`

echo $daycount_s
echo $daycount_e

for (( i = $daycount_s; i>=$daycount_e; i-- ));do
        date=`date -d"$i days ago " "+%Y%m%d"`

hive -e "
select t_play.pid,t_play.cid,count(distinct t_play.uid) as user_count,concat_ws(',', collect_set(t_order.userid)),0,sum(case t_play.prop when '0' then 1 end) as informal_uv,sum(case t_play.prop when '1' then 1 end) as formal_uv,t_order.terminal,t_order.viptype,t_order.orderpaytype,'${date}' from 
(select distinct userid,terminal,viptype,orderpaytype from dm_boss.t_new_order_4_data where dt='${date}' and status='1' and viptype != '-1' and terminal in ('111', '112', '113', '120', '130')) t_order
join
(select distinct pid,uid,cid,'0' as prop from dm_boss.tbl_play_day_boss where dt='${date}' and p1 in ('0','1','2') and property like '%pay=0%' and uid !='-' and uid!='' and pid !='-' and pid !='' and cid!='' and cid!='-'
union all
select distinct pid,uid,cid,'1' as prop from dm_boss.tbl_play_day_boss where dt='${date}' and p1 in ('0','1','2') and property like '%pay=1%' and uid !='-' and uid!='' and pid !='-' and pid !='' and cid!='' and cid!='-' and ilu='0') t_play
on(t_order.userid=t_play.uid) group by t_order.terminal, t_order.viptype, t_order.orderpaytype, t_play.pid, t_play.cid;" > ./data/movie_income_stat.${date}

#导入点播数据  目前只导入现金且金额大于0部分
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N -e "select aid2 as playlistId,'' as cid,count(distinct userid) as user_count,GROUP_CONCAT(distinct userid) as user_ids,sum(money) as income,0 as informal_uv,count(1) as formal_uv,terminal,viptype,orderpaytype,date(paytime) as date from T_NEW_ORDER_4_DATA where date(paytime)='${date}' and status='1' and viptype='-1' and orderpaytype='2' and terminal in ('111', '112', '113', '120', '130') and money>0 group by playlistId,terminal,orderpaytype" >> ./data/movie_income_stat.${date}

##导入数据到PAY_MOVIE_STAT
echo "load play data into bosstdy! date=$date";
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "delete from PAY_MOVIE_STAT where date='${date}'; load data local infile './data/movie_income_stat.$date' IGNORE into table PAY_MOVIE_STAT  fields terminated by '\t' (playlist_id,channel_id,user_count,user_ids,income,informal_uv,formal_uv,terminal,viptype,orderpaytype,date);"

done;

#专辑名称导入到数据库
./save_playlist_name.sh

echo "导入数据到PAY_MOVIE_STAT表完成，时间范围${startDate} ~ ${endDate}";

