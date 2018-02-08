#!/bin/sh
#将超级手机影片数据导入到bosstdy中
echo "开始导入超级手机的影片收入数据到bosstdy库中";

bosstdyIp="10.110.94.162"
bosstdyUser=bosstdy_w
bosstdyPassword=4f0aedbb8955ce8
bosstdyDatebase=bosstdy
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
    date2=`date -d "+0 day $date" +%Y-%m-%d`
    #导入订单数据
    echo "正在处理${date}的数据"

    ##导入播放数据
    echo "导入/home/boss/shell/hive/common_stat/movie_income_stat/data/movie_income_super.${date}到134的PAY_MOVIE_PLAY表";
    mysql --default-character-set=utf8 -P 3829 -h ${bosstdyIp} -u ${bosstdyUser} -p${bosstdyPassword} ${bosstdyDatebase} -s -N --local-infile=1 -e "set @date='$date';delete from PAY_MOVIE_PLAY where date=@date and terminal=120;load data local infile '/home/boss/shell/hive/common_stat/movie_income_stat/data/movie_income_super.$date' IGNORE into table PAY_MOVIE_PLAY fields terminated by '\t' (playlistId,videoId,userid,terminal,playtype,date);"

    sleep 1s;
    ##计算影片收入
    echo "开始计算影片收入，最后导到134的PAY_MOVIE_INCOME库中"
    mysql --default-character-set=utf8 -P 3829 -h ${bosstdyIp} -u ${bosstdyUser} -p${bosstdyPassword} ${bosstdyDatebase} -s -N -e "
    set @date='$date';
    set @terminal='120';
    #PC端专辑的播放次数
    SELECT @allcount:=sum(play.count) from (SELECT count(distinct userid) as count from PAY_MOVIE_PLAY where date=@date and terminal=@terminal GROUP BY date,playlistId) play;
    #PC端有观看行为会员的总收入
    SELECT @allincome:=sum(pay.money) from (SELECT distinct userid from PAY_MOVIE_PLAY where date=@date and terminal=@terminal) play
      LEFT JOIN (SELECT userid, money from T_NEW_ORDER_DAY where paytime=@date and status='1' and terminal=@terminal and orderpaytype='2' and viptype!='-1') pay on (pay.userid = play.userid) where pay.money>0;

    delete from PAY_MOVIE_INCOME where date=@date and terminal=@terminal;
    #计算PC端每个影片的收入并保存到数据库
    INSERT INTO PAY_MOVIE_INCOME(date,playlistId,income,paytype,terminal) SELECT finish.* from
    (SELECT income.date,income.playlistId,income.money,'1' as paytype,@terminal as terminal
     from (SELECT date,playlistId,cast(count(distinct userid)/@allcount*@allincome as decimal(8,2)) as money
     from PAY_MOVIE_PLAY where date=@date and terminal=@terminal GROUP BY playlistId) income) finish;"
    echo "导入影片信息到${bosstdyIp}PAY_MOVIE表中"
    sh ./save_playlist_name.sh ${date}
    date=`date -d "+1 day $date" +%Y%m%d`
done
echo "导入${bosstdyIp}影片收入数据结束，日期范围${startDate} ~ ${endDate}";
