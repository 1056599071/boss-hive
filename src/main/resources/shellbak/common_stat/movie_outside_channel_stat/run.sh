#!/bin/sh

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

./export_hivedata_activity_page.sh $1 
./import_movie_outer_uv_todb.sh $1
