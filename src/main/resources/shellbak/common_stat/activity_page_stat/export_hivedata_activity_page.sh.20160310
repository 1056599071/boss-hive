#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

hive -e"
select count(letv_cookie),count(distinct letv_cookie),concat('http://',parse_url(cur_url, 'HOST'),parse_url(cur_url, 'PATH')),product,max(1),max(dt) from data_raw.tbl_pv_hour where dt='${yesterday}' and (cur_url like 'http://yuanxian.letv.com/%/pay%' or cur_url like 'http://yuanxian.letv.com/pay%' or cur_url like 'http://minisite.letv.com/%/pay%' or cur_url like 'http://minisite.letv.com/pay%') group by product,concat('http://',parse_url(cur_url, 'HOST'),parse_url(cur_url, 'PATH'))" > ./data/activity_page.${yesterday}

hive -e"
select count(letv_cookie),count(distinct letv_cookie),concat('http://',parse_url(ref, 'HOST'),parse_url(ref, 'PATH')),max(product),max(2),max(dt) from data_raw.tbl_pv_hour where dt='${yesterday}' and cur_url like 'http://zhifu.letv.com/tobuy%' and (ref like 'http://yuanxian.letv.com/%/pay%' or ref like 'http://yuanxian.letv.com/pay%') and product='1'  group by concat('http://',parse_url(ref, 'HOST'),parse_url(ref, 'PATH'))" > ./data/pc_zhifu.${yesterday}

hive -e"
select count(letv_cookie),count(distinct letv_cookie),concat('http://',parse_url(ref, 'HOST'),parse_url(ref, 'PATH')),max(product),max(2),max(dt) from data_raw.tbl_pv_hour where dt='${yesterday}' and cur_url like 'http://zhifu.letv.com/mz/tobuy%' and (ref like 'http://minisite.letv.com/%/pay%' or ref like 'http://minisite.letv.com/pay%') and product='0'  group by concat('http://',parse_url(ref, 'HOST'),parse_url(ref, 'PATH'))" > ./data/mz_zhifu.${yesterday}

hive -e"
select count(letv_cookie),count(distinct letv_cookie),act_property,product,max(0),max(dt) from data_raw.tbl_action_hour where dt='${yesterday}' and (product='0' or product='1') and act_property like 'ch=zhifu%' group by product,act_property" > ./data/zhifu_act.${yesterday}

cat ./data/*.${yesterday} > ./data/page_alldata.${yesterday}

