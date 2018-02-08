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
	buf.close()
	return data

if __name__=="__main__":
    if (len(sys.argv)>1):
	pid_path=sys.argv[1]
    reload(sys)
    sys.setdefaultencoding('utf8') 
    file_object = open('./result.txt', 'w+')
    lineNum=0
    for line in fileinput.input('./movie_income_pc.20150412'):
	lineNum+=1
	if lineNum==1:
           continue;
	if line is None:
           break;
	line=line.strip('\n')
        info=line
	if re.match('^[0-9a-z]+$',line):
	   line=line	
	else:
	   line=line.split('\t')[0]
        result = http_get(str(line))
	#print result
	decodejson = json.loads(result)
	name = decodejson['data'][0]['nameCn']
	file_object.write(info+'\t'+name+'\n')
    file_object.close()

