source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

yesterday=`date -d "1 days ago" +"%Y%m%d"`

if [ "$#" -eq 1 ]; then
  yesterday=$1
fi

scp ./data/movie_income*.${yesterday} membership02@10.100.54.147:/home/membership02/boss_movie_income/data/
