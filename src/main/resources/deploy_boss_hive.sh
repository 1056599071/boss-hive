#!/usr/bin/env bash
#该脚本为编译boss-stat-api工程的脚本，编译完成后拷贝文件到美国，印度，俄罗斯的统计服务器并部署
#该工程为海外会员，支付提供接口，并做定时任务同步数据
source /etc/profile
BASEDIR=/home/zhaochunlong/boss-hive
cd ${BASEDIR}

#环境变量
JAVA_HOME=/usr/local/java
M2_HOME=/home/zhaochunlong/softs/apache-maven-3.3.9

echo "开始部署boss-hive工程......."

git pull origin master

echo "更新代码完成!"

${M2_HOME}/bin/mvn clean package -U -Dmaven.test.skip=true

echo "编译工程完成!"

exit 0



