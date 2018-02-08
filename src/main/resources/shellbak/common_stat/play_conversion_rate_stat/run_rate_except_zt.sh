#!/bin/sh
#计算由播放页带来的付费转化率

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "收银台uv:" > ./data/play_rate_${yesterday}.zt

hive -e "select count(distinct letv_cookie) from data_raw.tbl_pv_hour  where dt='${yesterday}' and product='1' and letv_cookie!='-' and letv_cookie!='' and cur_url like '%http://zhifu.letv.com/tobuy/regular?ref=pfcyp%'">> ./data/play_rate_${yesterday}.zt

echo "付费成功订单:" >>  ./data/play_rate_${yesterday}.zt

hive -e "select count(distinct t1.userid),max(t1.dt) from 
(select userid,dt from data_raw.t_new_order_4_data where dt='${yesterday}' and orderpaytype!='-1' and terminal='112' and ordertype!='1001' and status='1')t1
join
(select uid from data_raw.tbl_pv_hour  where dt='${yesterday}' and product='1' and  cur_url!='-' and cur_url!='' and cur_url is not null and ilu='0'  and cur_url like '%http://zhifu.letv.com/tobuy/regular?ref=pfcyp%')t2
on(t1.userid=t2.uid)">>./data/play_rate_${yesterday}.zt

#sed -n 'n;p' ./data/play_rate_${yesterday}.txt | sed ':a;N;s/\n/ /g;ta' | sed "s/[\t| ]/,/g" > ./data/pay_page_rate.${yesterday}

