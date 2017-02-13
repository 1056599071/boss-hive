#!/usr/bin/env bash
#站内渠道流量统计

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
    yesterday=$1
fi

file=/home/zhaochunlong/shell/channel/data/t_letv_internal_flow_${yesterday}.txt

echo "开始计算${yesterday}日的站内渠道流量收入"

hive -e "add jar /home/zhaochunlong/shell/udf/boss-hive-1.0.jar;
create temporary function splitUrl as 'com.letv.boss.stat.hive.UrlQuerySplitUDF';
select '${yesterday}', a.ref,
 case when b.neworxufei in (0, 1) then b.neworxufei else -1 end AS neworxufei,
 '112',
 count(distinct a.letv_cookie) as pageUv,
 count(distinct b.userid) as payUv,
 sum(coalesce(b.money, 0)) as income
 from
(select m.uid, m.query['ref'] as ref, m.letv_cookie from
(select uid, splitUrl(cur_url) as query, letv_cookie from data_raw.tbl_pv_hour
 where dt = '${yesterday}' and product = 1 and cur_url != '-' and cur_url != '') m
 where m.query['ref'] is not null and m.query['ref'] not like '%http:%' and m.query['ref'] != 'click') a
left outer join
(select userid, money, neworxufei from dm_boss.t_new_order_4_data where dt = '${yesterday}' and terminal = 112 and status = 1 and orderpaytype != -1) b
on (a.uid = b.userid)
group by a.ref, case when b.neworxufei in (0, 1) then b.neworxufei else -1 end" > ${file}


echo "PC端站内渠道流程统计完成..."

hive -e "add jar /home/zhaochunlong/shell/udf/boss-hive-1.0.jar;
create temporary function splitUrl as 'com.letv.boss.stat.hive.UrlQuerySplitUDF';
select '${yesterday}', a.ref,
 case when b.neworxufei in (0, 1) then b.neworxufei else -1 end AS neworxufei,
 '113',
 count(distinct a.letv_cookie) as pageUv,
 count(distinct b.userid) as payUv,
 sum(coalesce(b.money, 0)) as income
 from
(select m.uid, m.query['ref'] as ref, m.letv_cookie from
(select uid, splitUrl(cur_url) as query, letv_cookie from data_raw.tbl_pv_hour
 where dt = '${yesterday}' and product = 0 and p2 in ('04', '05', '06') and cur_url != '-' and cur_url != '') m
 where m.query['ref'] is not null and m.query['ref'] not like '%http:%' and m.query['ref'] != 'click') a
left outer join
(select userid, money, neworxufei from dm_boss.t_new_order_4_data where dt = '${yesterday}' and terminal = 113 and status = 1 and orderpaytype != -1) b
on (a.uid = b.userid)
group by a.ref, case when b.neworxufei in (0, 1) then b.neworxufei else -1 end" >> ${file}

echo "M站站内渠道流量统计完成..."

echo "开始将统计结果导入到mysql数据库中..."

db_ip=10.183.196.100
db_port=3306
db_user=boss_stat_w
db_pass=6b9b3#2137F
db_name=boss_stat

#从mysql查询结果导入到文件中
mysql --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "delete from t_letv_channel_flow where dt = '${yesterday}';
load data local infile '${file}' into table t_letv_channel_flow fields terminated by '\t' lines terminated by '\n' (dt, channel, is_new, terminal, page_uv, pay_uv, income)"

echo "导入数据到mysql中完成..."
