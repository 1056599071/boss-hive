#!/bin/bash
###########################################################################################################
# Target Table : dwd.dwd_flow_sdk_beat_hour
# Source Table : data_agnes.agnes_beat_hour t1
#				 data_agnes.agnes_simcard_hour t2
#				 dwd.dwd_res_zhixin_phone_source_day
#				 dwd.dwd_flow_sdk_imei_his_day
#				 dwd.dwd_res_device_trace_his_day
# Interface Name: SDK心跳信息时表
# Refresh Frequency: per hour 每小时处理
# 修改人   修改时间       修改原因 
# ------   -----------    --------------------
# 曾岐峰   2016-03-30     新建脚本
# 曾岐峰   2016-04-05     修改 设备发行地区 dvc_sale_area 字段 口径
# 曾岐峰   2016-05-18     增加 reCheckDONE 函数，如果DONE文件不存在sleep一小时后再重新 checkDONE，直到任务超时，任务才会失败
# 曾岐峰   2016-06-21     phone/letv 分区 增加 common 数据
# 曾岐峰   2016-07-13     sdk_beat表同一设备上报ui_version为- 导致CC出现不同值，取设备上报最早ui_version
# 曾岐峰   2016-08-08     依赖表修改：temp.dwd_flow_sdk_beat_hour_phone_imei_dvcsalearea -> dwd.dwd_flow_sdk_imei_his_day
# 曾岐峰   2016-08-08     依赖表修改：temp.devicetrace -> dwd.dwd_res_device_trace_day
# 曾岐峰   2016-08-11     依赖表修改：dwd.dwd_res_device_trace_day -> dwd.dwd_res_device_trace_his_day
# 郭春明   2016-09-26   美国特殊化: 1) 临时注释代码:join_cc, join_cc2, select_cc
#                                   2) select_cc固定为us, select_region默认为US
#                                   3) 剔除大陆数据
# 郭春明    2016-09-29   美国特殊化: ip解析更改函数
# 栗  刚    2016-09-30   美国特殊化：与simcard表关联改成left join 
# 郭春明    2016-10-12   美国特殊化：传入为美国时间，修改时区转换函数(含源时区、目标时区)
#张俊洁    2016-11-08   取消传参参数platform
###########################################################################################################
#增加国家分区cc逻辑
#乐视商品：
#手机
#dvc_type=phone
#1.IMEI关联dwd_res_zhixin_phone_source_day 取分区cc
#2.关联不到的取beat表dvc_sale_area
#3.其他为CN
#
#电视
#dvc_type=tv
#imei关联devicetrace表mac取area 
#其他为cn
#
#注：devicetrace表中海外数据每日为增量，非land的数据需要先计算查询出历史所有数据

function println(){
 num=$#
 if [ ${num} -eq 2 ]
 then
  #echo "[info] target_table=${target_table}"
  echo "[$1] $2=${!2}"
 else
  str="[$1] "
  for((i=2;i<=$num;i++))
  do
   str="${str} ${!i}"
  done
  #echo "[error] ${target_table} ${deveice_type} ${plat_form}"
  echo "${str}"
 fi
}

target_table=dwd.dwd_flow_sdk_beat_hour
println info target_table

param_num=3
println info param_num

