source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`


if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

echo "export user play record....."
sh run_play_record.sh $yesterday

echo "export movie configuration....."
sh export_rec_config_fromdb.sh $yesterday

url_filesize=`sed '/^[ \t]*$/d' config_data/rec_config_url_$yesterday.csv | wc -l`
pid_filesize=`sed '/^[ \t]*$/d' config_data/rec_config_pid_$yesterday.csv | wc -l`

if [ $url_filesize -gt 0 ]; then
   etho "exec command......export active datas......"
   sh run_config_url.sh $yesterday
else
   echo "not url......"
fi

#echo "export pid,uid....."
#sh run_play_uid_pid.sh $yesterday


if [ $pid_filesize -gt 0 ]; then
   echo "export pid,uid....."
   sh run_play_uid_pid.sh $yesterday
   echo "export pid uid from hive to db"
   sh run_config_pid.sh $yesterday
   sh import_rec_result_todb.sh $yesterday
else
   echo "not pid......"
fi



