#! /usr/bin/env python

import pycurl
import cStringIO
import fileinput
import time 
import json
import re
import sys 

c = pycurl.Curl()
URL_HTTP = 'http://i.api.letv.com/mms/inner/albumInfo/get?amode=1&platform=pc&id=$pid'


def http_get(line):
        url_str=URL_HTTP.replace('$pid',line)
        buf = cStringIO.StringIO()
        c.setopt(c.URL, url_str)
        c.setopt(c.WRITEFUNCTION, buf.write)
        c.perform()
        data = buf.getvalue()
        #print data
        buf.close()
        return data

if __name__=="__main__":
    x=0
    if (len(sys.argv)>1):
         x=sys.argv[1]
        #pid_path=sys.argv[1]
    reload(sys)
    print x 
    sys.setdefaultencoding('utf8') 
    filepathx='/home/zhaochunlong/boss_stat/common_stat/movie_outside_channel_stat/data/movie_outer_channel_result.'+x
    file_object = open(filepathx, 'w+')
    lineNum=0
    pathx='/home/zhaochunlong/boss_stat/common_stat/movie_outside_channel_stat/data/movie_outer_channel_temp.'+x
    for line in fileinput.input(pathx):
        #print line ;
        lineNum+=1
        if lineNum==1:
           continue;
        if line is None:
           break;
        line=line.strip()
        #if re.match('^[0-9a-z]+$',line):
        #   line=line
        #else:
        pid=line.split('\t')[2]

        #print line
        result = http_get(str(pid))
        #print result
        decodejson = json.loads(result)
        if len(result) < 100:
           continue;
        decodejson = json.loads(result)
        if len(decodejson['data'])==0:
           continue;
        name = decodejson['data'][0]['nameCn']
        file_object.write(line+'\t'+name+'\n')
    file_object.close()
