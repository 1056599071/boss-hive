CREATE TABLE `dm_boss.le_card_record`(
  `batch` string, 
  `result` int, 
  `activedate` string, 
  `activetime` string, 
  `terminal` int, 
  `cardnumber` string, 
  `cardtype` int, 
  `userid` string, 
  `username` string, 
  `chargenumber` string, 
  `chargetype` int, 
  `chargeway` int, 
  `point` int, 
  `ip` string, 
  `meal` int, 
  `paytype` int, 
  `corderid` string, 
  `source` string, 
  `productname` string, 
  `amount` decimal(10,2), 
  `device` string)
PARTITIONED BY ( 
  `dt` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY '\t' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
