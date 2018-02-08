#!/bin/bash

echo "开始创建表t_vip_product_order..."
hive -e "CREATE TABLE IF NOT EXISTS dm_boss.t_vip_product_order (
	orderid STRING COMMENT '产品订单号',
	order_name STRING COMMENT '产品名称',
	user_id BIGINT,
	country INT,
	selling_price DECIMAL(11,2) COMMENT '售卖价格',
	deductions DECIMAL(11,2) COMMENT '优惠额-代金券等',
	pay_price DECIMAL(11,2) COMMENT '通道真实支付价格',
	status TINYINT COMMENT '订单状态 0：未支付 1：已支付 2：服务关闭',
	logistics_status TINYINT,
	user_ip STRING COMMENT '购买用户ip',
	success_time TIMESTAMP COMMENT '支付成功时间',
	create_time TIMESTAMP,
	start_time TIMESTAMP,
	end_time TIMESTAMP,
	pay_channel INT COMMENT '支付系统通道',
	pay_channel_desc STRING COMMENT '支付系统通道描述',
	pay_merchant_business_id STRING,
	business_id STRING,
	is_refund TINYINT COMMENT '该字段已废弃,参照status=3',
	product_type INT COMMENT 'ALBUMS(1, "专辑"), SCROLLING(2, "轮播台"), VIDEO(3, "视频"), LIVE_ROUNDS(4, "直播场次"), LIVE_MATCH(5, "赛事"),VIP(100, "会员"),  LIVE_TICKET(200, "直播票")',
	product_subtype INT,
	product_id STRING COMMENT '产品id',
	product_duration INT COMMENT '购买商品的有效天数',
	product_duration_type TINYINT COMMENT '套餐时常单位',
	device_type TINYINT COMMENT '用户购买商品的设备来源 0：pc 1:mobile 2:tv 3:m_site',
	device STRING COMMENT '用户购买的设备详细信息：超级手机，iphone，ipad',
	pay_orderid STRING COMMENT '用户支付订单号',
	out_trade_no STRING COMMENT '商户订单号(第三方系统)',
	package_id STRING COMMENT '用户购买产品对应的套餐id',
	product_name STRING,
	is_renew TINYINT COMMENT '自扣费标识 0:普通订单 1:订阅订单 2:自动续费订单',
	subscribe_package_id STRING COMMENT '订阅套餐ID（套餐类型必须是订阅）',
	subscribe_price DECIMAL(11,2),
	platform INT COMMENT '来源平台 0:乐视',
	terminal STRING,
	cps_id STRING COMMENT '推广位ID',
	app_product_id STRING,
	tax_code STRING,
	tax DECIMAL(11,2),
	order_desc map<STRING, INT> COMMENT '订单描述信息',
	present_channel INT COMMENT '免费赠送渠道',
	order_flag INT,
	coupon STRING COMMENT '优惠券码',
	order_version STRING COMMENT '订单version'
)
PARTITIONED BY (dt STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE"
echo "创建表t_vip_product_order完成"
