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
 
#统计PC收银台pv
pv_data="./data/pc_pv_${yesterday}.log"
echo ${pv_data};
hive -e "select a.dt,count(a.letv_cookie) pv,count(distinct a.letv_cookie) uv,a.type,112 from 
(select dt,letv_cookie,'-2' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/tobuy%' or cur_url like 'http://zhifu.le.com/tobuy%') and product=1 
 union all 
 select dt,letv_cookie,'9' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/tobuy/pro%' or cur_url like 'http://zhifu.le.com/tobuy/pro%') and product=1 
 union all 
 select dt,letv_cookie,'1' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/tobuy/regular%' or cur_url like 'http://zhifu.le.com/tobuy/regular%') and product=1 
 union all 
 select dt,letv_cookie,'-1' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/tobuy/db%' or cur_url like 'http://zhifu.le.com/tobuy/db%') and product=1 
) a group by a.type,a.dt;" > ${pv_data}



#统计M站收银台pv
pv_data="./data/mz_pv_${yesterday}.log"
echo ${pv_data};
hive -e "select a.dt,count(a.letv_cookie) pv,count(distinct a.letv_cookie) uv,a.type,113 from 
(select dt,letv_cookie,'-2' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/mz/tobuy%' or cur_url like 'http://zhifu.le.com/mz/tobuy%') and product=0
 union all 
 select dt,letv_cookie,'9' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/mz/tobuy/pro%' or cur_url like 'http://zhifu.le.com/mz/tobuy/pro%') and product=0
 union all  
 select dt,letv_cookie,'1' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/mz/tobuy/regular%' or cur_url like 'http://zhifu.le.com/mz/tobuy/regular%') and product=0
 union all 
 select dt,letv_cookie,'-1' type from data_raw.tbl_pv_hour a where dt='${yesterday}' and letv_cookie!='' and letv_cookie!='0' and (cur_url like 'http://zhifu.letv.com/mz/tobuy/db%' or cur_url like 'http://zhifu.le.com/mz/tobuy/db%') and product=0
) a group by a.type,a.dt; "> ${pv_data}




cat ./data/*_pv_${yesterday}.log > ./data/cashier_pvuv.${yesterday}
