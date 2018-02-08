#!/bin/bash
#该脚本用来存储乐视的会员信息

echo "开始创建表t_letv_vip_order..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.t_letv_vip_order (

)
COMMENT '乐视网影视会员全量表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"
echo "创建表t_letv_vip_order完成"
