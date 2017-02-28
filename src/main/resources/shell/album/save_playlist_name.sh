
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


#查询专辑的名称
pwd=`pwd`
echo $pwd
#pwd='/home/membership02/boss_movie_income/stat_hive_todb'

#查询所有的专辑ID
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -e "SELECT daypid.playlistId from (SELECT distinct(playlist_id) playlistId from PAY_MOVIE_STAT) daypid left join PAY_MOVIE allpid on(daypid.playlistId=allpid.playlistId ) where allpid.playlistId is NULL;" > /tmp/playlistid.log

#使用Python调用专辑接口查询影片名称
echo "python running"
python $pwd/python_playlistName.py
echo "python 查询专辑名称结束"

#专辑名称导入到数据库
mysql --default-character-set=utf8  -P 3829 -h $bosstdyIp -u $bosstdyUser -p$bosstdyPassword $bosstdyDatebase -s -N --local-infile=1 -e "set character_set_database=utf8;set character_set_server=utf8;load data local infile '/tmp/playlistname.log' IGNORE into table PAY_MOVIE  fields terminated by ',' ;"
echo "导入专辑名称完成"
