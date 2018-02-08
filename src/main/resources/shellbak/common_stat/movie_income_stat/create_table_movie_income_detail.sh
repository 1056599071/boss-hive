#!/bin/bash

echo "开始创建表t_letv_movie_income_detail..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.t_letv_movie_income_detail (
playlist_id STRING COMMENT '专辑ID',
palylist_name STRING COMMENT '专辑名称',
pc_informal_num INT COMMENT 'PC端试看人数 ',
pc_formal_num INT COMMENT 'PC端付费播放人数 ',
mobile_informal_num INT COMMENT '移动端试看人数',  
mobile_formal_num INT COMMENT '移动端付费播放人数', 
lead_informal_num INT COMMENT '领先版试看人数', 
lead_formal_num INT COMMENT '领先版付费播放人数', 
pc_movie_income DECIMAL(10,2) COMMENT 'PC端影片会员收入', 
mobile_movie_income DECIMAL(10,2) COMMENT '移动端影片会员收入', 
lead_movie_income DECIMAL(10,2) COMMENT '领先版影片会员收入', 
single_income DECIMAL(10,2) COMMENT '点播收入' 
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"
echo "创建表t_letv_movie_income_detail完成"

