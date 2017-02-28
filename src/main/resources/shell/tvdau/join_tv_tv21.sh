source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`

if [ "$#" -eq 1 ]; then
  sdate=$1
fi

ssdate=${sdate//-/}



join -1 5 -2 8  data/tv_activity_user.$ssdate  data/tv_order_user.$ssdate > data/tv_activity_user_result.$ssdate

join -1 5 -2 8  data/tv21_activity_user.$ssdate  data/tv21_order_user.$ssdate >> data/tv_activity_user_result.$ssdate

sed -i "s/ /,/g" data/tv_activity_user_result.$ssdate
