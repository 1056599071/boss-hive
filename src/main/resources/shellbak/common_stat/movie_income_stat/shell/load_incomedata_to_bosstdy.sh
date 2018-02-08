#!/bin/sh
#导入某一天PC端的影片收入明细
db_ip="10.110.94.162"
username=bosstdy_w
password=4f0aedbb8955ce8
database=bosstdy

startDate=`date -d "1 days ago" +%Y-%m-%d`
if [ "$#" -eq 1 ]; then
   startDate=$1
fi
echo "开始导入PC端${startDate}日的影片收入到bosstdy中"

ORDER_DAY_FILE=/home/membership02/boss_movie_income/data/letv_vip_order_${startDate//-/}.txt
PC_MOVIE_FILE=/home/membership02/boss_movie_income/data/movie_income_pc.${startDate//-/}
if [ ! -f "$ORDER_DAY_FILE" ]; then
    scp root@10.118.28.200:/letv/data/infobright/load/mysql_order_${startDate}.txt ${ORDER_DAY_FILE}
fi
mysql --default-character-set=utf8 -P 3829 -h ${db_ip} -u ${username} -p${password} ${database} -s -N --local-infile=1 -e
 "DELETE FROM T_NEW_ORDER_DAY;
 LOAD DATA LOCAL INFILE '$ORDER_DAY_FILE' IGNORE into table T_NEW_ORDER_DAY FIELDS TERMINATED BY '\t' IGNORE 1 LINES;"
rm -rf ${ORDER_DAY_FILE}
mysql --default-character-set=utf8 -P 3829 -h ${db_ip} -u ${username} -p${password} ${database} -s -N --local-infile=1 -e
 "DELETE FROM PAY_MOVIE_PLAY WHERE date=${startDate};
 LOAD DATA LOCAL INFILE '${PC_MOVIE_FILE}' IGNORE into table PAY_MOVIE_PLAY fields terminated by '\t' (playlistId,videoId,userid,terminal,playtype,date);"

sleep 1s;

mysql --default-character-set=utf8 -P 3829 -h ${db_ip} -u ${username} -p${password} ${database} -s -N -e "
SELECT @allcount:=sum(play.count) FROM (SELECT count(distinct userid) as count from PAY_MOVIE_PLAY where date=${startDate} and terminal=112 GROUP BY date,playlistId) play;
SELECT @allincome:=sum(pay.money) FROM (SELECT distinct userid from PAY_MOVIE_PLAY where date=${startDate} and terminal=112) play
  LEFT JOIN (SELECT userid,money from T_NEW_ORDER_DAY where paytime=${startDate} and status='1' and terminal=112 and orderpaytype='2' and viptype!='-1') pay ON (pay.userid = play.userid) where pay.money > 0;

DELETE FROM PAY_MOVIE_INCOME WHERE date=${startDate} and terminal=112;
#计算PC端每个影片的收入并保存到数据库
INSERT INTO PAY_MOVIE_INCOME(date,playlistId,income,paytype,terminal) SELECT finish.* FROM
(SELECT income.date,income.playlistId,income.money,'1' as paytype,'112' as terminal
 FROM (SELECT date,playlistId,cast(count(distinct userid)/@allcount*@allincome as decimal(8,2)) as money
 FROM PAY_MOVIE_PLAY WHERE date=${startDate} and terminal=112 GROUP BY playlistId) income) finish ;
#点播的收入,所有终端只计算一次
INSERT INTO PAY_MOVIE_INCOME(date,playlistId,income,paytype,terminal) SELECT finish.* FROM
(SELECT pay.paytime as date,pay.aid2 as playlistId,pay.money ,'0' as paytype,pay.terminal from (SELECT paytime,aid2,sum(money) as money,terminal from T_NEW_ORDER_DAY
  where paytime=${startDate} and status='1' and orderpaytype='2' and viptype='-1' and orderfrom='1' GROUP BY aid2,terminal) pay where pay.money>0 ) finish;
"
#专辑名称导入到数据库
if [ "$#" -eq 1 ]; then
sh ./save_playlist_name.sh
fi
echo "导入${startDate}日PC端影片收入明细结束";