#设置参数
if [ $# -eq ${param_num} ]; then
    TRANS_DATE=$1
    TRANS_HOUR=$2
    deveice_type=$3
    #plat_form=$4
	datetime2=$(date -d"yesterday ${datetime}" +%Y%m%d)
	println info datetime
	println info hours
	println info deveice_type
	#println info plat_form
	println info datetime2	
else
    println error param must be ${param_num}
    exit 1
fi

##特殊变量 begin #####################################################################################
#时区转换为中国 
TZUDF="add jar /letv/release/fbr_dailycomputing/comm_tool/fbrudf-1.0-jar-with-dependencies.jar;
create temporary function TSConvertPSTTime as 'com.bigdata.roi.hive.udf.TSConvertPSTTime';
create temporary function TSConvertPSTTime2 as 'com.bigdata.roi.hive.udf.TSConvertPSTTime2'"

PARA_ARRAY=(`hive -S -e "$TZUDF; SELECT TSConvertPSTTime($TRANS_DATE,$TRANS_HOUR,'PST','GMT+8'), \
                                 substr(TSConvertPSTTime2($TRANS_DATE,$TRANS_HOUR,'PST','GMT+8'),9,2);"`)
datetime=${PARA_ARRAY[0]}
hours=${PARA_ARRAY[1]}
echo datetime=$datetime
echo hours=$hours

select_cc="'us'" 
FILTER_MAINLAND_DATA="nvl(props['agnes_area'] ,'-') <> 'NONE'"  #剔除大陆数据条件
##特殊变量 end #####################################################################################


echo "---------------start check---------------"

FLAG=0
function checkDONE(){
 hadoop fs -test -e $1
 if [ $? -ne 0 ]; then
  echo "[error] $1 not exist"
  FLAG=1;
 else
  echo "[info] $1 exist"
  FLAG=0
 fi
}

function reCheckDONE(){
 while (( $FLAG > 0 ))
 do
  echo "[error] sleep 5 minute, then reCheckDONE"
  sleep 5m
  checkDONE $1
 done
}

function checkPartition(){
sql="show partitions $1 partition($2);"
row=$(hive -e "$sql" | awk 'END{print NR}')
partition_num=$3
if [ $row -eq $partition_num ];then
 echo "[info] $sql Fetched: $row row(s) -eq partition_num $partition_num"
 FLAG=0
else
 echo "[error] $sql Fetched: $row row(s) -ne partition_num $partition_num"
 FLAG=1
fi
}

yd=`date -d "${datetime}" +%Y%m`

#BEAT_DONE_DIR=/user/hive/warehouse/data_agnes.db/beat/201605/20160512/22/phone/DONE
BEAT_DONE_DIR=/user/hive/warehouse/data_agnes.db/beat/${yd}/${datetime}/${hours}/${deveice_type}/DONE
checkDONE $BEAT_DONE_DIR
reCheckDONE $BEAT_DONE_DIR


echo "---------------end check---------------"


if [ "${deveice_type}" = "phone" ];then
    #if [ "${plat_form}" = "letv" ];then
     condition="device in ('letv','common','coolpad')"
    #elif [ "${plat_form}" = "coolpad" ];then
    # condition="device='coolpad'"
    #fi
	##checkDONE /user/hive/warehouse/dwd.db/dwd_res_zhixin_phone_source_day/done/${datetime2}/_DONE
  ##if [ ${FLAG} -eq 1 ];then
	## datetime2=$(date -d"yesterday ${datetime2}" +%Y%m%d)
	##fi
  select_region="coalesce(ui_version_parse(t1.build_version)['releaseRegion'],'US')"
	##join_cc="left outer join (select distinct imei,cc from dwd.dwd_res_zhixin_phone_source_day where dt='${datetime2}') t3 on upper(COALESCE(t1.props['imei'],'-'))=upper(t3.imei)"
	##
	##datetime2=$(date -d"yesterday ${datetime}" +%Y%m%d)
	##checkDONE /user/hive/warehouse/dwd.db/dwd_flow_sdk_imei_his_day/done/${datetime2}/phone_DONE
  ##if [ ${FLAG} -eq 1 ];then
	## datetime2=$(date -d"yesterday ${datetime2}" +%Y%m%d)
	##fi
	##println info datetime2 
	##join_cc2="left outer join (select imei,cc from dwd.dwd_flow_sdk_imei_his_day where dvc_type='${deveice_type}' and pf='${plat_form}' and dt='${datetime2}') t4 on upper(COALESCE(t1.props['imei'],'-'))=upper(t4.imei)"
	##select_cc="lower(coalesce(t3.cc,t4.cc,'CN'))"
elif [ "${deveice_type}" = "tv" ];then
    condition="device='letv'"
    select_region="'US'"
	##checkDONE /user/hive/warehouse/dwd.db/dwd_res_device_trace_his_day/done/${datetime2}/_DONE
  ##if [ ${FLAG} -eq 1 ];then
	## datetime2=$(date -d"yesterday ${datetime2}" +%Y%m%d)
	##fi
	##join_cc="left outer join (select mac,cc from dwd.dwd_res_device_trace_his_day where dt='${datetime2}') t3 on upper(COALESCE(t1.props['imei'],'-'))=upper(t3.mac)"
	##select_cc="lower(coalesce(t3.cc,'cn')) as cc"	
fi


#################################################################################
SQL="
add jar /letv/release/udf/dist/ipparse-1.0-us.jar;
add jar /letv/release/data_platform/jar/phoneUIVersionParse.jar;
create temporary function ipparse as 'com.letv.bigdata.udf.ipparse.IpParse';
create temporary function ui_version_parse as 'com.letv.udf.UIVersionParse';
set hive.map.aggr=true;
set hive.groupby.skewindata=true;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.reducers.max=200;
set hive.exec.compress.output=true;
--EXPLAIN
INSERT OVERWRITE TABLE ${target_table} partition (cc,dt,hour,dvc_type,platform)
select 
    COALESCE(t1.start_id,'-')
	,COALESCE(t1.props['imei'],'-')
	,COALESCE(t1.letv_uid,'-')
	,COALESCE(t1.product_vendor,'-')
	,COALESCE(t1.build_version,'-')
	,${select_region}
	,COALESCE(t1.product_model,'-')
	,COALESCE(t1.mac,'-')
	,COALESCE(t1.is_root,'-')
	,COALESCE(t1.cp_version,'-')
	,COALESCE(t1.network_type,'-')
	,COALESCE(t1.ip,'-')
	,COALESCE(ipparse(t1.ip)['countryCode'],'-') as ip_country_code
    ,COALESCE(ipparse(t1.ip)['country'],'-') as ip_country_name
    ,COALESCE(ipparse(t1.ip)['regionCode'],'-') as region_code
    ,COALESCE(ipparse(t1.ip)['region'],'-') as region_name
    ,COALESCE(ipparse(t1.ip)['provinceCode'],'-') as ip_province_code
    ,COALESCE(ipparse(t1.ip)['prov'],'-') as ip_province_name
    ,COALESCE(ipparse(t1.ip)['cityCode'],'-') as ip_city_code
    ,COALESCE(ipparse(t1.ip)['city'],'-') as ip_city_name
    ,COALESCE(ipparse(t1.ip)['ispName'],'-') as ip_isp
	,COALESCE(t1.battery_status,'-')
	,COALESCE(t2.slot1_number,'-')
	,COALESCE(t2.slot1_carrier_operator,'-')
	,COALESCE(t2.slot2_imei,'-')
	,COALESCE(t2.slot2_number,'-')
	,COALESCE(t2.slot2_carrier_operator,'-')
	,COALESCE(t1.props['wifi_ssid'],'-')
	,coalesce(cast(from_unixtime(cast(substr(t1.current_time,0,10) as bigint),'yyyyMMdd HHmmss') as string),'-')
	,coalesce(cast(from_unixtime(cast(substr(t1.start_time,0,10) as bigint),'yyyyMMdd HHmmss') as string),'-')
	,coalesce(cast(from_unixtime(cast(substr(t1.send_time,0,10) as bigint),'yyyyMMdd HHmmss') as string),'-')
	,COALESCE(t1.lived_time/1000,'-')
	,COALESCE(t1.props['leui_exp_pgm_enabled'],'-')
	,COALESCE(t1.props['agnes_atvst_hh'],'-')
	,coalesce(cast(from_unixtime(cast(substr(t1.server_time,0,10) as bigint),'yyyyMMdd HHmmss') as string),'-')
	   ,${select_cc}
	   ,'${TRANS_DATE}' as dt
	   ,'${TRANS_HOUR}' as hour
	   ,'${deveice_type}' as dvc_type
	   ,case when device in ('letv','common') then 'letv' when device='coolpad' then 'coolpad' end as platform	

from   (select * from data_agnes.agnes_beat_hour 
            where dt='${datetime}'
				and hour='${hours}'
				and product='${deveice_type}'
				and ${condition}
				and $FILTER_MAINLAND_DATA
            ) t1
left outer join
 (select start_id,current_time
    ,max(case when slot_no = 1 then number end) slot1_number
    ,max(case when slot_no = 1 then carrier_operator end) slot1_carrier_operator
    ,max(case when slot_no = 2 then imei end) slot2_imei
    ,max(case when slot_no = 2 then number end) slot2_number
    ,max(case when slot_no = 2 then carrier_operator end) slot2_carrier_operator
    from data_agnes.agnes_simcard_hour
    where dt = '${datetime}'
	and hour='${hours}'
	and product='${deveice_type}'
    and source = 'beat'
	and ${condition}
	and $FILTER_MAINLAND_DATA
    group by start_id,current_time
    ) t2 			
    on t1.start_id = t2.start_id
    and t1.current_time = t2.current_time
;"
#${join_cc}
#${join_cc2};"
echo "$SQL"
hive  -e "$SQL"

if [ $? -ne 0 ];then
     println error ${target_table} ${TRANS_DATE} ${TRANS_HOUR} ${deveice_type}
     exit 1
else
    DONE_DIR=/user/hive/warehouse/dwd.db/dwd_flow_sdk_beat_hour/done/${TRANS_DATE}
	hadoop fs -test -e ${DONE_DIR}
	if [ $? -ne 0 ]; then
	 hadoop fs -mkdir -p ${DONE_DIR}
	fi
	#hadoop fs -touchz /user/hive/warehouse/dwd.db/dwd_flow_sdk_beat_hour/done/20160630/phone_letv_00_DONE
	DONE_FILE=${DONE_DIR}/${deveice_type}_${TRANS_HOUR}_DONE
	hadoop fs -test -e ${DONE_FILE}
	if [ $? -ne 0 ]; then
	 hadoop fs -touchz ${DONE_FILE}
	fi
	println success ${target_table} ${TRANS_DATE} ${TRANS_HOUR} ${deveice_type}
fi
