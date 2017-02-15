#!/bin/bash
#执行导入一段时间范围内的所有数据到hive中

for date in 2017-02-13 2017-02-14
do	
	echo "开始导入${date}日的数据到hive中"
	sh ./load_vip.sh ${date}
done




















