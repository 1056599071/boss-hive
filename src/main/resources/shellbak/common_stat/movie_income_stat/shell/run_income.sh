#读入环境变量
#source /etc/profile;
source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

sdate=`date -d '1 days ago' +%Y-%m-%d`
edate=`date +%Y-%m-%d`

if [ "$#" -eq 2 ]; then
  sdate=$1
  edate=$2
fi

yesterday=${sdate//-/}
today=${edate//-/}

#./export_order_from_db.sh -sdate $sdate -edate $edate
#./load_order_tohive.sh $sdate
#./load_data_to_playdayuid.sh $yesterday
#./export_movie_income.sh $sdate

#./export_movie_income_mobile.sh $sdate

./load_incomedata_to_infobright.sh $yesterday
./load_incomedata_to_bosstdy.sh $yesterday

./load_incomedata_to_bosstdy.sh.mobile $yesterday
./load_incomedata_to_infobright.sh.mobile $yesterday

./load_super_movie_income_to_infobright.sh $yesterday ${today}
./load_super_movie_income_to_bosstdy.sh $yesterday ${today}
