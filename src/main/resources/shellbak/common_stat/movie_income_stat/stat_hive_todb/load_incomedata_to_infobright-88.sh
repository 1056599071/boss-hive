#!/bin/sh

echo "start load data to infobright!!!";
#mysqlIp="117.121.54.220"
mysqlIp="117.121.54.161"
mysqlUser=vip_letvuser
mysqlPassword=5iyw9DdOF2jKoBHDRZq5
mysqlDatabase=vip_letv

#infobrightIp="10.110.154.80"
#infobrightUser=infobright
#infobrightPassword=infobright
#infobrightDatebase=boss_stat

bosstdyIp="10.110.154.80"
bosstdyUser=infobright
bosstdyPassword=infobright
bosstdyDatebase=boss_stat

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
        date=`date -d"$i days ago " "+%Y%m%d"`
        date2=`date -d"$i days ago " "+%Y-%m-%d"`

	##导入订单数据
	echo "load order data into bosstdy! date=$date";
        orderDayFile=/home/membership02/boss_movie_income/data/letv_vip_order_$date.txt
	#判断文件是否已经存在，否则从院线查询订单
	if [ ! -f "$orderDayFile" ]; then
       	    scp root@10.110.154.80:/letv/data/infobright/load/mysql_order_$date2.txt $orderDayFile
	fi
	mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "delete from T_NEW_ORDER_DAY;load data local infile '$orderDayFile' IGNORE into table T_NEW_ORDER_DAY fields terminated by '\t' IGNORE 1 lines;"
        rm -rf $orderDayFile

        ##导入播放数据
        echo "load play data into bosstdy! date=$date";
        mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "load data local infile '/home/membership02/boss_movie_income/data/movie_income_pc.$date' IGNORE into table PAY_MOVIE_PLAY  fields terminated by '\t' (playlistId,videoId,userid,terminal,playtype,date);"

        sleep 1s;
        ##计算影片收入	
	mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N -e "
set @date='$date';
set @terminal='112';
#PC端专辑的播放次数
SELECT @allcount:=sum(play.count)  from (SELECT count(distinct userid) as count from PAY_MOVIE_PLAY where date=@date and terminal=@terminal GROUP BY date,playlistId) play; 
#PC端有观看行为会员的总收入
SELECT @allincome:=sum(pay.money) from (SELECT distinct userid from PAY_MOVIE_PLAY where date=@date and terminal=@terminal) play 
  left JOIN (SELECT userid,money from T_NEW_ORDER_DAY where paytime=@date and status='1' and terminal=@terminal and orderpaytype='2' and viptype!='-1') pay  on (pay.userid = play.userid) where pay.money>0;  
#计算PC端每个影片的收入并保存到数据库
INSERT INTO PAY_MOVIE_INCOME(date,playlistId,income,paytype,terminal) SELECT finish.* from 
(SELECT income.date,income.playlistId,income.money,'1' as paytype,'112' as terminal  
 from (SELECT date,playlistId,cast(count(distinct userid)/@allcount*@allincome as decimal(8,2)) as money 
	from PAY_MOVIE_PLAY where date=@date and terminal=@terminal GROUP BY playlistId) income) finish ;
#点播的收入,所有终端只计算一次 
INSERT INTO PAY_MOVIE_INCOME(date,playlistId,income,paytype,terminal) SELECT finish.* from 
(SELECT pay.paytime as date,pay.aid2 as playlistId,pay.money ,'0' as paytype,pay.terminal from (SELECT paytime,aid2,sum(money) as money,terminal from T_NEW_ORDER_DAY  
  where paytime=@date and status='1'  and orderpaytype='2' and viptype='-1' and orderfrom='1' GROUP BY aid2,terminal) pay  where pay.money>0 ) finish;
"

done;

#专辑名称导入到数据库
if [ "$#" -eq 1 ]; then

./save_playlist_name.sh

fi


echo "end!!!";
