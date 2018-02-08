#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

./cashier_hive_pv_pc.sh $1
./import_cashier_pvuv_todb.sh $1
