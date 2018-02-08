#!/bin/sh

echo "start load data to infobright!!!";
#mysqlIp="117.121.54.161"
#mysqlUser=vip_letvuser
#mysqlPassword=5iyw9DdOF2jKoBHDRZq5
#mysqlDatabase=vip_letv

#mysqlIp="117.121.54.161"
#mysqlUser=vip_letvuser
#mysqlPassword=5iyw9DdOF2jKoBHDRZq5
#mysqlDatabase=vip_letv
bosstdyIp="117.121.54.134"
bosstdyUser=bosstdy_w
bosstdyPassword=4f0aedbb8955ce8
bosstdyDatebase=bosstdy


infobrightIp=10.110.154.80
infobrightUser=infobright
infobrightPassword=infobright
infobrightDatebase=boss_stat

#i=1;  
#date=`date -d"$i days ago " "+%Y-%m-%d"`;
#dayFile=/letv/data/infobright/load/mysql_order_$date.txt;

#date=$1;
#date2=$2;
date1=$1
date2=$2
pid=$3


#dayFile=/home/membership02/boss_movie_income/data/letv_vip_order_$date.txt
#echo "dayFile=$dayFile";
	
##
echo "select data from mysql!";
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p $bosstdyPassword $bosstdyDatebase -e "select t1.a,
       t1.dayincome,
       t2.weekincome,
       t3.monthincome,
       t4.totalincome,
       t5.dianboincome
  from (select sum(income) as dayincome, playListId as a
          from PAY_MOVIE_INCOME
         WHERE playListId = '10007949'
           and date = '20150123'
         group by playListId) t1
  left join (select sum(income) as weekincome, playListId as a
               from PAY_MOVIE_INCOME
              WHERE playListId = '10007949'
                and date >= '20150123'
                and date < timestampadd(day, 7, '20150123')
              group by playListId) t2
    on (t1.a = t2.a)
  left join (select sum(income) as monthincome, playListId as a
               from PAY_MOVIE_INCOME
              WHERE playListId = '10007949'
                and date >= '20150123'
                and date < timestampadd(day, 30, '20150123')
              group by playListId) t3
    on (t1.a = t3.a)
  left join (select sum(income) as totalincome, playListId as a
               from PAY_MOVIE_INCOME
              WHERE playListId = '10007949'
                and date >= '20150123'
                and date <= '20150401'
              group by playListId) t4
    on (t1.a = t4.a)
  left join (select sum(income) as dianboincome, playListId as a
               from PAY_MOVIE_INCOME
              WHERE playListId = '10007949'
                and date >= '20150123'
                and date <= '20150401'
                and paytype = 0
              group by playListId) t5
    on (t1.a = t5.a)" >> movie_income.txt	
#sleep 10s;
	
##导入数据仓库
#echo "load data into infobright!";
#mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "load data local infile '$dayFile' IGNORE into table T_NEW_ORDER_4_DATA fields terminated by '\t' IGNORE 1 lines;"


##备库
#mysql --default-character-set=utf8  -P 3307 -h 10.100.54.147 -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "load data local infile '$dayFile' IGNORE into table T_NEW_ORDER_4_DATA fields terminated by '\t' IGNORE 1 lines;"

echo "end!!!";
