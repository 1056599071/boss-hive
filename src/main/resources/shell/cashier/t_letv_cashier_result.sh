#!/bin/sh

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ $# -eq 1 ]; then
    yesterday=$1
fi

echo "计算${yesterday}日的流量结果"

db_ip=117.121.54.134    #源数据库IP
db_port=3829            #源数据库端口 
db_user=bosstdy_w       #源数据库用户名
db_pass=4f0aedbb8955ce8 #源数据库密码
db_name=bosstdy         #源数据库名称

file=`pwd`/data/t_letv_cashier_result.${yesterday}

#从mysql查询结果导入到文件中
mysql -N --default-character-set=utf8 -h ${db_ip} -P ${db_port} -u ${db_user} -p${db_pass} ${db_name} -e "SELECT m.CREATEDATE, m.TERMINAL, m.VIPTYPE, SUM(m.pv - COALESCE(n.pv, 0)) AS pv, SUM(m.uv - COALESCE(n.uv, 0)) AS uv FROM 
(SELECT
	CREATEDATE,
	TERMINAL,
	VIPTYPE,
	SUM(COALESCE(PV, 0)) AS pv,
	SUM(COALESCE(UV, 0)) AS uv
FROM
	t_letv_cashier_flow
WHERE
	CREATEDATE = '${yesterday}'
AND type = 'flow'
GROUP BY
	createdate,
	terminal,
	viptype) m
LEFT JOIN
(SELECT
	CREATEDATE,
	TERMINAL,
	VIPTYPE,
	SUM(COALESCE(PV, 0)) AS pv,
	SUM(COALESCE(UV, 0)) AS uv
FROM
	t_letv_cashier_flow
WHERE
	CREATEDATE = '${yesterday}'
AND type = 'login'
GROUP BY
	createdate,
	terminal,
	viptype) n
ON (m.CREATEDATE = n.CREATEDATE AND m.TERMINAL = n.TERMINAL AND m.VIPTYPE = n.VIPTYPE)
GROUP BY m.CREATEDATE, m.TERMINAL, m.VIPTYPE" > ${file}

