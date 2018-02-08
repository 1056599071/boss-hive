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

infobrightIp=10.110.154.80
infobrightUser=infobright
infobrightPassword=infobright
infobrightDatebase=boss_stat

#i=1;  
#date=`date -d"$i days ago " "+%Y-%m-%d"`;
#dayFile=/letv/data/infobright/load/mysql_order_$date.txt;

date=$1;
date2=$2;


dayFile=/home/boss/shell/hive/common_stat/movie_income_stat/data/letv_vip_order_$date.txt
echo "dayFile=$dayFile";
	
##
echo "select data from mysql!";
mysql --default-character-set=utf8 -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase  -e "SELECT orderid,money,status,left(createtime,11) as createtime,left(canceltime,11) as canceltime,ordertype,aid,orderfrom,aid2,runningnumber,videoid,paytype,left(paytime,11) as paytime,right(paytime,8) as payHour,userip,pakbuycount,payChannel,suborderfrom,model,userid,terminal as t,terminal2 as t2,viptype as v,orderpaytype as o,orderpaytype1 as o1,neworxufei as n from T_NEW_ORDER_4_DATA where paytime>='$date' and paytime<'$date2'" > $dayFile;	
#sleep 10s;
	
##导入数据仓库
#echo "load data into infobright!";
#mysql --default-character-set=utf8  -P 3307 -h $infobrightIp -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "load data local infile '$dayFile' IGNORE into table T_NEW_ORDER_4_DATA fields terminated by '\t' IGNORE 1 lines;"


##备库
#mysql --default-character-set=utf8  -P 3307 -h 10.100.54.147 -u $infobrightUser -p$infobrightPassword $infobrightDatebase -s -N --local-infile=1 -e "load data local infile '$dayFile' IGNORE into table T_NEW_ORDER_4_DATA fields terminated by '\t' IGNORE 1 lines;"

echo "end!!!";
