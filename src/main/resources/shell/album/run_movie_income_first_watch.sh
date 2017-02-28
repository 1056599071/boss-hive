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

playTerminal="case when p1 = '0' and p2 in ('04', '05', '06') then 113 when p1 = '0' and p2 not in ('04', '05', '06') then 130 when p1 = '1' then 112 when p1 = '2' then 111 end"
viptype="case viptype when '0' then '9' else viptype end"

for (( i = $daycount_s; i>=$daycount_e; i-- ));do
        date=`date -d"$i days ago " "+%Y%m%d"`
	morrow=`expr $i - 1`
	datemorrow=`date -d"$morrow days ago " "+%Y%m%d"`
#首次观影记录
hive -e"
create temporary table play_record as 
select uid,cid,pid,$playTerminal as playTerminal,min(time) as time from data_raw.tbl_play_hour where (dt='$date' or (dt='$datemorrow' and hour in ('01', '02'))) and p1 in ('0','1','2') and property like '%pay=1%' and uid !='-' and uid!='' and cid!='' and cid!='-' and pid!='' and pid!='-' and ilu='0' group by uid,cid,pid,$playTerminal;

select t_play.pid,t_play.cid,t_play.playTerminal,count(distinct t_play.uid) as user_count,concat_ws(',', collect_set(distinct t_order.userid)),t_order.payTerminal,t_order.viptype,t_order.orderpaytype,'$date' from 
(select userid,terminal as payTerminal,$viptype as viptype,orderpaytype,paytime,min(paytime_hour) as paytime_hour from dm_boss.t_new_order_4_data where dt='$date' and status='1' and viptype in ('0','1','9') and terminal in ('111', '112', '113', '120', '130') group by userid,terminal,$viptype,orderpaytype,paytime) t_order
join
(select distinct a.uid,a.cid,a.pid,a.playTerminal,a.time from play_record a join (select uid, min(time) as time from play_record group by uid) b where a.uid = b.uid and a.time = b.time) t_play on(t_order.userid=t_play.uid) where t_order.paytime < substr(t_play.time, 0, 8) or (t_order.paytime = substr(t_play.time, 0, 8) and t_order.paytime_hour < substr(t_play.time, 10, 8)) group by t_order.payTerminal, t_order.viptype, t_order.orderpaytype, t_play.pid, t_play.cid, t_play.playTerminal;
" > ./data/movie_income_first_watch.$date;

#获取相关的所有Pid
pids=`awk '{print $1}' ./data/movie_income_first_watch.$date | sort -u | awk '{if(NR==1)printf("%s",$0);else printf("%s%s",",",$0)}'`;

#付费UV记录
hive -e"
select t_play.pid,t_play.cid,t_play.playTerminal,count(distinct t_play.uid) as formal_uv,t_order.terminal,t_order.viptype,t_order.orderpaytype,'$date' from 
(select distinct userid,terminal,$viptype as viptype,orderpaytype from dm_boss.t_new_order_4_data where status='1' and canceltime > '$date' and createtime < '$date' and viptype in ('0','1','9') and terminal in ('111', '112', '113', '120', '130')) t_order
join
(select distinct pid,uid,cid,$playTerminal as playTerminal from dm_boss.tbl_play_day_boss where dt='$date' and pid in($pids) and p1 in ('0','1','2') and property like '%pay=1%' and uid !='-' and uid!='' and pid !='-' and pid !='' and cid!='' and cid!='-' and ilu='0') t_play
on(t_order.userid=t_play.uid) group by t_order.terminal, t_order.viptype, t_order.orderpaytype, t_play.pid, t_play.cid, t_play.playTerminal;
" > ./data/movie_income_first_watch_informaluv.$date;

#合并首次观影与付费UV记录
awk 'NR==FNR {a[$1$2$3$6$7$8$9]=$4"\t"$5}NR!=FNR{print (a[$1$2$3$5$6$7$8]?$1"\t"$2"\t"$3"\t"$4"\t"a[$1$2$3$5$6$7$8]"\t"0"\t"$5"\t"$6"\t"$7"\t"$8:$1"\t"$2"\t"$3"\t"$4"\t\t\t"0"\t"$5"\t"$6"\t"$7"\t"$8)}'  ./data/movie_income_first_watch.$date ./data/movie_income_first_watch_informaluv.$date > ./data/movie_income_first_watch_final.$date;

#总UV和试看UV记录
hive -e"
select pid,cid,$playTerminal as playTerminal,count(distinct uid) as total_uv,count(distinct case when property like '%pay=0%' then uid end) as informal_uv,count(distinct case when property like '%pay=1%' then uid end) as formal_uv,'$date' from data_raw.tbl_play_hour where dt='$date' and p1 in ('0','1','2') and (property like '%pay=0%' or property like '%pay=1%') and uid !='-' and uid!='' and cid!='' and cid!='-' and pid!='' and pid!='-' and pid in ($pids) group by pid,cid,$playTerminal
" > ./data/movie_income_first_watch_totaluv.$date;

##导入总UV和试看UV记录到PAY_MOVIE_FIRST_WATCH_UV
echo "load data into bosstdy.PAY_MOVIE_FIRST_WATCH_UV! date=$date";
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "delete from PAY_MOVIE_FIRST_WATCH_UV where date='$date'; load data local infile './data/movie_income_first_watch_totaluv.$date' IGNORE into table PAY_MOVIE_FIRST_WATCH_UV  fields terminated by '\t' (playlist_id,channel_id,terminal,total_uv,informal_uv,formal_uv,date);"


#导入点播数据  目前只导入现金且金额大于0部分
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N -e "select aid2 as playlistId,'' as cid,'' as playTerminal,count(1) as formal_uv,count(distinct userid) as user_count,GROUP_CONCAT(distinct userid) as user_ids,sum(money) as income,terminal,viptype,orderpaytype,date(paytime) as date from T_NEW_ORDER_4_DATA where date(paytime)='${date}' and status='1' and viptype='-1' and orderpaytype='2' and terminal in ('111', '112', '113', '120', '130') and money>0 group by playlistId,terminal,orderpaytype" >> ./data/movie_income_first_watch_final.${date}

##导入合并后的记录到PAY_MOVIE_FIRST_WATCH
echo "load play data into bosstdy.AY_MOVIE_FIRST_WATCH! date=$date";
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "delete from PAY_MOVIE_FIRST_WATCH where date='$date'; load data local infile './data/movie_income_first_watch_final.$date' IGNORE into table PAY_MOVIE_FIRST_WATCH  fields terminated by '\t' (playlist_id,channel_id,play_terminal,formal_uv,user_count,user_ids,income,pay_terminal,viptype,orderpaytype,date);"

done;

echo "导入数据到PAY_MOVIE_STAT_FIRST_WATCH表完成，时间范围${startDate} ~ ${endDate}";

