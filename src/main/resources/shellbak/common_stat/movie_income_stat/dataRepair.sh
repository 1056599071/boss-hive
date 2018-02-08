#!/bin/sh

source ~/.bash_profile;

for (( i = 8; i>=1; i-- ));do
        date=`date -d"$i days ago " "+%Y%m%d"`;
        echo "${date} 日期数据开始导入"
   #     sh /home/zhaochunlong/boss_stat/common_stat/hook_stat/run.sh $date
sh /home/zhaochunlong/boss_stat/common_stat/movie_income_stat/run_movie_income_stat.sh $date

        echo "${date}日期数据导入完成"
done
