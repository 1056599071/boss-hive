#!/usr/bin/env bash
#测试工具类
source ~/.bashrc
source ./date_util.sh
source ./mysql_util.sh


yesterday=`getYesterday`

echo ${yesterday}

today=`addDays ${yesterday} 5`

echo ${today}



