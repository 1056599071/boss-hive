#!/usr/bin/env bash

startDate=`date -d "-1 days ago" +%Y-%m-%d`
endDate=`date -d "0 days ago" +%Y-%m-%d`

if [ '$#' -eq 1 ]; then
    ${startDate}=$1
    ${endDate}=$1
fi
if [ '$#' -eq 2 ]; then
    ${startDate}=$1
    ${endDate}=$2
fi

date=${startDate}

while [[ ${date} < ${endDate} ]]
do
    echo ${date}
    date=`date -d "+1 day $date" +%Y-%m-%d`
done
