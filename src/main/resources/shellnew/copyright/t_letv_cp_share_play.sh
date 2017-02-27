#!/bin/bash
#创建日期：2016-10-26 14:43:00
#创建者：亢雄伟
#作用：该脚本用来查询当日有效的配置专辑信息，并保存到hive的dm_boss.t_letv_cp_share_config中
#然后用该表关联影片日志上报表查询影片的播放次数，播放人数，播放时长和播完次数
#PGC是播放分成
source ~/.bashrc
source ../util/date_util.sh
source ../util/mysql_util.sh
source ../util/disk_util.sh
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
db_pass=vip_letv
database=share

yesterday=`getYesterday`
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi
#定义日志文件
log_path=`pwd`/logs/t_letv_cp_share_config_${yesterday}.log
#定义影片配置文件，配置好的影片信息存入改文件
filepath=`pwd`/config/t_letv_cp_share_config_${yesterday}.txt
#定义结果文件，将hive分析结果存入该文件
cp_play_result=`pwd`/play/t_letv_cp_play_result_${yesterday}.txt

#从mysql查询有效配置的影片信息，保存在文件中
function loadAlbumConfig {
    sql="SELECT * FROM v2_cp_share_config t WHERE t.config_type in (1,3,4) AND t.begin_time <= '${yesterday}' AND t.end_time >= '${yesterday}'"
    #执行mysql命令查询数据
    load ${db_ip} ${db_port} ${db_user} ${db_pass} ${database} "${sql}" ${filepath}
    return 0
}

#将mysql查询的结果导入到hive的t_letv_cp_share_config表中
function insertAlbumToHive {
    hive -e "LOAD DATA LOCAL INPATH '${filepath}' OVERWRITE INTO TABLE dm_boss.t_letv_cp_share_config PARTITION (dt='${yesterday}')"
    return 0
}

#将统计结果添加到mysql中
function addAlbumResultToMysql {
    delete ${db_ip} ${db_port} ${db_user} ${db_pass} ${database} "share_play_crm" "play_date = '${yesterday}'"
    columns="album_id, play_date, terminal, subterminal, play_num, play_users, play_video, play_video_users, play_hours, play_times, type, config_id"
    insert ${db_ip} ${db_port} ${db_user} ${db_pass} ${database} "share_play_crm" ${cp_play_result} "${columns}"
    return 0
}

#查询配置专辑号
cp_config="SELECT id, album_id FROM dm_boss.t_letv_cp_share_config WHERE dt = '${yesterday}'"
#需要过滤的播放渠道
filter_channel="SELECT ch FROM dim.dim_ch WHERE dt = '${yesterday}'"
#播放数据
play_data="SELECT vid,play_chnl,cv,vv,pf,app_name,pt,user_id,normal_end_flag
 FROM dws.dws_flow_play_day WHERE cc='cn' AND dt='${yesterday}' AND vid > 0 AND log_type = 'http'"
#统计字段
stat_result="sum(CASE WHEN pt > 360 THEN cv ELSE 0 END) AS play_num,
    count(DISTINCT CASE WHEN pt > 360 AND cv > 0 THEN user_id END) AS play_users,
    sum(CASE WHEN pt > 360 THEN vv ELSE 0 END) AS play_video,
    count(DISTINCT CASE WHEN pt > 360 AND vv > 0 THEN user_id END) AS play_video_users,
    sum(CASE WHEN pt > 360 THEN pt ELSE 0 END) AS play_hours,
    sum(CASE WHEN pt > 360 AND normal_end_flag > 0 THEN 1 ELSE 0 END) AS play_times"
#终端判定
terminal="CASE WHEN pf = 'mc' AND app_name = '00' THEN 'mobile_app' WHEN pf = 'mc' AND app_name != '00' THEN 'mobile_others' ELSE pf END"

#计算付费分成影片播放情况
function payAlbumPlay {
    sql1="select b.pid, '${yesterday}', b.terminal, 'common', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 1, a.id
    from (${cp_config} and config_type = 1) a
    join (select pid, ${terminal} AS terminal, ${stat_result}
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid, ${terminal}) b
    on (a.album_id = b.pid)"

    sql2="select b.pid, '${yesterday}', 'all', 'all', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 1, a.id
    from (${cp_config} and config_type = 1) a
    join (select pid, ${stat_result}
    from dws.dws_flow_play_day
    where cc = 'cn' and dt = '${yesterday}' and pid > 0 and user_id > 0 and user_vip_level in (1,2)
    group by pid) b
    on (a.album_id = b.pid)"

    print "${sql1}"
    hive -e "${sql1}" >> ${cp_play_result}
    print "${sql2}"
    hive -e "${sql2}" >> ${cp_play_result}
}

#计算播放分成数据
function playAlbumPlay {
    sql1="select b.vid, '${yesterday}', b.terminal, 'common', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 3, a.id
    from
     (${cp_config} and config_type = 1) a
    join
     (select m.vid, ${terminal} AS terminal, ${stat_result}
      from (${play_data}) m left join (${filter_channel}) n on (m.play_chnl = n.ch) where n.ch is null group by m.vid, ${terminal}) b
    on (a.album_id = b.vid)"

    sql2="select b.vid, '${yesterday}', 'all', 'all', b.play_num, b.play_users, b.play_video, b.play_video_users, b.play_hours, b.play_times, 3, a.id
    from
     (${cp_config} and config_type = 1) a
    join
     (select m.vid, ${stat_result} from (${play_data}) m left join (${filter_channel}) n on (m.play_chnl = n.ch) where n.ch is null group by m.vid) b
    on (a.album_id = b.vid)"

    print "${sql1}"
    hive -e "${sql1}" >> ${cp_play_result}
    print "${sql2}"
    hive -e "${sql2}" >> ${cp_play_result}
}

function main {
    echo "文件格式：影片ID，日期，终端，子终端，播放次数，播放人数，播放视频数，播放视频人数，播放时长，播完次数，类型，专辑配置ID" > ${log_path}
    echo "开始统计${yesterday}日的影片分成数据" >> ${log_path}

    #执行查询函数
    echo "开始查询专辑配置信息" >> ${log_path}
    loadAlbumConfig
    echo "专辑配置信息查询结束" >> ${log_path}

#    echo "开始将专辑配置信息导入到Hive中" >> ${log_path}
#    insertAlbumToHive
#    echo "将专辑配置信息导入到Hive中结束" >> ${log_path}

    echo "开始删除${filepath}文件" >> ${log_path}
    delete_file ${cp_play_result}
    echo "删除${filepath}文件成功" >> ${log_path}

    echo "开始查询付费分成数据" >> ${log_path}
    payAlbumPlay
    echo "付费分成数据查询结束" >> ${log_path}

    echo "开始查询播放分成数据" >> ${log_path}
    playAlbumPlay
    echo "播放分成数据查询结束" >> ${log_path}

    echo "开始将统计结果导入到Mysql中" >> ${log_path}
    addAlbumResultToMysql
    echo "将统计结果导入到Mysql中结束" >> ${log_path}

    echo "${yesterday}日影片分成数据统计完成" >> ${log_path}
}

#执行main方法
main



