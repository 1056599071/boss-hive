###########由于程序历史原因，需要把数据结果数据scp到147############
#!/bin/bash
source ~/.bash_profile
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +%Y-%m-%d`
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
echo "开始导入${yesterday}日的影片分成数据"

ssh membership02@10.100.54.147 "/home/membership02/playcrm/playCRM-fromdb.sh $yesterday"

scp membership02@10.100.54.147:/home/membership02/playcrm/albumId.txt /home/zhaochunlong/boss_stat/common_stat/playcrm_stat/data/

echo "正在导入数据到temp.album_id表中"

##drop table album_id;create table IF NOT EXISTS album_id (albumId string) comment 'movie id'  ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' STORED AS TEXTFILE;
hive -e "use temp;drop table album_id;create table IF NOT EXISTS album_id (albumId string, config_type int) comment 'movie id' ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' STORED AS TEXTFILE;load data local inpath '/home/zhaochunlong/boss_stat/common_stat/playcrm_stat/data/albumId.txt' overwrite into table album_id ;";

echo "导入数据到album_id成功，开始查询type=1的数据"

#hive查询
hive -e "SELECT dt, uid, pid, sum(pt) alltimes, product
 FROM (SELECT albumId FROM temp.album_id WHERE config_type = 1) a
 JOIN (SELECT dt, uid, pid, pt, product FROM data_raw.tbl_play_hour
	WHERE dt='${yesterday//-/}' AND uid != '-' AND (property like '%pay=1%' or p1=2 )) p
 ON (p.pid = a.albumId)
 GROUP BY uid,product,dt,pid HAVING alltimes > 0" > ./data/playcrm-type1-${yesterday//-/}.txt

echo "type=1的数据查询完成，开始查询type=3的数据"

hive -e "SELECT dt,uid,pid,sum(pt) alltimes,product
 FROM (SELECT albumId FROM temp.album_id WHERE config_type = 3) a
 JOIN (SELECT dt, uid, pid, pt, product from data_raw.tbl_play_hour
 	WHERE dt='${yesterday//-/}' and uid != '-' and (property like '%pay=1%' or p1 = 2 or property like '%pay=0%')) p
 ON (p.pid = a.albumId)
 group by uid,product,dt,pid having alltimes > 0" > ./data/playcrm-type3-${yesterday//-/}.txt

echo "type=3的数据查询完成，开始查询type=4的数据"

hive -e "SELECT m.* FROM (
SELECT dt, uid, pid, pt, product FROM
(SELECT albumId FROM temp.album_id WHERE config_type = 4) b
 JOIN (SELECT dt, uid, pid, pt, product FROM data_raw.tbl_play_hour
	WHERE dt = '${yesterday//-/}' AND uid != '-' AND (property LIKE '%pay=1%' OR p1 = 2) AND pt != '-' AND pt > 0) p
ON (p.pid = b.albumId)) m
LEFT JOIN (SELECT userid FROM dm_boss.t_new_order_4_data WHERE viptype != -1 AND createtime <= '${yesterday}' AND canceltime >= '${yesterday}') n
ON (m.uid = n.userid)" > ./data/playcrm-type4-${yesterday//-/}.txt

scp /home/zhaochunlong/boss_stat/common_stat/playcrm_stat/data/playcrm-*-${yesterday//-/}.txt membership02@10.100.54.147:/home/membership02/playcrm/

ssh membership02@10.100.54.147 "/home/membership02/playcrm/playCRM-todb.sh $yesterday"
