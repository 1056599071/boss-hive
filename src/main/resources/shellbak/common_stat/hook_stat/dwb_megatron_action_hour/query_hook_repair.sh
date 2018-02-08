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
 
#埋点统计
#hive -e "select ${yesterday}, count(1) pv, count(distinct letv_cookie) uv, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) from dwb.dwb_megatron_action_hour t where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])" > ./data/query_hook_data.${yesterday}


hive -e "select ${yesterday}, count(1) pv, count(distinct letv_cookie) uv, props from dwb.dwb_megatron_action_hour where dt = '${yesterday}' and (props like 'ch=zhifu&pg=tobuy%' or props like 'ch=zhifu&pg=mtobuy%') group by props" > ./data/query_hook_data.${yesterday}
