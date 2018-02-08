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

################PC MZ TV活跃会员用户数########################
hive -e "select count(distinct t3.userid),t4.product,t3.orderpaytype,'d_00005',max(t4.dt) from 
(select t1.userid,t2.orderpaytype from
(select userid,min(canceltime) as canceltime  from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and dt<='${ssdate}' group by userid)t1 
join
(select userid,orderpaytype,canceltime from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and dt<='${ssdate}')t2
on(t1.userid=t2.userid and t1.canceltime=t2.canceltime))t3
join
(select uid,dt,product from data_raw.tbl_pv_hour where dt='${ssdate}' and ilu='0' and uid!='-' and (product='1' or (product='2' and p2='21') or (product='0' and p2='04'))) t4 
on(t3.userid=t4.uid)
group by t4.product,t3.orderpaytype" > ./data/activity_user_data.${ssdate}

#############客户端android ipad ios##################
hive -e "select count(distinct t3.userid),t4.p3,t3.orderpaytype,'d_00005',max(t4.dt) from 
(select t1.userid,t2.orderpaytype from
(select userid,min(canceltime) as canceltime  from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and dt<='${ssdate}' group by userid)t1 
join
(select userid,orderpaytype,canceltime from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and dt<='${ssdate}')t2
on(t1.userid=t2.userid and t1.canceltime=t2.canceltime))t3
join
(select distinct uid,dt,p3 from data_raw.tbl_action_hour where dt='${ssdate}' and ilu='0' and uid!='-' and product='0' and p2='00' and p3 in ('001','002','004')) t4
on(t3.userid=t4.uid) 
group by t4.p3,t3.orderpaytype" >> ./data/activity_user_data.${ssdate}


#############会员访问视频UVCV#########################
hive -e"
select count(distinct uid),count(distinct uid,uuid),count(distinct case when t4.property['pay']='1' then uid end),count(distinct case when t4.property['pay']='1' then concat(t4.uuid,t4.uid) end),sum(case when t4.act='time' then t4.pt end),t4.p1,t4.p2,t4.p3,t3.orderpaytype from
(select t1.userid,t2.orderpaytype from
(select userid,min(canceltime) as canceltime  from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and dt<='${ssdate}' group by userid)t1 
join
(select userid,orderpaytype,canceltime from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and dt<='${ssdate}')t2
on(t1.userid=t2.userid and t1.canceltime=t2.canceltime))t3 
join
(select distinct uid,split(uuid,'_')[0] as uuid,p1,case when p1='1' then '0' else p2 end as p2,case when (p1='2' and p2='21') or p1='1' then '0' else p3 end as p3,property,act,pt,dt from data_raw.boss_play_day where dt='${ssdate}' and ilu='0' and uid!='-' and (p1='0' and p2='00' and p3 in ('001','002','003','004')) or (p1='0' and p2='04') or (p1='1') or (p1='2' and p2='21') and act in ('play','init','time') and (split(uuid,'_')[1]<100 or split(uuid,'_')[1] is null) and uuid!='-')t4
on(t3.userid=t4.uid)
group by t4.p1,t4.p2,t4.p3,t3.orderpaytype" > ./data/activity_cvuvavg_data.${ssdate}
