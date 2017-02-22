#!/bin/bash
#创建日期：2016-10-26 14:43:00
#创建者：亢雄伟
#作用：该脚本用来查询当日有效的配置专辑信息，并保存到hive的dm_boss.t_letv_cp_share_config中
#然后用该表关联影片日志上报表查询影片的播放次数，播放人数，播放时长和播完次数
#PGC是播放分成
source ~/.bashrc
source ./util/mysql_util.sh
BASEDIR=`dirname $0`
cd ${BASEDIR}

#专辑配置数据库信息
#db_ip=117.121.54.241
#db_port=3839
#db_user=boss_w
#db_pass=454bce2f998e80a
#database=share

#测试库数据库信息
db_ip=10.150.130.21
db_port=3307
db_user=vip_letv_test
db_pass="vip_letv"
database=share

yesterday=`date -d "1 days ago" +%Y%m%d`
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
#定义日志文件
log_path=`pwd`/logs/t_letv_cp_share_config_${yesterday}.log
#定义结果文件，将hive分析结果存入该文件
cp_play_result=`pwd`/play/t_letv_cp_play_result_${yesterday}.txt

echo "文件格式：影片ID，日期，终端，子终端，播放次数，播放人数，播放视频数，播放视频人数，播放时长，播完次数，类型，专辑配置ID" > ${log_path}

#从mysql查询有效配置的影片信息，保存在文件中
function query_cp_config {
filepath=`pwd`/config/t_letv_cp_share_config_${yesterday}.txt
echo "=================开始导入专辑信息到hive中======================="
sql="SELECT t.id, t.cid, t.cp_name, t.album_id, t.album_name, t.config_type, t.type, t.begin_time, t.end_time, t.ext,
 t.create_time, t.update_time, t.member_type, t.member_type_name
 FROM v2_cp_share_config t WHERE t.config_type in (1,3,4) AND t.begin_time <= '${yesterday}' AND t.end_time >= '${yesterday}'"
echo "=======================查询专辑配置信息========================="
echo "${sql}"
echo "============================================================="
mysql --default-character-set=utf8 -P ${db_port} -h ${db_ip} -u ${db_user} -p${db_pass} ${database} -N -e "${sql}" > ${filepath}
echo "=========================查询专辑完成，查询结果保存在${filepath}=========================="
}

#将mysql查询的结果导入到hive的t_letv_cp_share_config表中
function load_cp_config {
if [ "$#" != 1 ]; then
    echo "必须输入文件路径"
    exit 1
fi
filepath=$1
echo "=======================需要导入的文件为${filepath}=============="
hive -e "LOAD DATA LOCAL INPATH '${filepath}' OVERWRITE INTO TABLE dm_boss.t_letv_cp_share_config PARTITION (dt='${yesterday}')"
echo "====================将专辑信息导入到hive中成功==================="
}


#查询配置专辑号
cp_config="SELECT id, album_id FROM dm_boss.t_letv_cp_share_config WHERE dt = '${yesterday}'"
#需要过滤的播放渠道
filter_channel="SELECT ch FROM dim.dim_ch WHERE dt = '${yesterday}'"
#播放数据
play_data="SELECT pid,play_chnl,cv,vv,prod_termn,prod_os,pt,user_id,normal_end_flag FROM dws.dws_flow_play_day WHERE cc='cn' AND dt='${yesterday}' AND pid > 0"
#统计字段
stat_result="sum(CASE WHEN pt > 360 THEN cv ELSE 0 END) AS play_num,
    count(DISTINCT CASE WHEN pt > 360 AND cv > 0 THEN user_id END) AS play_users,
    sum(CASE WHEN pt > 360 THEN vv ELSE 0 END) AS play_video,
    count(DISTINCT CASE WHEN pt > 360 AND vv > 0 THEN user_id END) AS play_video_users,
    sum(CASE WHEN pt > 360 THEN pt ELSE 0 END) AS play_hours,
    sum(CASE WHEN pt > 360 AND normal_end_flag > 0 THEN 1 ELSE 0 END) AS play_times"


