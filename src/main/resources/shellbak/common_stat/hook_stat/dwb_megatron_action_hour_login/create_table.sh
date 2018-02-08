#!/bin/bash

echo "开始创建表le_card_record..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.dwb_megatron_action_hour_login (
        uid_cookie STRING,
        letv_cookie STRING,
        props STRING
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"
echo "创建表dwb_megatron_action_hour_login完成"
