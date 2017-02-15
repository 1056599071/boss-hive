#!/bin/sh
#计算由播放页带来的付费转化率

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi


hive -e "select dt,route,count(deviceid) pv,count(distinct deviceid) uv,111 from 
 (select dt,deviceid,regexp_replace(regexp_extract(property,'.*?route\\=([^&]+)',1),'http[^,]+','h5') as route from data_raw.tbl_pv_hour where dt='$yesterday' and product='2'  
 union all 
 select dt,deviceid,cur_url as route from data_raw.tbl_pv_hour where dt='$yesterday' and product='2' and  cur_url in ('1000116','1000639','1000633','1000634','1000635','1000636','1000637','1000638','800','1000601','1000604','1000603','1000630','1000606','1000607','798','799','1000109','1000112','1000517','1000902','1000903','1000906','1000908','1000632','1000113','1000108','1000518'))t where t.route!='-' and t.route!='' group by dt,route order by route; 
" > ./data/tv_inner_channels_pv.$yesterday


#mysql --default-character-set=utf8 -P 3829 -h 117.121.54.134 -u bosstdy_w -p4f0aedbb8955ce8 bosstdy -s -N --local-infile=1 -e "load data local infile './data/tv_inner_channels_pv.$yesterday' IGNORE into table t_inner_channel_pv fields terminated by  '\t'(date,channelParameter,pv,uv,terminal);"
