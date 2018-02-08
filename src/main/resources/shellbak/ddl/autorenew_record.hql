CREATE TABLE `dm_boss.autorenew_record`(
  `userid` string, 
  `canceltime` string, 
  `paytype` string, 
  `phone` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY '\t' 
