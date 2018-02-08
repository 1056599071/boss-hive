
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

	echo $sdate
	#day=$(((`date +%s -d ${sdate_1}`-`date +%s -d ${sdate}`)/86400))
	########cvuv
	hive -e "add jar /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_zhibiao/json-udf-1.3.7-jar-with-dependencies.jar;
 SELECT user_id,props, get_json_object(f.props, '$.p3')   FROM dws.dws_flow_play_day f WHERE dt='20171004' and  user_id != '-' LIMIT 10;
			" > ./data/retention_cvuv_data_.${sdate//-/}


