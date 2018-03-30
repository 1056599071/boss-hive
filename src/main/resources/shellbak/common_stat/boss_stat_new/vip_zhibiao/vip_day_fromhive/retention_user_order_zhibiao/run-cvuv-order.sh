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
for sdate in $sdate_2 $sdate_3 $sdate_7 $sdate_15 $sdate_30
#for sdate in $sdate_2
do
	echo $sdate
	day=$(((`date +%s -d ${sdate_1}`-`date +%s -d ${sdate}`)/86400))
	########cvuv
	hive -e "set hive.groupby.skewindata=false;
SELECT
	count(DISTINCT t5.uid),
	sum(
		CASE
		WHEN t5.play > 0
		OR t5.time > 0 THEN
			1
		ELSE
			0
		END
	),
	count(
		DISTINCT CASE
		WHEN t5.play > 0
		OR t5.time > 0 THEN
			t5.uid
		END
	),
	sum(
		CASE
		WHEN t5.time > 0 THEN
			t5.pt
		ELSE
			cast(0 AS BIGINT)
		END
	),
	t5.p1,
	t5.p2,
	t5.p3,
	t1.orderpaytype,
	t1.neworxufei,
	t5.pay,
	CASE
WHEN t1.canceltime < '${sdate_1}' THEN
	0
ELSE
	1
END,
 'd_00018_${day}',
 ${sdate//-/},
 t1.viptype
FROM
	(
		SELECT
			userid,
			orderpaytype,
			canceltime,
			neworxufei,
			viptype
		FROM
			dm_boss.t_new_order_4_data
		WHERE
			STATUS = 1
		AND ordertype != '1001'
		AND viptype != '-1'
		AND dt = '${sdate//-/}'
	) t1
JOIN (
	SELECT DISTINCT
		user_id as uid
	FROM
		dws.dws_flow_play_day
	WHERE
		dt = '${sdate//-/}'
	AND user_id != '-'
) t4 ON (t1.userid = t4.uid)
JOIN (
	SELECT
		user_id as uid,
		play_times as play,
		beat_times as time,
		is_pay as pay,
		props [ 'p1' ] AS p1,
		pt,
		app_name AS p2,
		props [ 'p3' ] AS p3,
		play_id as uuid,
		dt
	FROM
		dws.dws_flow_play_day
	WHERE
		dt = '${ssdate_1}'
	AND user_id != '-'
) t5 ON (t4.uid = t5.uid)
GROUP BY
	t5.p1,
	t5.p2,
	t5.p3,
	t1.orderpaytype,
	t1.neworxufei,
	t5.pay,
	CASE
WHEN t1.canceltime < '${sdate_1}' THEN
	0
ELSE
	1
END,
t1.viptype" > ./data/retention_order_cvuv_data_${day}.${sdate//-/}
done
