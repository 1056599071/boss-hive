#!/bin/bash

echo "开始创建表le_card_record..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.le_card_record (
	batch STRING,
	result INT,
	activedate STRING,
	activetime STRING,
	terminal INT,
	cardnumber STRING,
	cardtype INT,
	userid STRING,
	username STRING,
	chargenumber STRING,
	chargetype INT,
	chargeway INT,
	point INT,
	ip STRING,
	meal INT,
	paytype INT,
	corderid STRING,
	source STRING,
	productname STRING,
	amount DECIMAL(10,2),
	device STRING
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"
echo "创建表le_card_record完成"
