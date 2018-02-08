#!/bin/sh

infobrightIp="10.110.154.80"
infobrightUser=infobright
infobrightPassword=infobright
infobrightDatebase=boss_stat

date=`date -d"1 days ago " "+%Y%m%d"`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   date=$1
fi

pwd=`pwd`
echo $pwd
pwd='/home/membership02/boss_movie_income/stat_hive_todb'

echo "select pid"
mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -e "SELECT daypid.playlistId from (SELECT distinct(playlistId) playlistId from PAY_MOVIE_INCOME where date>=$date) daypid left join PAY_MOVIE allpid on(daypid.playlistId=allpid.playlistId ) where allpid.playlistId is NULL;" > /tmp/playlistid.log

echo "python running"
python $pwd/python_playlistName.py


echo "load data to mysql"
mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "set character_set_database=utf8;set character_set_server=utf8;load data local infile '/tmp/playlistname.log' IGNORE into table PAY_MOVIE  fields terminated by ',' ;"

sleep 1s;

echo "end!!!";
