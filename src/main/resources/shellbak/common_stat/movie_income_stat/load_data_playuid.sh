source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

hive -e "
insert overwrite table dm_boss.tbl_play_day_boss partition(dt=${yesterday})
select distinct p1,p2,p3,uid,letv_cookie,deviceid,cid,pid,vid,playtype,property,ref,ilu,zid,liveid,time from data_raw.tbl_play_hour where dt='${yesterday}' and (property like '%pay=0%' or  property like '%pay=1%')
"
