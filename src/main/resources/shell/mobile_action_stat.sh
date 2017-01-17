#!/usr/bin/env bash

echo "统计字段如下：" > kangxiongwei.log

echo "日期，终端，推广位，点击数UV，点击产生的订单人数UV，点击产生的成功订单人数UV" >> kangxiongwei.log

echo "================================统计安卓端的数据======================================" >> kangxiongwei.log

echo "安卓半屏试看" >> kangxiongwei.log

hive -e "SELECT a.dt, '001', 'fl=c62&name=0022&pageid=031',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c62' AND act_property ['name'] = '0022' AND act_property ['pageid'] = '031' AND p3 = '001') a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt" >> kangxiongwei.log

echo "安卓半屏去广告" >> kangxiongwei.log

hive -e "SELECT a.dt, '001', 'fl=c61&pageid=031&wz=1',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c61' AND act_property ['wz'] = '1' AND act_property ['pageid'] = '031' AND p3 = '001') a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt" >> kangxiongwei.log

echo "安卓全屏试看" >> kangxiongwei.log

hive -e "SELECT a.dt, '001', 'fl=c62&name=0022&pageid=032',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c62' AND act_property ['name'] = '0022' AND act_property ['pageid'] = '032' AND p3 = '001') a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt" >> kangxiongwei.log

echo "安卓全屏去广告" >> kangxiongwei.log

hive -e "SELECT a.dt, '001', 'fl=c61&wz=1&pageid=032',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c61' AND act_property ['wz'] = '1' AND act_property ['pageid'] = '031' AND p3 = '001') a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt" >> kangxiongwei.log


echo "===================================统计iPhone端的数据====================================" >> kangxiongwei.log

echo "半屏试看中" >> kangxiongwei.log

hive -e "SELECT a.dt, a.p3, 'fl=c62&name=0022&pageid=031&wz=1',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, p3, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c62' AND act_property ['name'] = '0022' AND act_property ['pageid'] = '031'
      AND act_property ['wz'] = '1' AND p3 IN ('002', '004')) a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt, a.p3" >> kangxiongwei.log

echo "半屏试看结束" >> kangxiongwei.log

hive -e "SELECT a.dt, a.p3, 'fl=c62&name=0022&pageid=031&wz=2',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, p3, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c62' AND act_property ['name'] = '0022' AND act_property ['pageid'] = '031'
      AND act_property ['wz'] = '2' AND p3 IN ('002', '004')) a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt, a.p3" >> kangxiongwei.log

echo "半屏去广告" >> kangxiongwei.log

hive -e "SELECT a.dt, a.p3, 'fl=c61&pageid=031&wz=1',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, p3, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c61' AND act_property ['pageid'] = '031'
      AND act_property ['wz'] = '1' AND p3 IN ('002', '004')) a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt, a.p3" >> kangxiongwei.log

echo "全屏试看中" >> kangxiongwei.log

hive -e "SELECT a.dt, a.p3, 'fl=c62&name=0022&pageid=032&wz=1',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, p3, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c62' AND act_property ['name'] = '0022' AND act_property ['pageid'] = '032'
      AND act_property ['wz'] = '1' AND p3 IN ('002', '004')) a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt, a.p3" >> kangxiongwei.log

echo "全屏试看结束" >> kangxiongwei.log

hive -e "SELECT a.dt, a.p3, 'fl=c62&name=0022&pageid=032&wz=2',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, p3, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c62' AND act_property ['name'] = '0022' AND act_property ['pageid'] = '032'
      AND act_property ['wz'] = '2' AND p3 IN ('002', '004')) a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt, a.p3" >> kangxiongwei.log

echo "全屏去广告" >> kangxiongwei.log

hive -e "SELECT a.dt, a.p3, 'fl=c61&pageid=032&wz=1',
    sum(COALESCE(a.act_times, 0)) AS uv,
    count(DISTINCT b.userid) AS uuv,
    count(DISTINCT CASE WHEN b.status = 1 THEN b.userid END) AS suuv
    FROM
    (SELECT uid, act_times, p3, dt FROM data_sum.sum_user_act_day WHERE dt >= '20161230' AND dt < '20170113' AND product = 'mobile_cli'
     AND act_code = 0 AND act_property ['fl'] = 'c61' AND act_property ['pageid'] = '032'
      AND act_property ['wz'] = '1' AND p3 IN ('002', '004')) a
    LEFT JOIN
    (SELECT userid, status FROM dm_boss.t_new_order_4_data WHERE dt >= '20161230' AND dt < '20170113' AND terminal = '130') b
    ON (a.uid = b.userid)
    GROUP BY a.dt, a.p3" >> kangxiongwei.log


echo "查询结束...........请查看kangxongwei.log"


