#!/usr/bin/env bash
#会员播放活跃分析
#创建日期：2017-02-28 14:43:00
#创建者：亢雄伟
#作用：站内渠道流量统计，该脚本会解析PV表中cur_url包含ref的部分
#按照ref进行分组统计每个渠道带来的收入

source ~/.bash_profile;
source ../util/date_util.sh
source ../util/mysql_util.sh
source ../util/disk_util.sh

BASEDIR=`dirname $0`
cd ${BASEDIR}

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
    yesterday=$1
fi

log=`pwd`/logs/t_letv_play_dau_${yesterday}.log

file=`pwd`/data/t_letv_play_dau_${yesterday}.txt


#分析活跃会员数据
function activeVipPlay {
    #媒资表中付费影片
    dmm="select distinct pid from dmm.gsql_vid_pid_info_merge_trunk where dt = '${yesterday}' and pid > 0 and is_pay = 1"
    #影片播放表中查询播放量
    dws="select user_id, cv, coalesce(pt, 0) as pt, dvc_id, pid from dws.dws_flow_play_day where dt = '${yesterday}' and log_type = 'http' and cc = 'cn' and cv > 0"
    #查询会员信息表
    vip="select distinct userid, orderpaytype from dm_boss.t_new_order_4_data where status = 1 and dt <= '${yesterday}'"
    #所有影片播放信息
    sql1="select m.*, case when n.pid is null then 0 else 1 end as is_pay from (${dws}) m left join (${dmm}) n on (m.pid = n.pid)"

    result="count(distinct a.userid) as vipuv,
        count(distinct case when b.pid > 0 then a.userid end) as vipcvuv,
        count(distinct case when b.is_pay = 1 then a.userid end) as vippaycvuv,
        sum(b.cv) as cv,
        sum(case when b.is_pay = 1 then b.cv else 0 end) as paycv,
        sum(b.pt)/60 as pt"

    #拼接sql
    sql="select ${result} from (${vip}) a join (${sql1}) b on (a.userid = b.user_id)" > ${file}
    #打印日志，并执行hive语句
    print "${sql}"
    hive -e "${sql}"
}


function main {
    echo "开始计算${yesterday}日的会员活跃分析数据" > ${log}
    activeVipPlay >> ${log}
    echo "${yesterday}日的会员活跃分析数据计算完成" >> ${log}
}

#执行main方法
main