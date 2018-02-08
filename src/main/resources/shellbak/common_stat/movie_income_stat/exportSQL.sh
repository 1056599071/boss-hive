#!/bin/sh
#导入影片统计相关信息
echo "开始导入影片收入数据到bosstdy中";

bosstdyIp="10.110.94.162"
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

##导入数据到PAY_MOVIE_STAT
echo "load play data into bosstdy! date=$date";
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "delete from PAY_MOVIE_STAT where date='${date}'; load data local infile './data/movie_income_stat.$date' IGNORE into table PAY_MOVIE_STAT  fields terminated by '\t' (playlist_id,channel_id,user_count,user_ids,income,informal_uv,formal_uv,terminal,viptype,orderpaytype,date);"

done;


echo "导入数据到PAY_MOVIE_STAT表完成，时间范围${startDate} ~ ${endDate}";

