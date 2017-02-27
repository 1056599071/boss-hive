#!/usr/bin/env bash
#磁盘管理通用脚本

#检验文件是否存在
function exist_file {
    if [ $# -ne 1 ]; then
       echo "必须输入文件名"
       exit 1
    fi
    if [ ! -f "$1" ]; then
        echo "文件$1不存在！请检查..."
        exit 1
    fi
    return 0
}

#清理文件的方法
function clear_file {
    exist_file $1;
    echo "开始清理文件$1，请稍等..."
    echo > "$1"
    echo "恭喜您，清理文件$1完成！"
    return 0
}

#删除文件的方法
function delete_file {
    clear_file $1;
    echo "开始删除文件$1，请稍等..."
    rm -f "$1";
    echo "恭喜您，删除文件$1成功！"
    return 0
}

#压缩文件的方法
function compress_file {
    exist_file $1;
    echo "开始压缩文件$1，请稍等..."
    path=$(dirname $1)
    src=${1##*/}
    target="$path/${src}.tar.gz"
    tar -zcPf ${target} $1
    echo "恭喜您，压缩文件$1完成，压缩后的文件为$target"
    return 0
}

