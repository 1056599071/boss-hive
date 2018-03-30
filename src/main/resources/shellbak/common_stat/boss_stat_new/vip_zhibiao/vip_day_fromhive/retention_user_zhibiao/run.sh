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
ssdate_3=${sdate_3//-/}
ssdate_7=${sdate_7//-/}
ssdate_15=${sdate_15//-/}
ssdate_30=${sdate_30//-/}

################PC MZ TV 7日活跃会员用户数########################
echo $sdate_1 $sdate_3 $sdate_7 $sdate_15 $sdate_30

for sdate in $sdate_7 $sdate_15 $sdate_30
#for sdate in $sdate_7
do 
	day=$(((`date +%s -d ${sdate_1}`-`date +%s -d ${sdate}`)/86400))
	hive -e "set hive.optimize.skewjoin=false;
		     set hive.groupby.skewindata=false;
			SELECT
	count(DISTINCT t3.userid),
	t4.p1,
	t4.p2,
	t3.orderpaytype,
	'd_00012_${day}',
	t3.neworxufei,
	${sdate//-/},
	t3.viptype
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype,
			t2.neworxufei,
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
				AND dt = '${ssdate_1}'
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
			AND dt = '${ssdate_1}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT
		user_id as uid,
		dt,
		props [ 'p1' ] AS p1,
		app_name AS p2
	FROM
		dws.dws_flow_play_day
	WHERE
		dt >= '${sdate//-/}'
	AND dt <= '${ssdate_1}'
	AND pf IN ('pc', 'mh5', 'tv')
	AND user_id != '-'
	AND (
		(props [ 'p1' ]  = '1' AND app_name IN('10', '11'))
		OR (props [ 'p1' ]  = '2' AND app_name = '21')
		OR (props [ 'p1' ]  = '0' AND app_name IN('04', '05', '06'))
	)
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p1,
	t4.p2,
	t3.orderpaytype,
	t3.neworxufei,
	t3.viptype " > ./data/retention_user_data_${day}.${sdate//-/}
####app
	hive -e "set hive.optimize.skewjoin=false;
		     set hive.groupby.skewindata=false;
		SELECT
	count(DISTINCT t3.userid),
	t4.p1,
	t4.p3,
	t3.orderpaytype,
	'd_00012_${day}',
	t3.neworxufei,
	${sdate//-/},
	t3.viptype
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype,
			t2.neworxufei,
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
				AND dt = '${ssdate_1}'
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
			AND dt = '${ssdate_1}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT DISTINCT
		user_id as uid,
		dt,
		props [ 'p1' ] AS p1,
		props [ 'p3' ] AS p3
	FROM
		dws.dws_flow_play_day
	WHERE
		dt >= '${sdate//-/}'
	AND dt <= '${ssdate_1}'
	AND pf = 'mc'
	AND props [ 'p1' ] = '0'
	AND app_name = '00'
	AND user_id != '-'
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p1,
	t4.p3,
	t3.orderpaytype,
	t3.neworxufei,
	t3.viptype ">> ./data/retention_user_data_${day}.${sdate//-/}
done
