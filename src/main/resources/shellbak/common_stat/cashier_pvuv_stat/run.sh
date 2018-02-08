#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

sh ./cashier_hive_pv.sh $1
sh ./import_cashier_pvuv_todb.sh $1

sh ./t_letv_cashier_import.sh $1
