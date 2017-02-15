#!/bin/sh
###########由于程序历史原因，需要把数据结果数据scp到147############
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

startDate=`date -d "1 days ago" +%Y-%m-%d`
endDate=`date -d "0 days ago" +%Y-%m-%d`

if [ $# -eq 2 ]; then
    startDate=$1
    endDate=$2
fi

./run_movie_income_pc.sh ${startDate//-/}
./run_movie_income_mobile.sh ${startDate//-/}
./run_movie_income_super.sh ${startDate//-/}
./scp_data_147.sh ${startDate//-/}
./run_movie_income_stat.sh ${starDate//-/}
./run_movie_income_first_watch.sh ${starDate//-/}

ssh membership02@10.100.54.147 "/home/membership02/boss_movie_income/stat_hive_todb/run_income.sh ${startDate} ${endDate}"
