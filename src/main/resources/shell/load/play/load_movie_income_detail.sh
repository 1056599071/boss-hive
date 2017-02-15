#!/bin/bash
#创建日期：2017-01-11
#创建者：常岳
#该脚本用来导入boss后台页面统计报表-影片收入-影片收入明细到hive中
source ~/.bashrc
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y-%m-%d"`
if [ $# -eq 1 ]; then
	yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y-%m-%d"`

echo "开始导入${yesterday}~${today}日的数据到hive中"

db_ip=117.121.54.134    #源数据库IP
db_port=3829            #源数据库端口 
db_user=bosstdy_w       #源数据库用户名
db_pass=4f0aedbb8955ce8 #源数据库密码
db_name=bosstdy         #源数据库名称

file=`pwd`/data/movie_income_detail_${yesterday//-/}.txt

#从mysql查询结果导入到文件中
mysql -N --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "
SELECT 
a.playlistId,
b.playlistName,
c.pcInformalNum,
c.pcFormalNum,
c.mobileInformalNum,
c.mobileFormalNum,
c.leadInformalNum,
c.leadFormalNum,
a.pcMovieIncome,
a.mobileMovieIncome,
a.leadMovieIncome,
a.singleincome
FROM (SELECT t.playlistId, SUM(CASE WHEN t.paytype = 1 AND t.terminal = 112 THEN t.income ELSE 0 END) AS pcMovieIncome, 
SUM(CASE WHEN t.paytype = 1 AND t.terminal = 130 THEN t.income ELSE 0 END) AS mobileMovieIncome, SUM(CASE WHEN t.paytype = 1 AND t.terminal = 120 THEN t.income ELSE 0 END) AS leadMovieIncome, 
SUM(CASE WHEN t.paytype = 0 THEN t.income ELSE 0 END) AS singleincome FROM PAY_MOVIE_INCOME t WHERE t.playlistId > 0 AND t.date = '${yesterday}' GROUP BY t.playlistId) a 
LEFT JOIN PAY_MOVIE b ON (a.playlistId = b.playlistId) 
LEFT JOIN (SELECT t.playlistId, COUNT(DISTINCT CASE WHEN t.playtype = 1 AND t.terminal = 112 THEN t.userid END) AS pcFormalNum, 
COUNT(DISTINCT CASE WHEN t.playtype = 0 AND t.terminal = 112 THEN t.userid END) AS pcInformalNum, COUNT(DISTINCT CASE WHEN t.playtype = 1 AND t.terminal = 130 THEN t.userid END) AS mobileFormalNum, 
COUNT(DISTINCT CASE WHEN t.playtype = 0 AND t.terminal = 130 THEN t.userid END) AS mobileInformalNum, COUNT(DISTINCT CASE WHEN t.playtype = 1 AND t.terminal = 120 THEN t.userid END) AS leadFormalNum, 
COUNT(DISTINCT CASE WHEN t.playtype = 0 AND t.terminal = 120 THEN t.userid END) AS leadInformalNum 
FROM PAY_MOVIE_PLAY t WHERE t.playlistId > 0 AND t.date = '${yesterday}' GROUP BY t.playlistId) c ON (a.playlistId = c.playlistId)
;" > ${file}

echo "从数据库查询数据结束，文件名为${file}"

#将文件导入hive表中，覆盖存在的分区
hive -e "LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.t_letv_movie_income_detail PARTITION (dt='${yesterday//-/}')"

echo "导入${file}到hive完成"

