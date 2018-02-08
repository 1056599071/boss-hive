#!/bin/bash
#该脚本用于创建影片分成相关表

echo "开始创建表cp_share_config..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.cp_share_config (
	id INT COMMENT '配置库ID',
	cid STRING COMMENT '版权公司ID',
	cp_name STRING COMMENT '版权公司名称',
	album_id INT COMMENT '专辑ID',
	album_name STRING COMMENT '专辑名称',	
	config_type INT COMMENT '分成类型1:付费分成,2:CPM分成,3:播放分成,4:累计时长',
	type INT COMMENT '粒度类型:1.cp粒度,2.专辑粒度',
	begin_time STRING COMMENT '限期开始时间',
	end_time STRING COMMENT '限期结束时间',
	ext STRING COMMENT '扩展字段',
	create_time STRING COMMENT '创建时间',
	update_time STRING COMMENT '更新时间',
	member_type INT COMMENT '会员类型',
	member_type_name STRING COMMENT '会员类型名称'
)
COMMENT '当日有效版权专辑配置表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"
echo "创建表cp_share_config完成"
