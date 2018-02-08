#!/bin/sh
#########会员指标脚本############
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

edate_1=`date +%Y-%m-%d`

if [ "$#" -eq 1 ]; then
  edate_1=$1
fi
sdate_1=`date -d "${edate_1} 1 days ago" +"%Y-%m-%d"`

#sh /home/boss/shell/hive/common_stat/boss_stat_new/common_stat/movie_play_stat/export_play_to_bossplay.sh

#sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/activity_user_zhibiao/run.sh
#sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/activity_user_zhibiao/import_activity_page_uv_todb.sh
#sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_stat_day/run-vip-activity-user-day.sh

sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_zhibiao/run.sh ${sdate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_zhibiao/run-cvuv.sh ${sdate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_zhibiao/import_retention_user_todb.sh ${sdate_1//-/}
#sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_zhibiao/run-uv-7-15-30.sh 
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/activity_user_zhibiao/run-cvuv-uuid.sh ${sdate_1}
#sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/activity_user_zhibiao/run-vip-activity-user-day-uuid.sh
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/activity_user_zhibiao/import_activity_uuid_todb.sh ${sdate_1//-/}

sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_stat_day/run-vip-retention-user.sh ${sdate_1} ${edate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_stat_day/run-vip-activity-user-day-uuid.sh ${sdate_1} ${edate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_stat_day/run-vip-activity-user-7-15-30.sh  ${sdate_1} ${edate_1}

#####################每日留存##############################
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_order_zhibiao/run-cvuv-order.sh ${sdate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_order_zhibiao/import_retention_user_order_todb.sh ${sdate_1//-/}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_stat_retention_order_day/run-vip-retention-order.sh ${sdate_1} ${edate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_order_zhibiao/run-activity-order.sh ${sdate_1}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_order_zhibiao/import_activity_order_todb.sh ${sdate_1//-/}
sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_stat_retention_order_day/run-vip-activity-order-day-uuid.sh ${sdate_1}  ${edate_1}

##########################################################

#sh /home/boss/shell/hive/common_stat/boss_stat_new/vip_zhibiao/vip_day_fromhive/retention_user_zhibiao/run-uv-7-15-30.sh
