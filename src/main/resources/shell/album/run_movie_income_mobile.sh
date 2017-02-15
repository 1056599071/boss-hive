source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

#yesterday=${yesterdays//-/}


hive -e "
select distinct t_play.pid,t_play.vid,t_order.userid,'130',t_play.prop,'${yesterday}' from 
(select userid,money from dm_boss.t_new_order_4_data where dt='${yesterday}' and  status='1' and money!='0' and terminal='130' and orderpaytype='2')t_order
join
(select distinct t2.uid,t2.vid,t2.pid,'0' as prop from 
(select uid,deviceid from data_raw.tbl_action_hour where dt='${yesterday}' and product='0' and vid='-' and uid !='-' and uid!='' and deviceid!='-' and deviceid!='0' and deviceid!='' and ilu='0')t1
join
(select uid,vid,pid,deviceid from dm_boss.tbl_play_day_boss where dt='${yesterday}' and p1='0' and property like '%pay=0%' and uid !='-' and uid!='' and deviceid!='-' and deviceid!='0' and deviceid!='')t2
on(t1.deviceid=t2.deviceid)
union all
select distinct uid,vid,pid,'1' as prop from dm_boss.tbl_play_day_boss where dt='${yesterday}' and p1='0' and property like '%pay=1%' and uid !='-' and uid!='' and deviceid!='-' and deviceid!='0' and deviceid!='' and ilu='0') 
t_play
on(t_order.userid=t_play.uid) " >  ./data/movie_income_mobile.${yesterday}
