#!/bin/sh
#计算超级手机端影片收入，并导入到200的统计库中
echo "start load data to infobright!!!";
infobrightIp="10.118.28.200"
infobrightUser=infobright
infobrightPassword=infobright
infobrightDatebase=boss_stat

#循环遍历某段时间内的每一天，范围为：startDate ~ endDate-1
startDate=`date -d "-1 days ago" +%Y%m%d`
endDate=`date -d "0 days ago" +%Y%m%d`
if [ $# -eq 1 ]; then
    startDate=$1
    endDate=$1
fi
if [ $# -eq 2 ]; then
    startDate=$1
    endDate=$2
fi
#一个中间变量
date=${startDate}
#遍历日期
while [[ ${date} < ${endDate} ]]
do
    echo "导入/home/membership02/boss_movie_income/data/movie_income_super.$date到${infobrightIp}的PAY_MOVIE_PLAY表中"
    mysql --default-character-set=utf8 -P 3307 -h ${infobrightIp} -u ${infobrightUser} -p${infobrightPassword} ${infobrightDatebase} -s -N --local-infile=1 -e "load data local infile '/home/membership02/boss_movie_income/data/movie_income_super.$date' IGNORE into table PAY_MOVIE_PLAY fields terminated by '\t' (playlistId,videoId,userid,terminal,playtype,date);"

    sleep 1s;
    echo "导入影片收入数据到${infobrightIp}的PAY_MOVIE_INCOME表中"
    mysql --default-character-set=utf8 -P 3307 -h ${infobrightIp} -u ${infobrightUser} -p${infobrightPassword} ${infobrightDatebase} -s -N -e "
    set @date='$date';
    set @terminal='120';
    #超级手机端专辑的播放次数
    SELECT @allcount:=sum(play.count) from (SELECT count(distinct userid) as count from PAY_MOVIE_PLAY where date=@date and terminal=@terminal GROUP BY date,playlistId) play;
    #超级手机端有观看行为会员的总收入
    SELECT @allincome:=sum(pay.money) from (SELECT distinct userid from PAY_MOVIE_PLAY where date=@date and terminal=@terminal) play
      LEFT JOIN (SELECT userid,money from T_NEW_ORDER_4_DATA where paytime=@date and status='1' and terminal=@terminal and orderpaytype='2' and viptype!='-1') pay  on (pay.userid = play.userid) where pay.money>0;
    #计算超级手机端每个影片的收入并保存到数据库
    INSERT INTO PAY_MOVIE_INCOME(date,playlistId,income,paytype,terminal) SELECT finish.* from
    (SELECT income.date,income.playlistId,income.money,'1' as paytype,@terminal as terminal
     from (SELECT date,playlistId,cast(count(distinct userid)/@allcount*@allincome as decimal(8,2)) as money
     from PAY_MOVIE_PLAY where date=@date and terminal=@terminal GROUP BY playlistId) income) finish;"
    date=`date -d "+1 day $date" +%Y%m%d`
done

if [ "$#" -eq 0 ]; then
#查询专辑的名称
pwd=`pwd`

pwd='/home/membership02/boss_movie_income/stat_hive_todb'

#查询所有的专辑ID
mysql --default-character-set=utf8 -P 3307 -h ${infobrightIp} -u ${infobrightUser} -p${infobrightPassword} ${infobrightDatebase} -e "SELECT daypid.playlistId from (SELECT distinct(playlistId) playlistId from PAY_MOVIE_INCOME) daypid left join PAY_MOVIE allpid on(daypid.playlistId=allpid.playlistId ) where allpid.playlistId is NULL;" > /tmp/playlistid.log

#使用Python调用专辑查询接口
echo "python running"
python ${pwd}/python_playlistName.py

#专辑名称导入到数据库
echo "load data to mysql"
mysql --default-character-set=utf8 -P 3307 -h ${infobrightIp} -u ${infobrightUser} -p${infobrightPassword} ${infobrightDatebase} -s -N --local-infile=1 -e "set character_set_database=utf8;set character_set_server=utf8;load data local infile '/tmp/playlistname.log' IGNORE into table PAY_MOVIE  fields terminated by ',' ;"

fi

echo "导入${infobrightIp}影片收入数据结束，日期范围${startDate} ~ ${endDate}";
