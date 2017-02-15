#!/bin/bash
#该脚本用来存储乐视的会员信息

echo "开始创建表t_letv_vip_payment_all..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.t_letv_vip_payment_all (
  ordernumber string COMMENT '流水号',
  orderid string COMMENT '商户订单号',
  user_id string COMMENT '用户ID',
  user_name string COMMENT '用户名',
  ip string COMMENT '支付IP',
  paymentdate string COMMENT '支付时间',
  pay_position int COMMENT '支付位置 1首页快捷扫码 2 首页普通扫码',
  paytype int COMMENT '支付渠道',
  signnumber string COMMENT '商户号',
  status int COMMENT '状态',
  is_renew int COMMENT '自动续费标志 0 普通订单 1 首次订阅 2 连续续费',
  product_id string COMMENT '产品ID',
  product_name string COMMENT '产品名称',
  pid string COMMENT '专辑ID',
  vid string COMMENT '视频ID',
  deviceid string COMMENT '设备唯一标识',
  companyid int COMMENT '公司ID',
  terminal int COMMENT '终端',
  device string COMMENT '子终端',
  svip string COMMENT '会员类型',
  chargetype int COMMENT '充值类型 0表示直接购买，1表示充值乐点',
  lepayorderno string COMMENT '支付平台订单号',
  activity_id string COMMENT '活动ID',
  phone string COMMENT '手机号码',
  p1 string comment '一级订单来源',
  p2 string comment '二级订单来源',
  p3 string comment '三级订单来源',
  version string COMMENT '系统版本号 v1 v2') 
COMMENT '乐视网影视会员全量表'
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"

echo "创建表t_letv_vip_payment_all完成"
