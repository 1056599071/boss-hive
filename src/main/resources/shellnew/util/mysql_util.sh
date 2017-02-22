#!/usr/bin/env bash
#封装mysql的常用方法

#从mysql中查询数据，然后把结果存储到指定文件中
#返回值0表示成功，1表示失败
function load {
    if [ $# != 7 ]; then
        echo "必须输入7个参数[ip, port, username, password, database, sql, file]"
        return 1
    fi
    echo "开始查询数据，并保存到$7中"
    mysql --default-character-set=utf8 -h $1 -P $2 -u $3 -p$4 $5 -N -e "$6" > $7
    echo "查询数据完成，请检查$7文件"
    return 0
}

#将文件内容导入到mysql的指定表中
#返回值0表示成功，1表示失败
#注意：文件每一列必须和表每一列对应，每列之间分隔符为\t，
function insert {
    if [ $# != 7 ]; then
        echo "必须输入7个参数[ip, port, username, password, database, table, file]"
        return 1
    fi
    echo "开始导入文件$7到$6表中"
    sql="LOAD DATA LOCAL INFILE '$7' INTO TABLE $6 FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n'"
    echo "执行sql为${sql}"
    mysql --default-character-set=utf8 -h $1 -P $2 -u $3 -p4 $5 -e "${sql}"
    echo "导入成功，请检查数据"
    return 0
}

#从mysql中删除数据
#返回值0表示成功，1表示失败
function delete {
    if [ $# != 7 ]; then
        echo "必须输入7个参数[ip, port, username, password, database, table, condition]"
        return 1
    fi
    echo "开始删除$6表中指定条件的数据"
    sql="DELETE FROM $6 WHERE $7"
    echo "执行sql为${sql}"
    mysql --default-character-set=utf8 -h $1 -P $2 -u $3 -p4 $5 -e "${sql}"
    echo "删除数据成功，请在$6表中检查是否正确"
    return 0
}