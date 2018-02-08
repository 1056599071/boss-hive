source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

hive -e "
set hive.exec.compress.output=true;  
set mapred.output.compress=true;  
set mapred.output.compression.codec=org.apache.hadoop.io.compress.GzipCodec;  
set io.compression.codecs=org.apache.hadoop.io.compress.GzipCodec; 
insert overwrite table data_raw.boss_play_day partition(dt='${yesterday}')
select ip,time,cookie,inu,country,area,province,city,p1,p2,p3,act,pt,uid,letv_cookie,deviceid,uuid,cid,pid,vid,playtype,
       str_to_map(property,'&','='),station,ilu,pcode,zid,liveid,utype,ctime,pay,joint 
        from data_raw.tbl_play_hour where dt='${yesterday}' and ilu='0'"
