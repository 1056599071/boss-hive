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
    file_object = open('/tmp/playlistname.log', 'w+')
    lineNum=0
    for line in fileinput.input('/tmp/playlistid.log'):
	lineNum+=1
	if lineNum==1:
           continue;
	if line is None:
           break;
	line=line.strip('\n')
	if re.match('^[0-9a-z]+$',line):
	   line=line	
	else:
	   line=line.split('-')[0]
        result = http_get(str(line))
	#print result
	if len(result) < 100:
           continue;
	decodejson = json.loads(result)
	if len(decodejson['data'])==0:
	   continue;
	name = decodejson['data'][0]['nameCn']
	category = decodejson['data'][0]['category'].keys()[0]
	categoryName = decodejson['data'][0]['category'].values()[0]
	file_object.write(line+','+name+',,,'+category+','+categoryName+'\n')
    file_object.close()

