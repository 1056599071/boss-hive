#! /usr/bin/env python

import pycurl
import cStringIO
import fileinput
import time 
import json
import re
import sys 

c = pycurl.Curl()
URL_HTTP = 'http://api.sso.letv.com/api/getUserByID/uid/$pid'


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
    filepathx='/home/zhaochunlong/boss_stat/common_stat/movie_user_recommand/result_data/pid_uid_phone_result.'+x
    file_object = open(filepathx, 'w+')
    lineNum=0
    pathx='/home/zhaochunlong/boss_stat/common_stat/movie_user_recommand/result_data/pid_uid_phone.'+x
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
        #   line=line.split('-')[0]

        #print line
        result = http_get(str(line))
        #print result
        decodejson = json.loads(result)
       # name = decodejson['bean']['uid']
       # file_object.write(line+','+name+',,\n')
        #name = decodejson['bean']['uid']
        #email = decodejson['bean']['email']
        phonenum = decodejson['bean']['mobile']
        if not phonenum.strip():
           phonenum='0'
        file_object.write(line+'\t'+x+'\t'+phonenum+'\n')
    file_object.close()
