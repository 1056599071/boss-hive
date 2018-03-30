#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi


hive -e "set hive.groupby.skewindata=false;set hive.optimize.skewjoin=false;
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
	t3.orderpaytype,
	t3.neworxufei,
	t5.pay,
	'd_00005_1',
	${sdate//-/},
	t3.viptype
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype,
			t2.neworxufei,
			t1.canceltime,
			t2.viptype
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
				neworxufei,
				viptype
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
		dt = '${sdate//-/}'
	AND user_id != '-'
) t5 ON (t3.userid = t5.uid)
GROUP BY
	t5.p1,
	t5.p2,
	t5.p3,
	t3.orderpaytype,
	t3.neworxufei,
	t5.pay,
	t3.viptype" > ./data/activity_user_data_uuid.${sdate//-/}
