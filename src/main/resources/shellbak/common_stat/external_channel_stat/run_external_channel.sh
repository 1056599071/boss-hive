#!/bin/sh
#计算外部渠道带来收入 PC端

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

today=`date +"%Y%m%d"`

if [ "$#" -eq 2 ]; then
  yesterday=$1
  today=$2
fi

hive -e "set hive.groupby.skewindata=false;
SELECT 
    t_play.dt,
    t_play.ref,
    COUNT(DISTINCT COALESCE(t_order.userid, 0)) - 1,
    COUNT(DISTINCT t_play.letv_cookie),
    SUM(COALESCE(t_order.money, 0))
FROM
    (SELECT 
        userid, money, dt
    FROM
        dm_boss.t_new_order_4_data
    WHERE
        dt >= '${yesterday}' AND dt < '${today}'
            AND status = '1'
            AND money != '0'
            AND terminal = '112'
            AND orderpaytype = '2') t_order
        RIGHT OUTER JOIN
    (SELECT DISTINCT
        t2.dt, t1.uid, t2.ref, t2.letv_cookie
    FROM
        (SELECT 
        uid, dt, letv_cookie
    FROM
        data_raw.tbl_pv_hour
    WHERE
        dt >= '${yesterday}' AND dt < '${today}'
            AND product = '1'
            AND uid != '-'
            AND uid != ''
            AND letv_cookie != '-'
            AND letv_cookie != '0'
            AND letv_cookie != ''
            AND ilu = '0') t1
    RIGHT OUTER JOIN (SELECT 
        uid, dt, letv_cookie, PARSE_URL(ref, 'HOST') AS ref
    FROM
        dm_boss.tbl_play_day_boss
    WHERE
        dt >= '${yesterday}' AND dt < '${today}'
            AND p1 = '1'
            AND property LIKE '%pay=0%'
            AND letv_cookie != '-'
            AND letv_cookie != '0'
            AND letv_cookie != '') t2 ON (t1.letv_cookie = t2.letv_cookie
        AND t1.dt = t2.dt)) t_play ON (t_order.userid = t_play.uid
        AND t_order.dt = t_play.dt)
GROUP BY t_play.dt , t_play.ref" >./data/external_channels_income.$yesterday



