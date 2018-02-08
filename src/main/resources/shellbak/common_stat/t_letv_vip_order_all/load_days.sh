#!/bin/bash
#执行导入一段时间范围内的所有数据到hive中

DATE_FORMAT="%Y-%m-%d"


start=`date -d "1 days ago" +"${DATE_FORMAT}"`
end=`date -d "0 days ago" +"${DATE_FORMAT}"`

if [ $# -eq 2 ]; then
	start=$1
	end=$2
fi

echo "时间范围为${start}~${end}"

date=`date -d "+0 day ${start}" +"${DATE_FORMAT}"`

until [[ ${date} > ${end} ]]; do 
    sh ./load.sh ${date}
    date=`date -d "+1 day ${date}" +"${DATE_FORMAT}"`
done																																									




















