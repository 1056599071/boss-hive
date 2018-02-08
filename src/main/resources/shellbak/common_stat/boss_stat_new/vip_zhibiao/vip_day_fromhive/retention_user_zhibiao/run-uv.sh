#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi

	hive -e "select count(distinct t5.uid),t5.p1,t5.p2,t5.p3,t3.orderpaytype,t3.neworxufei,'d_00060',${sdate//-/} from
			(select t1.userid,t2.orderpaytype,t2.neworxufei,t1.canceltime from
			(select userid,min(canceltime) as canceltime from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and ordertype!='1001' and viptype!='-1' and dt<='${sdate//-/}' group by userid)t1 
			join
			(select userid,orderpaytype,canceltime,neworxufei from data_raw.t_new_order_4_data where canceltime>='${sdate}' and status=1 and ordertype!='1001' and viptype!='-1' and dt<='${sdate//-/}')t2
			on(t1.userid=t2.userid and t1.canceltime=t2.canceltime))t3
			join
			(select uid,play,time,pay,p1,pt,p2,p3,uuid,dt from data_sum.sum_user_uuid_play_day where dt='${sdate//-/}' and uid!='-')t5
			on(t3.userid=t5.uid)
			group by t5.p1,t5.p2,t5.p3,t3.orderpaytype,t3.neworxufei" > ./data/retention_uv_data.${sdate//-/}
