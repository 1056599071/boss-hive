#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`
s_sdate=`date -d "2 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi


ssdate=${sdate//-/}


hive -e "
select count(distinct t1.userid),sum(t1.money),t1.can from 
(select userid,sum(money) as money,max(canceltime) as canceltime,case when datediff(max(canceltime),'$sdate')<30 then 'lt30' when datediff(max(canceltime),'$sdate')>=30 then 'gt30' end as can from dm_boss.t_new_order_4_data where status=1 and  neworxufei='0' and ordertype!='1001' and viptype!='-1' and canceltime>='$sdate' and dt='${ssdate}' group by userid)t1
JOIN
(select distinct uid from data_sum.sum_user_pv_day where dt='${ssdate}' and product='tv' and ilu='0')t2
on(t1.userid=t2.uid)
group by t1.can" > ./data/income_new.${ssdate}

hive -e "
select count(distinct t1.userid),sum(t1.money),t1.can from
(select userid,sum(money) as money,max(canceltime) as canceltime,case when datediff(max(canceltime),'$sdate')<30 then 'lt30' when datediff(max(canceltime),'$sdate')>=30 then 'gt30' end as can from dm_boss.t_new_order_4_data where status=1 and  neworxufei='0' and ordertype!='1001' and viptype!='-1' and canceltime>='$sdate' and dt='${ssdate}' group by userid)t1
JOIN
(select distinct uid from data_sum.sum_user_pv_day where dt='${ssdate}' and product='tv' and p2='21' and ilu='0')t2
on(t1.userid=t2.uid)
group by t1.can" > ./data/income_tv21_new.${ssdate}
