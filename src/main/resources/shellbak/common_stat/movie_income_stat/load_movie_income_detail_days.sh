#!/bin/bash
#执行导入一段时间范围内的所有数据到hive中

start=`date -d "1 days ago" +"%Y-%m-%d"`
end=`date -d "0 days ago" +"%Y-%m-%d"`

if [ $# -eq 2 ]; then
	start=$1
	end=$2
fi

echo "时间范围为${start}~${end}"

date=`date -d "+0 day ${start}" +"%Y-%m-%d"`

while [[ ${date} < ${end} ]]; 
do
    sh ./load_movie_income_detail.sh ${date}
    date=`date -d "+1 day ${date}" +"%Y-%m-%d"`
done																																									




















