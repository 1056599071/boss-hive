#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

#yesterday=${yesterdays//-/}

echo "开始导入boss_order_${yesterday}.csv文件到t_new_order_4_data表"

hive -e "load data local inpath '/home/zhaochunlong/boss_stat/vip_zhibiao/vip_order_tohive/data/boss_order_${yesterday}.csv' overwrite into table dm_boss.t_new_order_4_data partition(dt='${yesterday}')"

echo "导入文件到t_new_order_4_data表成功"
