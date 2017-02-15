#!/bin/sh
#source ~/.bashrc #很重要,不然hive指令不执行

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#分隔符
yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi

echo "正在导入${yesterday}的埋点PV和UV数据"

hook="concat('cur_url=',cur_url)"

#页面PVUV
hive -e"
select ${yesterday}, count(1) as pv, count(distinct dvc_id) as uv, 111 as terminal, $hook from dwd.dwd_flow_log_pv_day where dt = '${yesterday}' and p1 = '2' and p2 = '21' and cur_url in ('1000942', '1000943', '1000944') group by $hook;
" > ./data/query_hook_data.${yesterday}

#点击PVUV
hook="concat_ws('&', concat('cur_url=',cur_url), concat('rank=',recom_rank))"

hive -e "
select ${yesterday}, count(1) as pv, count(distinct dvc_id) as uv, 111 as terminal, $hook from dwd.dwd_flow_log_action_day where dt = '${yesterday}' and p1 = '2' and p2 = '21' and cur_url in ('1000942', '1000943', '1000944') group by $hook;
" >> ./data/query_hook_data.${yesterday}
