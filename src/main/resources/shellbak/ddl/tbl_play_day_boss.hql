CREATE TABLE `dm_boss.tbl_play_day_boss`(
  `p1` string, 
  `p2` string, 
  `p3` string, 
  `uid` string, 
  `letv_cookie` string, 
  `deviceid` string, 
  `cid` string, 
  `pid` string, 
  `vid` string, 
  `playtype` string, 
  `property` string, 
  `ref` string, 
  `ilu` string, 
  `zid` string, 
  `liveid` string, 
  `time` string)
PARTITIONED BY ( 
  `dt` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY '\t' 
