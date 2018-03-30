#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi


hive -e "
set hive.groupby.skewindata=false;
SELECT
	count(DISTINCT t2.uid),
	sum(
		CASE
		WHEN t2.play > 0
		OR t2.time > 0 THEN
			1
		ELSE
			0
		END
	),
	count(
		DISTINCT CASE
		WHEN t2.play > 0
		OR t2.time > 0 THEN
			t2.uid
		END
	),
	sum(
		CASE
		WHEN t2.time > 0 THEN
			t2.pt
		ELSE
			cast(0 AS BIGINT)
		END
	),
	t2.p1,
	t2.p2,
	t2.p3,
	t1.orderpaytype,
	t1.neworxufei,
	t2.pay,
	'd_00006_1',
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
) t2 ON (t1.userid = t2.uid)
GROUP BY
	t2.p1,
	t2.p2,
	t2.p3,
	t1.orderpaytype,
	t1.neworxufei,
	t2.pay,
	t1.viptype" > ./data/activity_user_order_data.${sdate//-/}