#计算付费分成
function query_pay_play {
    echo "开始计算各端付费分成数据" >> ${log_path}

    hive -e "SELECT b.pid, '${yesterday}', b.prod_termn, b.prod_os, b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 1, a.id
    FROM (${cp_config}) a
    JOIN (SELECT pid, prod_termn, prod_os, ${stat_result}
    FROM (SELECT t.* FROM
    (${play_data} AND user_id > 0 AND user_vip_level IN (1, 2)) t LEFT JOIN (${filter_channel}) r ON (t.play_chnl = r.ch) WHERE r.ch IS NULL) m
    GROUP BY m.pid, m.prod_termn, m.prod_os) b ON (a.album_id = b.pid)" > ${cp_play_result}

    echo "开始计算全端付费分成数据" >> ${log_path}

    hive -e "SELECT b.pid, '${yesterday}', -2, -2, b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 1, a.id
    FROM (${cp_config}) a
    JOIN (SELECT pid, prod_termn, prod_os, ${stat_result}
    FROM (SELECT t.* FROM
    (${play_data} AND user_id > 0 AND user_vip_level IN (1, 2)) t LEFT JOIN (${filter_channel}) r ON (t.play_chnl = r.ch) WHERE r.ch IS NULL) m
    GROUP BY m.pid, m.prod_termn, m.prod_os) b ON (a.album_id = b.pid)" > ${cp_play_result}

    echo "付费分成数据计算完成" >> ${log_path}
}


hive -e "select b.pid, '${yesterday}', '-2', '-2', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 1, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 1) a
    join (select pid,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then vv else 0 end) as play_video,
        count(distinct case when pt > 360 and vv > 0 then user_id end) as play_video_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid) b
    on (a.album_id = b.pid)" >> ${cp_play_result}

echo "开始计算播放分成数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', b.prod_termn, b.prod_os, b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 3, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 3) a
    join (select pid, prod_termn, prod_os,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then vv else 0 end) as play_video,
        count(distinct case when pt > 360 and vv > 0 then user_id end) as play_video_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0
    group by prod_termn, prod_os, pid) b
    on (a.album_id = b.pid);" >> ${cp_play_result}

echo "开始计算总播放分成数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', '-2', '-2', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 3, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 3) a
    join (select pid,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then vv else 0 end) as play_video,
        count(distinct case when pt > 360 and vv > 0 then user_id end) as play_video_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0
    group by pid) b
    on (a.album_id = b.pid);" >> ${cp_play_result}

echo "开始计算累计时长数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', b.prod_termn, b.prod_os, b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 4, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 4) a
    join (select pid, prod_termn, prod_os,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then vv else 0 end) as play_video,
        count(distinct case when pt > 360 and vv > 0 then user_id end) as play_video_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid, prod_termn, prod_os) b
    on (a.album_id = b.pid)" >> ${cp_play_result}

echo "开始计算总累计时长数据" >> ${log_path}

hive -e "select b.pid, '${yesterday}', '-2', '-2', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 4, a.id
    from
        (select id, album_id from dm_boss.t_letv_cp_share_config where dt='${yesterday}' and config_type = 4) a
    join (select pid,
        sum(case when pt > 360 then cv else 0 end) as play_num,
        count(distinct case when pt > 360 and cv > 0 then user_id end) as play_users,
        sum(case when pt > 360 then vv else 0 end) as play_video,
        count(distinct case when pt > 360 and vv > 0 then user_id end) as play_video_users,
        sum(case when pt > 360 then pt else 0 end) as play_hours,
        sum(case when pt > 360 and normal_end_flag > 0 then 1 else 0 end) as play_times
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid) b
    on (a.album_id = b.pid);" >> ${cp_play_result}

echo "开始导入计算结果到数据库中" >> ${log_path}


delete ${db_ip} ${db_port} ${db_user} ${db_pass} ${database} "share_play_crm" "play_date = '${yesterday}'"
insert ${db_ip} ${db_port} ${db_user} ${db_pass} ${database} "share_play_crm" ${cp_play_result}

echo "${yesterday}日影片分成数据计算完成" >> ${log_path}

