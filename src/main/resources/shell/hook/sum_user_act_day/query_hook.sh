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
 
hook="concat_ws('&', concat('act_code=',act_code), concat('pageid=',act_property['pageid']), concat('fl=',act_property['fl']), concat('wz=',act_property['wz']), concat('name=',act_property['name']))"
#埋点统计
hive -e "
select ${yesterday}, sum(act_times) as pv, count(1) as uv, substr(pcode, 3, 2) as terminal, $hook from data_sum.sum_user_act_day where dt = '${yesterday}' and product = 'mobile_cli' and length(pcode) > 4 and act_code in ('0', '19') and act_property['pageid'] in ('031', '032', '035') and act_property['fl'] in ('b3', 'b31', 'b321', 'b322', 'vp11', 'b32') group by substr(pcode, 3, 2), $hook
" > ./data/query_hook_data.${yesterday}
