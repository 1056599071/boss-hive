#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

./query_hook.sh $1
./import_hook.sh $1

