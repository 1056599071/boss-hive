#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd ${BASEDIR}

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "正在统计${yesterday}日fragid所带来的pv，uv，订单量"

##########按fragid计算页面、按钮pv、uv,包括点击，曝光、推荐曝光######################
hive -e "
add jar /home/boss/shell/hive/common_stat/mobile_action_stat/letv-boss-stat-1.2.jar ;
create temporary function split_act_udtf as 'com.letv.boss.stat.hive.GenericUDTFSplitAct';
set hive.groupby.skewindata=true ;
SELECT concat(count(deviceid),',',count(distinct deviceid),',',act_code,',',act_pageid,',',act_fl,',',act_fragid,',','0')
 FROM data_raw.tbl_action_hour lateral view split_act_udtf(act_property) mytable as act_fl,act_fragid,act_scid,act_name,act_pageid,act_wz where dt = '$yesterday' and product = '0' and act_code in('0','17') and deviceid!='-' and act_property like '%pageid=%' GROUP BY act_code,act_pageid,act_fl,act_fragid"  > ./data/mobile_pv_uv_fragid_all.${yesterday}
echo "${yesterday}按fragid计算页面、按钮pv、uv,包括点击，曝光、推荐曝光统计完成"

########按fragid计算页面、按钮订单量,包括点击，曝光、推荐曝光######################
hive -e "
add jar /home/boss/shell/hive/common_stat/mobile_action_stat/letv-boss-stat-1.2.jar ;
create temporary function split_act_udtf as 'com.letv.boss.stat.hive.GenericUDTFSplitAct';
set hive.groupby.skewindata=false;
select concat(count(distinct t4.uid),',',t4.act_code,',',t4.act_pageid,',',t4.act_fl,',',t4.act_fragid,',',t3.neworxufei,',','0',',',sum(t3.money))
 from
(select userid,neworxufei,money from dm_boss.t_new_order_4_data where dt='$yesterday' and orderpaytype!='-1' and terminal='130' and ordertype!='1001' and status='1')t3
join
(select distinct t1.uid,t2.deviceid,t2.act_code,t2.act_fl,t2.act_fragid,t2.act_scid,t2.act_pageid,t2.act_wz from
(select deviceid,max(uid) uid
 from data_raw.tbl_action_hour
 where dt='$yesterday' and product='0' and act_code in('0','17') and act_property like '%pageid=%' and uid!='-' and uid!='' and deviceid!='-'
 group by deviceid) t1
join
(select deviceid,act_code,act_property,act_fl,act_fragid,act_scid,act_name,act_pageid,act_wz
 from data_raw.tbl_action_hour lateral view split_act_udtf(act_property) mytable as act_fl,act_fragid,act_scid,act_name,act_pageid,act_wz
 where dt='$yesterday' and product='0' and act_code in('0','17') and act_property like '%pageid=%' and deviceid!='-') t2
 on(t1.deviceid=t2.deviceid)) t4
 on(t3.userid=t4.uid)
 group by t4.act_code,t4.act_pageid,t4.act_fl,t4.act_fragid,t3.neworxufei" > ./data/mobile_order_fragid_all.${yesterday}
echo "${yesterday}按fragid计算页面、按钮订单量,包括点击，曝光、推荐曝光统计完成"

