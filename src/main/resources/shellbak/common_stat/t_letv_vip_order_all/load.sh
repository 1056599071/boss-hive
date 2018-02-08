#!/bin/bash
#################################################################################
# Target Table : dm_boss.t_letv_vip_order_all
# Source Table : 
# Interface Name: 从Mysql统计库推送数据到hive中
# Refresh Frequency: per day 每日处理
# Version Info : 
# 修改人    修改时间        修改原因  
# ------   -----------    --------------------
# 亢雄伟    2017-05-09     推送统计表到dm_boss中
#
#################################################################################
source ~/.bashrc


BASEDIR=`dirname $0`
cd ${BASEDIR}

echo "推送boss会员订单表任务"
# User Variable Section
yesterday=`date -d "1 days ago" +"%Y-%m-%d"`
if [ $# -eq 1 ]; then
    yesterday=$1
fi

today=`date -d "${yesterday} +1 day" +"%Y-%m-%d"`

db_ip="10.183.196.100"     #源数据库IP
db_port=3306             #源数据库端口
db_user="boss_stat_w"      #源数据库用户名
db_pass="6b9b3#2137F"      #源数据库密码
db_name="boss_stat"        #源数据库名称

mkdir -p `pwd`/vip
file=`pwd`/data/t_letv_vip_order_all_${yesterday//-/}.txt

echo "export to file: ${file}"
#################################################################################

##
# 打印系统信息
##
function printSystemInfo {
    echo "################以下为系统相关信息####################"
    echo "#####################Mysql信息为#####################"
    whereis mysql
    which mysql
    echo "#######################环境变量为#####################"
    echo ${PATH}
    echo "####################################################"
}

##
# 查询会员订单
##
function getVipOrder {
    columns="orderid,order_name,user_id,selling_price,deductions,pay_price,user_ip, \
        success_time,create_time,start_time,end_time,pay_channel,pay_channel_desc, \
        pay_merchant_business_id,business_id,is_refund,product_type,product_subtype, \
        product_id,product_name,product_duration,product_duration_type,pay_orderid, \
        package_id,is_renew,subscribe_package_id,subscribe_price,terminal,app_product_id,tax_code,tax, \
        REPLACE(SUBSTR(order_desc, 2, CHAR_LENGTH(order_desc) - 2), '\"', ''), \
        present_channel,order_flag,parent_channel,cps_id,p1,p2,p3,coupon,coupon_batch,card_id,card_batch, \
        activity_id,original_order,deviceid,device_brand,device_model,batchid,order_src,ref,status,is_new, \
        version,pay_version,country,platform"

    sql="SELECT ${columns} from t_letv_vip_order_all where create_time >= '${yesterday}' and create_time < '${today}'"

    echo "从Mysql查询${yesterday}的会员订单数据"
    echo "执行sql为${sql}"
    mysql --default-character-set=utf8 -h"${db_ip}" -P"${db_port}" -u"${db_user}" -p"${db_pass}" "${db_name}" -N -e "${sql}" > ${file}
    
    if [ $? -ne 0 ]; then
        echo "执行Mysql查询出错，请检查"
        exit 1
    fi
    
    #替换null为空值
    sed -i 's/null//ig' "${file}"
    
    echo "从Mysql查询数据结束，文件路径为${file}"
    
}

function main {
    echo "开始导入${yesterday}~${today}日的数据到hive中"

    echo /dev/null > ${file}
    
    printSystemInfo
   
    getVipOrder

    sql="LOAD DATA LOCAL INPATH '${file}' OVERWRITE INTO TABLE dm_boss.t_letv_vip_order_all PARTITION (dt='${yesterday//-/}')"

    hive -e "${sql}"
}

#执行main方法
main




