#!/bin/sh
#source ~/.bashrc #很重要,不然hive指令不执行

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

hive_raw_table="data_raw.tbl_pv_hour"

#分隔符
yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi

#date=`date -d"${i} days ago " "+%Y%m%d"`;
 
#统计TV收银台pv
pv_data="./data/tv_pv_${yesterday}.log"
echo ${pv_data};
hive -e "select a.dt,count(a.deviceid) pv,count(distinct a.deviceid) uv,a.type,111 from
(select dt,deviceid,'-2' type from data_raw.tbl_pv_hour a where a.dt='${yesterday}' and a.cur_url like '10006%' and deviceid!='' and product=2 and p2='21'
 union all 
 select dt,deviceid,'-1' type from data_raw.tbl_pv_hour a where a.dt='${yesterday}' and a.cur_url='1000613' and deviceid!='' and product=2 and p2='21'
 union all 
 select dt,deviceid,'9' type from data_raw.tbl_pv_hour a where a.dt='${yesterday}' and a.cur_url='1000601' and deviceid!='' and product=2 and p2='21'
) a group by a.type,a.dt ;" > ${pv_data}


#移动端收银台pv
pv_data="./data/mobile_pv_${yesterday}.log"
echo ${pv_data};
hive -e "select b.dt,count(b.deviceid),count(distinct b.deviceid),b.type,130 from 
(select dt,a.deviceid,'-2' type from data_raw.tbl_action_hour a where a.dt='${yesterday}' and a.letv_cookie!='' and a.letv_cookie!='0' and  product=0 and a.act_property like '%fl=b3&%' 
 union all 
 select dt,a.deviceid,'9' type from data_raw.tbl_action_hour a where a.dt='${yesterday}' and a.letv_cookie!='' and a.letv_cookie!='0'  and  product=0  and act_code=0 and a.act_property like '%fl=b3&%wz=2%'
 ) b group by b.type,b.dt; " > ${pv_data}

#scp /home/membership02/boss_hive/cashierpv/*_pv_${yesterday}.log root@10.104.28.104:/letv/boss_pv/
#导入收银台pv数据到数据库
#ssh root@10.104.28.104 "cd /data/web/script/pvmechine_task/letv_boss_task/target;  /bin/sh  /data/web/script/pvmechine_task/letv_boss_task/target/execute_task_loadCashierPv.sh start  $yesterday"

cat ./data/*_pv_${yesterday}.log > ./data/cashier_pvuv.${yesterday}
