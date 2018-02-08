#!/bin/bash
#该脚本用来统计JSSDK上报的收银台流量，2017-01-09日使用
#以前的上报通过http上报
#该脚本只支持PC端和M站的流量，TV和Mobile端不包括
source ~/.bash_profile;
BASEDIR=`dirname $0`

echo "开始统计收银台流量，当前目录为${BASEDIR}"

cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ $# -eq 1 ]; then
    yesterday=$1
fi

echo "统计的日期为${yesterday}"

pv_data="./data/t_letv_cashier_flow.${yesterday}"

echo "===================开始统计PC端的收银台流量，文件存放内容为：日期、PV、UV、会员类型、终端类型，文件为${pv_data}=================="
echo "查询PC端所有会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, -2, 112, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform  = '0' and cur_url like '%zhifu.le.com/tobuy%'
 GROUP BY dt" > ${pv_data}

echo "查询PC端高级会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, 9, 112, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform  = '0' and cur_url like '%zhifu.le.com/tobuy/pro%'
 GROUP BY dt" >> ${pv_data}

echo "查询PC端普通会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, 1, 112, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform  = '0' and cur_url like '%zhifu.le.com/tobuy/regular%'
 GROUP BY dt" >> ${pv_data}

echo "查询PC端点播会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, -1, 112, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform  = '0' and cur_url like '%zhifu.le.com/tobuy/db%'
 GROUP BY dt" >> ${pv_data}

echo "===============开始统计M站的收银台流量，文件存放内容为：日期、PV、UV、会员类型、终端类型，文件为${pv_data}==========================="
echo "查询M站所有会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, -2, 113, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform IN (1, 2) and cur_url like '%zhifu.le.com/mz/tobuy%'
 GROUP BY dt" >> ${pv_data}

echo "查询M站高级会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, 9, 113, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform IN (1, 2) and cur_url like '%zhifu.le.com/mz/tobuy/pro%'
 GROUP BY dt" >> ${pv_data}

echo "查询M站普通会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, 1, 113, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform IN (1, 2) and cur_url like '%zhifu.le.com/mz/tobuy/regular%'
 GROUP BY dt" >> ${pv_data}

echo "查询M站点播会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct session_id) as uv, -1, 113, 'flow'
 FROM dwb.dwb_megatron_pv_hour
 WHERE dt = '${yesterday}' and prod = 'vipCashier' and country  = 'cn' and platform IN (1, 2) and cur_url like '%zhifu.le.com/mz/tobuy/db%'
 GROUP BY dt" >> ${pv_data}


echo "===================开始统计PC端的登录弹窗流量，文件存放内容为：日期、PV、UV、会员类型、终端类型，文件为${pv_data}=================="
echo "查询PC端所有会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, -2, 112, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform = 0 and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/tobuy%'
 GROUP BY dt" >> ${pv_data}

echo "查询PC端高级会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, 9, 112, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform = 0 and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/tobuy/pro%'
 GROUP BY dt" >> ${pv_data}

echo "查询PC端普通会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, 1, 112, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform  = 0 and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/tobuy/regular%'
 GROUP BY dt" >> ${pv_data}

echo "查询PC端点播会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, -1, 112, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform = 0 and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/tobuy/db%'
 GROUP BY dt" >> ${pv_data}

echo "===============开始统计M站的登录弹窗流量，文件存放内容为：日期、PV、UV、会员类型、终端类型，文件为${pv_data}==========================="
echo "查询M站所有会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, -2, 113, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform IN (1, 2) and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/mz/tobuy%'
 GROUP BY dt" >> ${pv_data}

echo "查询M站高级会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, 9, 113, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform IN (1, 2) and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/mz/tobuy/pro%'
 GROUP BY dt" >> ${pv_data}

echo "查询M站普通会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, 1, 113, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform IN (1, 2) and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/mz/tobuy/regular%'
 GROUP BY dt" >> ${pv_data}

echo "查询M站点播会员的流量"

hive -e "SELECT dt, count(1) as pv, count(distinct letv_cookie) as uv, -1, 113, 'login'
 FROM dwb.dwb_megatron_action_hour
 WHERE dt = '${yesterday}' and platform IN (1, 2) and app_name = 'vipCashier' and props = 'ob_ca=loginPV' and cur_url like '%zhifu.le.com/mz/tobuy/db%'
 GROUP BY dt" >> ${pv_data}

echo "查询PC端和M站的收银台流量完成"