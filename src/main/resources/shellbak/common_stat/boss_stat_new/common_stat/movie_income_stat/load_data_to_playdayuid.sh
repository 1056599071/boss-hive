
#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

#过滤出试看用户，登陆试看和未登录试看
#过滤出登陆用户看影片


hive -e "select distinct p1,p2,p3,uid,letv_cookie,deviceid,cid,pid,vid,playtype,property,ref,ilu,zid,liveid,time from data_raw.tbl_play_hour where dt='${yesterday}' and (property like '%pay=0%' or  property like '%pay=1%')" > /home/boss/shell/hive/common_stat/boss_movie_income/data/tbl_play_day_pc.${yesterday} ;



echo "开始导入tbl_play_day_pc.${yesterday}文件到tbl_play_day_boss表"


hive -e "load data local inpath '/home/boss/shell/hive/common_stat/boss_movie_income/data/tbl_play_day_pc.${yesterday}' overwrite into table data_raw.tbl_play_day_boss partition(dt='${yesterday}')"

echo "导入文件到tbl_play_day_boss表成功"

