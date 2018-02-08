#!/bin/sh

mysqlIp="117.121.54.220"
mysqlUser=vip_letvuser
mysqlPassword=5iyw9DdOF2jKoBHDRZq5
mysqlDatabase=vip_letv

bosstdyIp="117.121.54.134"
bosstdyUser=bosstdy_w
bosstdyPassword=4f0aedbb8955ce8
bosstdyDatebase=bosstdy

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

        ##导入订单数据
        echo "load order data into bosstdy! date=$date";
        orderDayFile=/home/membership02/boss_movie_income/data/letv_vip_order_$date.txt
        #判断文件是否已经存在，否则从院线查询订单
        if [ ! -f "$orderDayFile" ]; then
        	scp root@10.110.154.80:/letv/data/infobright/load/mysql_order_2015-01-06.txt $orderDayFile
	fi
        #mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "delete from T_NEW_ORDER_4_DATA;load data local infile '$orderDayFile' IGNORE into table T_NEW_ORDER_4_DATA fields terminated by '\t' IGNORE 1 lines;"
        #rm -rf $orderDayFile
done;
