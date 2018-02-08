#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR


sdate=`date -d "1 days ago" +"%Y-%m-%d"`
edate=`date +%Y-%m-%d`

if [ "$#" -eq 4 ]; then
  sdate=$2
  edate=$4
fi

ssdate=${sdate//-/}

./export_order_from_db.sh $1 $2 $3 $4

./load_order_tohive.sh $sdate
