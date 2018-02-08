CREATE TABLE `dm_boss.t_new_order_4_data_temp`(
  `orderid` string, 
  `money` string, 
  `status` string, 
  `createtime` string, 
  `canceltime` string, 
  `ordertype` string, 
  `aid` string, 
  `orderfrom` string, 
  `aid2` string, 
  `runningnumber` string, 
  `videoid` string, 
  `paytype` string, 
  `paytime` string, 
  `paytime_hour` string, 
  `userip` string, 
  `pakbuycount` string, 
  `paychannel` string, 
  `suborderfrom` string, 
  `model` string, 
  `userid` string, 
  `terminal` string, 
  `terminal2` string, 
  `viptype` string, 
  `orderpaytype` string, 
  `orderpaytype1` string, 
  `neworxufei` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY '\t' 
STORED AS TEXTFILE

