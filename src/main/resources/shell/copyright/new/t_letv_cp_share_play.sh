#!/bin/bash
#创建日期：2016-10-26 14:43:00
#创建者：亢雄伟
#作用：该脚本用来查询当日有效的配置专辑信息，并保存到hive的dm_boss.t_letv_cp_share_config中
#然后用该表关联影片日志上报表查询影片的播放次数，播放人数，播放时长和播完次数

source ~/.bashrc
BASEDIR=`dirname $0`
cd $BASEDIR

#专辑配置数据库信息
db_ip=117.121.54.241
db_port=3839
db_user=boss_w
db_pass=454bce2f998e80a
database=share

#测试库数据库信息
#db_ip=10.150.130.21
#db_port=3307
#db_user=vip_letv_test
#db_pass=vip_letv
#database=share

yesterday=`date -d "1 days ago" +%Y%m%d`
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi

log_path=`pwd`/logs/t_letv_cp_share_config_${yesterday}.log
echo "开始查询${yesterday}日的影片配置信息" > $log_path 

filepath=`pwd`/config/t_letv_cp_share_config_${yesterday}.txt
mysql --default-character-set=utf8 -P ${db_port} -h ${db_ip} -u ${db_user} -p${db_pass} ${database} -N -e "SELECT t.id, t.cid, t.cp_name, t.album_id, t.album_name, t.config_type, t.type, t.begin_time, t.end_time, t.ext, t.create_time, t.update_time, t.member_type, t.member_type_name FROM v2_cp_share_config t WHERE t.config_type in (1,3,4) AND t.begin_time <= '${yesterday}' AND t.end_time >= '${yesterday}'" > $filepath

echo "查询${yesterday}日影片配置信息完成,文件存储到${filepath}中" >> ${log_path}

sleep 1s;

echo "开始导入${filepath}到hive的dm_boss.t_letv_cp_share_config中" >> ${log_path}

hive -e "LOAD DATA LOCAL INPATH '${filepath}' OVERWRITE INTO TABLE dm_boss.t_letv_cp_share_config PARTITION (dt='${yesterday}')" >> ${log_path}

echo "导入文件到hive中完成" >> ${log_path}

#定义结果文件，将hive分析结果存入该文件
cp_play_result=`pwd`/play/t_letv_cp_play_result_${yesterday}.txt

echo "文件格式：影片ID，日期，终端，子终端，播放次数，播放人数，播放时长，播完次数，类型，专辑配置ID" >> ${log_path}
echo "开始分端计算付费分成数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', b.prod_termn, b.prod_os, b.play_num, b.play_users, b.play_hours, b.play_times, 1, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 1) a
    join (select pid, prod_termn, prod_os,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid, prod_termn, prod_os) b
    on (a.album_id = b.pid)" > ${cp_play_result}

echo "开始计算总付费分成数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', '-2', '-2', b.play_num, b.play_users, b.play_hours, b.play_times, 1, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 1) a
    join (select pid,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid) b
    on (a.album_id = b.pid)" >> ${cp_play_result}

echo "开始计算播放分成数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', b.prod_termn, b.prod_os, b.play_num, b.play_users, b.play_hours, b.play_times, 3, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 3) a
    join (select pid, prod_termn, prod_os,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0
    group by prod_termn, prod_os, pid) b
    on (a.album_id = b.pid);" >> ${cp_play_result}

echo "开始计算总播放分成数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', '-2', '-2', b.play_num, b.play_users, b.play_hours, b.play_times, 3, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 3) a
    join (select pid,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0
    group by pid) b
    on (a.album_id = b.pid);" >> ${cp_play_result}

echo "开始计算累计时长数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', b.prod_termn, b.prod_os, b.play_num, b.play_users, b.play_hours, b.play_times, 4, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 4) a
    join (select pid, prod_termn, prod_os,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid, prod_termn, prod_os) b
    on (a.album_id = b.pid)" >> ${cp_play_result}

echo "开始计算总累计时长数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', '-2', '-2', b.play_num, b.play_users, b.play_hours, b.play_times, 4, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 4) a
    join (select pid,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid) b
    on (a.album_id = b.pid);" >> ${cp_play_result}

echo "开始导入计算结果到数据库中" >> ${log_path}

mysql --default-character-set=utf8 -P ${db_port} -h ${db_ip} -u ${db_user} -p${db_pass} ${database} -e "DELETE FROM share_play_crm WHERE play_date = '${yesterday}'; LOAD DATA LOCAL INFILE '${cp_play_result}' INTO TABLE share_play_crm FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' (album_id, play_date, terminal, subterminal, play_num, play_users, play_hours, play_times, type, config_id)"

echo "${yesterday}日影片分成数据计算完成" >> ${log_path}

