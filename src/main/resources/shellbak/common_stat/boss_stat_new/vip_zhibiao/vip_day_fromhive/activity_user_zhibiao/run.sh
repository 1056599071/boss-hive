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
hive -e "set hive.groupby.skewindata=false;
SELECT
	count(DISTINCT t3.userid),
	t4.product,
	t3.orderpaytype,
	'd_00005',
	max(t4.dt)
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype
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
				AND dt <= '${ssdate}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND dt <= '${ssdate}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT
		uid,
		dt,
		product
	FROM
		data_raw.tbl_pv_hour
	WHERE
		dt = '${ssdate}'
	AND ilu = '0'
	AND uid != '-'
	AND (
		product = '1'
		OR product = '2'
		OR (product = '0' AND p2 = '04')
	)
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.product,
	t3.orderpaytype" > ./data/activity_user_data.${ssdate}

#############客户端android ipad ios##################
hive -e "set hive.groupby.skewindata=false;
SELECT
	count(DISTINCT t3.userid),
	t4.p3,
	t3.orderpaytype,
	'd_00005',
	max(t4.dt)
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype
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
				AND dt <= '${ssdate}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND dt <= '${ssdate}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT DISTINCT
		uid,
		dt,
		p3
	FROM
		data_raw.tbl_action_hour
	WHERE
		dt = '${ssdate}'
	AND ilu = '0'
	AND uid != '-'
	AND product = '0'
	AND p2 = '00'
	AND p3 IN ('001', '002', '004')
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p3,
	t3.orderpaytype" >> ./data/activity_user_data.${ssdate}


#############会员访问视频UVCV#########################
hive -e "set hive.groupby.skewindata=false;
SELECT
	count(DISTINCT t3.userid),
	count(vid),
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype,
	'd_00006',
	max(t4.dt)
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype
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
				AND dt <= '${ssdate}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND dt <= '${ssdate}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT DISTINCT
		uid,
		vid,
		p1,
		p2,
		p3,
		dt
	FROM
		data_raw.boss_play_day
	WHERE
		dt = '${ssdate}'
	AND ilu = '0'
	AND uid != '-'
	AND p1 IN (0, 1, 2)
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype" > ./data/activity_cvuv_data.${ssdate}


###############会员访问付费视频UVCV#########################
hive -e "set hive.groupby.skewindata=false;
SELECT
	count(DISTINCT t3.userid),
	count(vid),
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype,
	'd_00006',
	max(t4.dt)
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype
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
				AND dt <= '${ssdate}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND dt <= '${ssdate}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT DISTINCT
		uid,
		vid,
		p1,
		p2,
		p3,
		dt
	FROM
		data_raw.boss_play_day
	WHERE
		dt = '${ssdate}'
	AND ilu = '0'
	AND uid != '-'
	AND p1 IN (0, 1, 2)
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype" >> ./data/activity_cvuv_data.${ssdate}


##############人均播放时长#########################
hive -e "set hive.groupby.skewindata=false;
SELECT
	sum(t4.pt) / count(DISTINCT t3.userid),
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype,
	'd_00010',
	max(t4.dt)
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype
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
				AND dt <= '${ssdate}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND dt <= '${ssdate}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT
		uid,
		pt,
		p1,
		p2,
		p3,
		dt
	FROM
		data_raw.boss_play_day
	WHERE
		dt = '${ssdate}'
	AND ilu = '0'
	AND act = 'time'
	AND uid != '-'
	AND pt != '-'
	AND p1 IN (0, 1, 2)
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype" >  ./data/activity_avgtime_data.${ssdate}


##############次均播放时长##################
hive -e "set hive.groupby.skewindata=false;
SELECT
	sum(t4.pt) / count(t4.vid),
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype,
	'd_00011',
	max(t4.dt)
FROM
	(
		SELECT
			t1.userid,
			t2.orderpaytype
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
				AND dt <= '${ssdate}'
				GROUP BY
					userid
			) t1
		JOIN (
			SELECT
				userid,
				orderpaytype,
				canceltime
			FROM
				dm_boss.t_new_order_4_data
			WHERE
				canceltime >= '${sdate}'
			AND STATUS = 1
			AND dt <= '${ssdate}'
		) t2 ON (
			t1.userid = t2.userid
			AND t1.canceltime = t2.canceltime
		)
	) t3
JOIN (
	SELECT
		count(DISTINCT vid) AS vid,
		sum(pt) AS pt,
		uid,
		p1,
		p2,
		p3,
		max(dt) AS dt
	FROM
		data_raw.boss_play_day
	WHERE
		dt = '${ssdate}'
	AND ilu = '0'
	AND act = 'time'
	AND uid != '-'
	AND pt != '-'
	GROUP BY
		uid,
		p1,
		p2,
		p3
) t4 ON (t3.userid = t4.uid)
GROUP BY
	t4.p1,
	t4.p2,
	t4.p3,
	t3.orderpaytype" >> ./data/activity_avgtime_data.${ssdate}
