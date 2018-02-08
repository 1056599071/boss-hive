CREATE TABLE `dm_boss.t_letv_vip_order_refund`(
  `user_id` bigint, 
  `country` int, 
  `orderid` string, 
  `pay_orderid` string, 
  `refund_no` string, 
  `refund_price` decimal(11,2), 
  `operator` string, 
  `status` int, 
  `result` string, 
  `reason` string, 
  `pay_refund_no` string, 
  `pay_refund_channel_no` string, 
  `pay_refund_time` string, 
  `update_time` string, 
  `create_time` string)
PARTITIONED BY ( 
  `dt` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY '\t' 
  COLLECTION ITEMS TERMINATED BY ',' 
  MAP KEYS TERMINATED BY ':' 
