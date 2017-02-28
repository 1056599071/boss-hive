#!/bin/sh
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +%Y-%m-%d`

if [ $# -eq 1 ]; then
	yesterday=$1
fi

sh ./mobile_channel.sh ${yesterday}

sh ./import_mobile_channel.sh ${yesterday//-/}
