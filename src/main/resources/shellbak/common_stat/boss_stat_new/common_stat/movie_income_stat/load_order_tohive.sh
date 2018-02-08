#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


yesterdays=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  yesterdays=$1
fi

yesterday=${yesterdays//-/}

echo "开始导入boss_order_${yesterdays}.csv文件到t_new_order_4_data表"

hive -e "load data local inpath '/home/boss/shell/hive/common_stat/boss_movie_income/data/boss_order_${yesterdays}.csv' overwrite into table data_raw.t_new_order_4_data partition(dt='${yesterday}')"

echo "导入文件到t_new_order_4_data表成功"
