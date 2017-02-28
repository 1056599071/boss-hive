#!/usr/bin/env bash
#测试工具类
source ~/.bashrc
source ./date_util.sh
source ./mysql_util.sh

yesterday=`getYesterday`

echo ${yesterday}

today=`addDays ${yesterday} 5`

echo ${today}

ip="10.183.196.100"
port="3306"
user="boss_stat_w"
password="6b9b3#2137F"

insert ${ip} ${port} ${user} ${password} "boss_stat" "kxw_shell" ./test_mysql.txt

load ${ip} ${port} ${user} ${password} "boss_stat" "select * from kxw_shell" ./kangxiongwei.log

delete ${ip} ${port} ${user} ${password} "boss_stat" "kxw_shell" "firstname = 'zhang'"

