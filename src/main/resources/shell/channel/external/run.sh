#!/bin/sh
#计算外部渠道带来收入 PC端

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

./run_external_channel.sh $1 $2
./import_eci_todb_new.sh $1
