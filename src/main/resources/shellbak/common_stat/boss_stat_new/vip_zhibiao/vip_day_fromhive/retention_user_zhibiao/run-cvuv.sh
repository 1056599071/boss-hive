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
	hive -e "set hive.groupby.skewindata=false;set hive.optimize.skewjoin=false;
		SELECT
	count(DISTINCT t5.user_id),
	sum(
		CASE
		WHEN t5.play_times > 0
		OR t5.beat_times > 0 THEN
			1
		ELSE
			0
		END
	),
	count(
		DISTINCT CASE
		WHEN t5.play_times > 0
		OR t5.beat_times > 0 THEN
			t5.user_id
		END
	),
	sum(
		CASE
		WHEN t5.beat_times > 0 THEN
			t5.pt
		ELSE
			cast(0 AS BIGINT)
		END
	),
	t5.p1,
	t5.p2,
	t5.p3,
	t3.orderpaytype,
	t3.neworxufei,
	t5.is_pay,
CASE
WHEN t3.canceltime < '${sdate_1}' THEN
	0
ELSE
	1
END,
 'd_00017_${day}',
 ${sdate//-/}
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype,
			t2.neworxufei,
			t1.canceltime
		FROM
			(
				SELECT
					userid,
					min(canceltime) AS canceltime
				FROM
					dm_boss.t_new_order_4_data
				WHERE
					canceltime >= '${sdate}'
				AND STATUS = 1
				AND ordertype != '1001'
				AND viptype != '-1'
				AND dt = '${sdate//-/}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime,
				neworxufei
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND ordertype != '1001'
			AND viptype != '-1'
			AND dt = '${sdate//-/}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT DISTINCT
		user_id
	FROM
		dws.dws_flow_play_day
	WHERE
		dt = '${sdate//-/}'
	AND user_id != '-'
) t4 ON (t3.userid = t4.user_id)
JOIN (
	SELECT
		user_id,
		play_times,
		beat_times,
		is_pay,
		props['p1'] as p1,
		pt,
		app_name as p2,
		props['p3'] as p3,
		play_id,
		dt
	FROM
		dws.dws_flow_play_day
	WHERE
		dt = '${ssdate_1//-/}'
	AND user_id != '-'
) t5 ON (t4.user_id = t5.user_id)
GROUP BY
	t5.p1,
	t5.p2,
	t5.p3,
	t3.orderpaytype,
	t3.neworxufei,
	t5.is_pay,
CASE
WHEN t3.canceltime < '${sdate_1}' THEN
	0
ELSE
	1
END" > ./data/retention_cvuv_data_${day}.${sdate//-/}
done
