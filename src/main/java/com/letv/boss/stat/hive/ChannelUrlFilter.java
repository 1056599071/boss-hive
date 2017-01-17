package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDF;

import java.io.UnsupportedEncodingException;
import java.net.URL;
import java.net.URLDecoder;

/**
 * 站内渠道流量配置过滤UDF
 * <p/>
 * Created by kangxiongwei3 on 2016/12/27 20:24.
 */
public class ChannelUrlFilter extends UDF {

    public String evaluate(String url) {
        if (url == null || "".equals(url)) return null;
        if (url.contains("ref=http") || url.contains("ref=click")) return null;
        if (!url.contains("ref=") && !url.contains("ch=") && !url.contains("hy")) return null;
        try {
            url = URLDecoder.decode(url, "UTF-8");
            url = new URL(url).getQuery();
        } catch (Exception e) {
            return null;
        }
        String[] refs = new String[3];
        if (url.contains("ref=")) {
            String params = url.substring(url.indexOf("ref="));
            refs[0] = params.contains("&") ? params.substring(0, params.indexOf("&")) : params;
        }
        if (url.contains("hy") && !url.contains("ref=hy") && !url.contains("ch=hy")) {
            String params = url.substring(url.indexOf("hy"));
            params = params.contains("?") ? params.substring(0, params.indexOf("?")) : params;
            refs[1] = params.contains("&") ? params.substring(0, params.indexOf("&")) : params;
        }

        if (url.contains("ch=")) {
            String params = url.substring(url.indexOf("ch="));
            refs[2] = params.contains("&") ? params.substring(0, params.indexOf("&")) : params;
        }
        String ref = "";
        for (String key : refs) {
            if (key == null || "".equals(key)) continue;
            ref += "&" + key;
        }
        return ref.substring(1, ref.length() >= 100 ? 100 : ref.length());
    }

    public static void main(String[] args) {
        ChannelUrlFilter filter = new ChannelUrlFilter();
        String url = "http://baidu.com?ch=aaa&ref=bbb";
        String result = filter.evaluate(url);
        System.out.println(result);
    }

}
