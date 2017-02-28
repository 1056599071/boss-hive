#tr="hello,world,i,like,you,babalala"  
#str=`more ./config_data/rec_config_20150518.csv`
#arr=(${str//,/ })  
  
#for i in ${arr[@]}  
#do  
#    echo $i  
#done



#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

#count=0 ;

for line in `sed '/^[ \t]*$/d' config_data/rec_config_url_$yesterday.csv | awk -F, '{print $0}'`
do
    #((count++))
    arr=(${line//,/ })
    pid=${arr}
    sdate=(${arr[1]//-/})
    edate=(${arr[2]//-/})
    echo $pid $sdate $edate
    arr_url=(${arr[3]//;/ })
    for url in ${arr_url[@]}  
    do
      if [[ $url =~ "yuanxian" ]] 
      then
        hive -e "insert into table dm_boss.tbl_play_record_day partition(dt='$sdate') select distinct uid,'$pid',deviceid,product from data_raw.tbl_pv_hour where dt>='$sdate' and dt<='$edate' and product='1' and ilu='0' and uid!='-' and cur_url like '%$url%'"
        echo "pc="$url
      fi
      if [[ $url =~ "minisite" ]]  
      then
       hive -e "insert into table dm_boss.tbl_play_record_day partition(dt='$sdate') select distinct uid,'$pid',deviceid,product from data_raw.tbl_pv_hour where dt>='$sdate' and dt<='$edate' and product='0' and ilu='0' and uid!='-' and cur_url like '%$url%'"
       echo "h5="$url
      fi
    done 
    echo $line
    #pid=`echo $line | awk -F"'" '{print $2}'`
    #echo "insert overwrite local directory '/home/membership02/boss_stat/play_record_user/data/pid_uid_$pid.$yesterday' select distinct uid,$arr from dm_boss.tbl_play_record_all where dt='$yesterday' and pid in ($line)"
    #hive -e "select distinct uid,$arr from dm_boss.tbl_play_record_all where dt='$yesterday' and pid in ($line)" > ./result_data/pid_uid.$pid
    #awk '{if($1 ~ /^[0-9]+$/) print $0;}' pid_uid.$pid > pid_uid_result.$pid
done 


