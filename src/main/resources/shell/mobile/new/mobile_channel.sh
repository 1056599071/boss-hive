#!/usr/bin/env bash
#移动端渠道流量统计

yesterday=`date -d "1 days ago" +%Y-%m-%d`

if [ $# -eq 1 ]; then
    yesterday=$1
fi

echo "正在统计${yesterday}的移动端流量"

hive -e "add jar /home/zhaochunlong/boss_stat/common_stat/mobile_action_stat/letv-boss-stat-1.2.jar;
create temporary function split_act as 'com.letv.boss.stat.hive.GenericUDTFSplitAct';
set hive.groupby.skewindata=true;
SELECT
	concat(
		p.act_code,
		'#',
		p.act_fl,
		'#',
		p.act_fragid,
		'#',
		p.act_scid,
		'#',
		p.act_name,
		'#',
		p.act_pageid,
		'#',
		p.act_wz,
		'#',
		p.p3,
		'#',
		p.pv / 2,
		'#',
		p.uv / 2,
		'#',
		q.neworxufei,
		'#',
		q.income,
		'#',
		q.orders,
		'#',
		0,
		'#',
		'${yesterday}'
	)
FROM
	(
		SELECT
			act_code,
			act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz,
			p3,
			count(deviceid) AS pv,
			count(DISTINCT deviceid) AS uv
		FROM
			data_raw.tbl_action_hour t lateral VIEW split_act (act_property) mytable AS act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz
		WHERE
			t.dt = '${yesterday//-/}'
		AND t.p1 = 0
		AND t.act_code IN (0, 17, 19, 25)
		AND t.act_property LIKE '%pageid=%'
		AND t.act_property LIKE '%fragid=%'
		AND t.deviceid != '-'
		GROUP BY
			act_code,
			act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz,
			p3
	) p
JOIN (
	SELECT
		a.act_code,
		a.act_fl,
		a.act_fragid,
		a.act_scid,
		a.act_name,
		a.act_pageid,
		a.act_wz,
		a.p3,
		b.neworxufei,
		SUM(b.income) AS income,
		SUM(b.orders) AS orders
	FROM
		(
			SELECT
				act_code,
				act_fl,
				act_fragid,
				act_scid,
				act_name,
				act_pageid,
				act_wz,
				p3,
				deviceid,
				uid
			FROM
				data_raw.tbl_action_hour t lateral VIEW split_act (act_property) mytable AS act_fl,
				act_fragid,
				act_scid,
				act_name,
				act_pageid,
				act_wz
			WHERE
				t.dt = '${yesterday//-/}'
			AND t.p1 = 0
			AND t.act_code IN (0, 17, 19, 25)
			AND t.act_property LIKE '%pageid=%'
			AND t.act_property LIKE '%fragid=%'
			AND t.deviceid != '-'
			AND t.uid != '-'
			AND t.uid != ''
		) a
	JOIN (
		SELECT
			userid,
			neworxufei,
			CASE terminal2
		WHEN 41 THEN
			'004'
		WHEN 42 THEN
			'002'
		WHEN 47 THEN
			'001'
		ELSE
			''
		END AS p3,
		SUM(money) AS income,
		COUNT(DISTINCT orderid) AS orders
	FROM
		dm_boss.t_new_order_4_data
	WHERE
		dt = '${yesterday//-/}'
	AND orderpaytype != - 1
	AND terminal = 130
	AND ordertype != '1001'
	AND terminal2 IN (41, 42, 47)
	AND STATUS = 1
	AND neworxufei in (0, 1)
	GROUP BY
		userid,
		neworxufei,
		terminal2
	) b ON (a.uid = b.userid AND a.p3 = b.p3)
	GROUP BY
		a.act_code,
		a.act_fl,
		a.act_fragid,
		a.act_scid,
		a.act_name,
		a.act_pageid,
		a.act_wz,
		a.p3,
		b.neworxufei
) q ON (
	p.act_code = q.act_code
	AND p.act_fl = q.act_fl
	AND p.act_fragid = q.act_fragid
	AND p.act_scid = q.act_scid
	AND p.act_name = q.act_name
	AND p.act_pageid = q.act_pageid
	AND p.act_wz = q.act_wz
	AND p.p3 = q.p3
)" > ./data/mobile_channel.${yesterday//-/}

echo "按模块fragid统计${yesterday}日的移动端流量完成"

hive -e "add jar /home/zhaochunlong/boss_stat/common_stat/mobile_action_stat/letv-boss-stat-1.2.jar;
create temporary function split_act as 'com.letv.boss.stat.hive.GenericUDTFSplitAct';
set hive.groupby.skewindata=true;
SELECT
	concat(
		p.act_code,
		'#',
		p.act_fl,
		'#',
		p.act_fragid,
		'#',
		p.act_scid,
		'#',
		p.act_name,
		'#',
		p.act_pageid,
		'#',
		p.act_wz,
		'#',
		p.p3,
		'#',
		p.pv / 2,
		'#',
		p.uv / 2,
		'#',
		q.neworxufei,
		'#',
		q.income,
		'#',
		q.orders,
		'#',
		0,
		'#',
		'${yesterday}'
	)
FROM
	(
		SELECT
			act_code,
			act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz,
			p3,
			count(deviceid) AS pv,
			count(DISTINCT deviceid) AS uv
		FROM
			data_raw.tbl_action_hour t lateral VIEW split_act (act_property) mytable AS act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz
		WHERE
			t.dt = '${yesterday//-/}'
		AND t.p1 = 0
		AND t.act_code IN (0, 17, 19, 25)
		AND t.act_property LIKE '%pageid=%'
		AND t.act_property LIKE '%name=%'
		AND NOT t.act_property LIKE '%fragid=%'
		AND t.deviceid != '-'
		GROUP BY
			act_code,
			act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz,
			p3
	) p
JOIN (
	SELECT
		a.act_code,
		a.act_fl,
		a.act_fragid,
		a.act_scid,
		a.act_name,
		a.act_pageid,
		a.act_wz,
		a.p3,
		b.neworxufei,
		SUM(b.income) AS income,
		SUM(b.orders) AS orders
	FROM
		(
			SELECT
				act_code,
				act_fl,
				act_fragid,
				act_scid,
				act_name,
				act_pageid,
				act_wz,
				p3,
				deviceid,
				uid
			FROM
				data_raw.tbl_action_hour t lateral VIEW split_act (act_property) mytable AS act_fl,
				act_fragid,
				act_scid,
				act_name,
				act_pageid,
				act_wz
			WHERE
				t.dt = '${yesterday//-/}'
			AND t.p1 = 0
			AND t.act_code IN (0, 17, 19, 25)
			AND t.act_property LIKE '%pageid=%'
			AND t.act_property LIKE '%name=%'
		    AND NOT t.act_property LIKE '%fragid=%'
			AND t.deviceid != '-'
			AND t.uid != '-'
			AND t.uid != ''
		) a
	JOIN (
		SELECT
			userid,
			neworxufei,
			CASE terminal2
		WHEN 41 THEN
			'004'
		WHEN 42 THEN
			'002'
		WHEN 47 THEN
			'001'
		ELSE
			''
		END AS p3,
		SUM(money) AS income,
		COUNT(DISTINCT orderid) AS orders
	FROM
		dm_boss.t_new_order_4_data
	WHERE
		dt = '${yesterday//-/}'
	AND orderpaytype != - 1
	AND terminal = 130
	AND ordertype != '1001'
	AND terminal2 IN (41, 42, 47)
	AND STATUS = 1
	AND neworxufei in (0, 1)
	GROUP BY
		userid,
		neworxufei,
		terminal2
	) b ON (a.uid = b.userid AND a.p3 = b.p3)
	GROUP BY
		a.act_code,
		a.act_fl,
		a.act_fragid,
		a.act_scid,
		a.act_name,
		a.act_pageid,
		a.act_wz,
		a.p3,
		b.neworxufei
) q ON (
	p.act_code = q.act_code
	AND p.act_fl = q.act_fl
	AND p.act_fragid = q.act_fragid
	AND p.act_scid = q.act_scid
	AND p.act_name = q.act_name
	AND p.act_pageid = q.act_pageid
	AND p.act_wz = q.act_wz
	AND p.p3 = q.p3
)" >> ./data/mobile_channel.${yesterday//-/}

echo "按name统计${yesterday}日的移动端流量完成"

hive -e "add jar /home/zhaochunlong/boss_stat/common_stat/mobile_action_stat/letv-boss-stat-1.2.jar;
create temporary function split_act as 'com.letv.boss.stat.hive.GenericUDTFSplitAct';
set hive.groupby.skewindata=true;
SELECT
	concat(
		p.act_code,
		'#',
		p.act_fl,
		'#',
		p.act_fragid,
		'#',
		p.act_scid,
		'#',
		p.act_name,
		'#',
		p.act_pageid,
		'#',
		p.act_wz,
		'#',
		p.p3,
		'#',
		p.pv / 2,
		'#',
		p.uv / 2,
		'#',
		q.neworxufei,
		'#',
		q.income,
		'#',
		q.orders,
		'#',
		0,
		'#',
		'${yesterday}'
	)
FROM
	(
		SELECT
			act_code,
			act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz,
			p3,
			count(deviceid) AS pv,
			count(DISTINCT deviceid) AS uv
		FROM
			data_raw.tbl_action_hour t lateral VIEW split_act (act_property) mytable AS act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz
		WHERE
			t.dt = '${yesterday//-/}'
		AND t.p1 = 0
		AND t.act_code IN (0, 17, 19, 25)
		AND t.act_property LIKE '%pageid=%'
		AND NOT t.act_property LIKE '%name=%'
		AND NOT t.act_property LIKE '%fragid=%'
		AND t.deviceid != '-'
		GROUP BY
			act_code,
			act_fl,
			act_fragid,
			act_scid,
			act_name,
			act_pageid,
			act_wz,
			p3
	) p
JOIN (
	SELECT
		a.act_code,
		a.act_fl,
		a.act_fragid,
		a.act_scid,
		a.act_name,
		a.act_pageid,
		a.act_wz,
		a.p3,
		b.neworxufei,
		SUM(b.income) AS income,
		SUM(b.orders) AS orders
	FROM
		(
			SELECT
				act_code,
				act_fl,
				act_fragid,
				act_scid,
				act_name,
				act_pageid,
				act_wz,
				p3,
				deviceid,
				uid
			FROM
				data_raw.tbl_action_hour t lateral VIEW split_act (act_property) mytable AS act_fl,
				act_fragid,
				act_scid,
				act_name,
				act_pageid,
				act_wz
			WHERE
				t.dt = '${yesterday//-/}'
			AND t.p1 = 0
			AND t.act_code IN (0, 17, 19, 25)
			AND t.act_property LIKE '%pageid=%'
			AND NOT t.act_property LIKE '%name=%'
		    AND NOT t.act_property LIKE '%fragid=%'
			AND t.deviceid != '-'
			AND t.uid != '-'
			AND t.uid != ''
		) a
	JOIN (
		SELECT
			userid,
			neworxufei,
			CASE terminal2
		WHEN 41 THEN
			'004'
		WHEN 42 THEN
			'002'
		WHEN 47 THEN
			'001'
		ELSE
			''
		END AS p3,
		SUM(money) AS income,
		COUNT(DISTINCT orderid) AS orders
	FROM
		dm_boss.t_new_order_4_data
	WHERE
		dt = '${yesterday//-/}'
	AND orderpaytype != - 1
	AND terminal = 130
	AND ordertype != '1001'
	AND terminal2 IN (41, 42, 47)
	AND STATUS = 1
	AND neworxufei in (0, 1)
	GROUP BY
		userid,
		neworxufei,
		terminal2
	) b ON (a.uid = b.userid AND a.p3 = b.p3)
	GROUP BY
		a.act_code,
		a.act_fl,
		a.act_fragid,
		a.act_scid,
		a.act_name,
		a.act_pageid,
		a.act_wz,
		a.p3,
		b.neworxufei
) q ON (
	p.act_code = q.act_code
	AND p.act_fl = q.act_fl
	AND p.act_fragid = q.act_fragid
	AND p.act_scid = q.act_scid
	AND p.act_name = q.act_name
	AND p.act_pageid = q.act_pageid
	AND p.act_wz = q.act_wz
	AND p.p3 = q.p3
)" >> ./data/mobile_channel.${yesterday//-/}

echo "排除fragid和name统计${yesterday}日的移动端流量完成"


