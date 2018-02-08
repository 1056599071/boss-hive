#!/bin/sh

sdate=$1
edate=`date -d "+1 day $2" +%Y%m%d`

:  > ./redo_run.sh
while [[ $sdate<$edate ]]
do
 sdate1=`date -d "+1 day $sdate" +%Y%m%d` 
 echo "./run.sh $sdate $sdate1" >>redo_run.sh
 sdate=$sdate1
done

chmod 744 redo_run.sh
