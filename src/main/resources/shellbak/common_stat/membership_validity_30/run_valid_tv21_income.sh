#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi

ssdate=${sdate//-/}

if [ "$#" -eq 1 ]; then
  sdate=$1
fi

hive -e "
select t1.can,count(distinct t1.userid),${ssdate} from
(select userid,max(canceltime) as canceltime,case when datediff(max(canceltime),'${sdate}')<30 then 'lt30' when datediff(max(canceltime),'${sdate}')>=30 then 'gt30' end as can from dm_boss.t_new_order_4_data where status=1 and ordertype!='1001' and viptype!='-1' and canceltime>='${sdate}' and dt<='${ssdate}' group by userid) t1
JOIN
(select uid from data_sum.sum_user_pv_day where dt='${ssdate}' and product='tv' and p2='21' and ilu='0')t2
on(t1.userid=t2.uid)
group by t1.can" > ./data/membership_valid_tv21_30.${ssdate}



hive -e "
select count(distinct t2.id),${ssdate} from 
(select userid from dm_boss.t_new_order_4_data where status=1 and ordertype!='1001' and viptype!='-1' and canceltime>='${sdate}' and dt<='${ssdate}' group by userid)t1
right JOIN
(select uid,id from data_sum.sum_user_pv_day where dt='${ssdate}' and product='tv' and p2='21' and ilu='0')t2
on(t1.userid=t2.uid) 
where t1.userid is null" > ./data/login_invalid_tv21.${ssdate}


