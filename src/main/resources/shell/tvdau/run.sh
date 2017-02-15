#!/bin/sh
source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

sdate=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi

startdate=${sdate//-/}

echo "${sdate} ${startdate}"

sh ./run_tv_activity.sh ${sdate}
sh ./join_tv_tv21.sh ${sdate}
sh ./import_tv_activity_user.sh ${startdate}
