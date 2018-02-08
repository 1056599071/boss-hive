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
 
#埋点统计
hive -e "select ${yesterday}, count(1) pv, count(distinct letv_cookie) uv, act_property, split(cur_url, '[?]')[0] from data_raw.tbl_action_hour where dt = '${yesterday}' and (act_property like 'ch=zhifu&pg=tobuy%' or act_property like 'ch=zhifu&pg=mtobuy%') group by act_property, split(cur_url, '[?]')[0]" > ./a.${yesterday}

#PC端埋点
hive -e "select pv, uv, type, hook from (
select count(1) pv, count(distinct letv_cookie) uv, 1 as type, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) as hook from data_raw.tbl_action_hour where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' and (cur_url like 'http://zhifu.letv.com/tobuy/regular%' or cur_url like 'http://zhifu.le.com/tobuy/regular%' or cur_url like 'http://zhifu.letv.com/tobuy/renewregular%' or cur_url like 'http://zhifu.le.com/tobuy/renewregular%') group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])
union
select count(1) pv, count(distinct letv_cookie) uv, 9 as type, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) as hook from data_raw.tbl_action_hour where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' and (cur_url like 'http://zhifu.letv.com/tobuy/pro%' or cur_url like 'http://zhifu.le.com/tobuy/pro%' or cur_url like 'http://zhifu.letv.com/tobuy/renewpro%' or cur_url like 'http://zhifu.le.com/tobuy/renewpro%') group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])
union
select count(1) pv, count(distinct letv_cookie) uv, -1 as type, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) as hook from data_raw.tbl_action_hour_hour where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' and (cur_url like 'http://zhifu.letv.com/tobuy/db%' or cur_url like 'http://zhifu.le.com/tobuy/db%') group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])) tmp" > b.${yesterday}

#M站埋点
hive -e "select pv, uv, type, hook from (
select count(1) pv, count(distinct letv_cookie) uv, 1 as type, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) as hook from data_raw.tbl_action_hour where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' and (cur_url like 'http://zhifu.letv.com/mz/tobuy/regular%' or cur_url like 'http://zhifu.le.com/mz/tobuy/regular%') group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])
union
select count(1) pv, count(distinct letv_cookie) uv, 9 as type, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) as hook from data_raw.tbl_action_hour where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' and (cur_url like 'http://zhifu.letv.com/mz/tobuy/pro%' or cur_url like 'http://zhifu.le.com/mz/tobuy/pro%') group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])
union
select count(1) pv, count(distinct letv_cookie) uv, -1 as type, concat_ws('&', split(props, '&')[2], split(props, '&')[3]) as hook from data_raw.tbl_action_hour where dt='${yesterday}' and props like '%click_area=cashier&position=%' and (props like '%object_id=35%' or props like '%object_id=9%') and app_name='bossCN' and (cur_url like 'http://zhifu.letv.com/mz/tobuy/db%' or cur_url like 'http://zhifu.le.com/mz/tobuy/db%') group by concat_ws('&', split(props, '&')[2], split(props, '&')[3])) tmp" >> b.${yesterday}
