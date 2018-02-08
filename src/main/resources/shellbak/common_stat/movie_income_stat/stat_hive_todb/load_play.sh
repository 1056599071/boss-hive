#!/bin/sh

echo "start load data to infobright!!!";
#mysqlIp="117.121.54.220"
mysqlIp="117.121.54.161"
mysqlUser=vip_letvuser
mysqlPassword=5iyw9DdOF2jKoBHDRZq5
mysqlDatabase=vip_letv

infobrightIp="10.110.154.80"
infobrightUser=infobright
infobrightPassword=infobright
infobrightDatebase=boss_stat

today=`date -d"0 days ago " "+%Y%m%d"`
startDate=`date -d"1 days ago " "+%Y%m%d"`
endDate=`date -d"1 days ago " "+%Y%m%d"`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   startDate=$1
   endDate=$1
fi
if [ "$#" -eq 2 ]; then
   startDate=$1
   endDate=$2
fi

sys_s_date=`date -d  "$startDate" +%s`
sys_e_date=`date -d   "$endDate" +%s`
sys_t_date=`date -d   "$today" +%s`

interval_s=`expr $sys_t_date - $sys_s_date`
interval_e=`expr $sys_t_date - $sys_e_date`

daycount_s=`expr $interval_s / 3600 / 24`
daycount_e=`expr $interval_e / 3600 / 24`

echo $daycount_s
echo $daycount_e

for (( i = $daycount_s; i>=$daycount_e; i-- ));do
        date=`date -d"$i days ago " "+%Y%m%d"`;

        ##
        echo "load data into infobright! date=$date";
        mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "load data local infile '/home/membership02/boss_movie_income/data/movie_income_pc.$date' IGNORE into table PAY_MOVIE_PLAY  fields terminated by '\t' (playlistId,videoId,userid,terminal,playtype,date);"

        sleep 1s;

done;

if [ "$#" -eq 0 ]; then
#查询专辑的名称
pwd=`pwd`
echo $pwd
pwd='/home/membership02/boss_movie_income/stat_hive_todb'

#查询所有的专辑ID
mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -e "SELECT daypid.playlistId from (SELECT distinct(playlistId) playlistId from PAY_MOVIE_INCOME where date>=$startDate) daypid left join PAY_MOVIE allpid on(daypid.playlistId=allpid.playlistId ) where allpid.playlistId is NULL;" > /tmp/playlistid.log

#使用Python调用专辑查询接口
echo "python running"
python $pwd/python_playlistName.py

#专辑名称导入到数据库
echo "load data to mysql"
mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "set character_set_database=utf8;set character_set_server=utf8;load data local infile '/tmp/playlistname.log' IGNORE into table PAY_MOVIE  fields terminated by ',' ;"

fi


echo "end!!!";
