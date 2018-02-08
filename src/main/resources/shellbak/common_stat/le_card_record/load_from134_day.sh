#!/bin/bash
#执行导入一段时间范围内的所有数据到hive中

dates=`cat data_days`
for date in $dates
do	
	echo "开始导入${date}日的数据到hive中"
	sh ./load_from134.sh ${date}
done




















