#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate_1=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate_1=$1
fi

sdate_2=`date -d "${sdate_1} 1 days ago" +"%Y-%m-%d"`
sdate_3=`date -d "${sdate_1} 2 days ago" +"%Y-%m-%d"`
sdate_7=`date -d "${sdate_1} 6 days ago" +"%Y-%m-%d"`
sdate_15=`date -d "${sdate_1} 14 days ago" +"%Y-%m-%d"`
sdate_30=`date -d "${sdate_1} 29 days ago" +"%Y-%m-%d"`

ssdate_1=${sdate_1//-/}
ssdate_2=${sdate_2//-/}
ssdate_3=${sdate_3//-/}
ssdate_7=${sdate_7//-/}
ssdate_15=${sdate_15//-/}
ssdate_30=${sdate_30//-/}

################留存用户数############################

################留存用户数cvuv########################
#for $sdate in $sdate_2 $sdate_3 $sdate_7 $sdate_15 $sdate_30
for sdate in $sdate_2
do
	echo $sdate
	day=$(((`date +%s -d ${sdate_1}`-`date +%s -d ${sdate}`)/86400))
	########pc m 留存数
	########cvuv
	hive -e "
			select count(distinct t5.uid,t5.uuid),sum(case when (t5.play+t5.time)>0 then 1 else 0 end),count(distinct case when (t5.play+t5.time)>0 then t5.uid end),sum(case when t5.time>0 then t5.pt else cast(0 as bigint) end),t5.p1,t5.p2,t5.p3,t3.orderpaytype,t3.neworxufei,t5.pay,case when t3.canceltime<'${sdate_1}' then 0 else 1 end,'d_00016',${sdate//-/} from
			(select t1.userid,t2.orderpaytype,t2.neworxufei,t1.canceltime from
			(select userid,min(canceltime) as canceltime from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and ordertype!='1001' and viptype!='-1' and dt<='${sdate//-/}' group by userid)t1 
			join
			(select userid,orderpaytype,canceltime,neworxufei from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and ordertype!='1001' and viptype!='-1' and dt<='${sdate//-/}')t2
			on(t1.userid=t2.userid and t1.canceltime=t2.canceltime))t3
			join
			(select uid,play,time,p1,p2,p3,uuid,pay,dt from data_sum.sum_user_uuid_play_day where dt='${sdate//-/}' and (play>0 or time>0) and uid!='-')t4
			on(t3.userid=t4.uid)
			join
			(select uid,play,time,pay,p1,pt,p2,p3,uuid,dt from data_sum.sum_user_uuid_play_day where dt='${ssdate_1}' and (play>0 or time>0) and uid!='-')t5
			on(t4.uid=t5.uid)
			group by t5.p1,t5.p2,t5.p3,t3.orderpaytype,t3.neworxufei,t5.pay,case when t3.canceltime<'${sdate_1}' then 0 else 1 end" > ./data/retention_cvuv_data_${day}.${sdate//-/}
done