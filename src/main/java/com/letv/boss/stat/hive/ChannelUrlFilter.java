package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDF;

import java.util.Set;
import java.util.TreeSet;

/**
 * 渠道配置过滤UDF
 * <p/>
 * Created by kangxiongwei3 on 2016/12/27 20:24.
 */
public class ChannelUrlFilter extends UDF {

    public String evaluate(String url) {
        if (url == null || "".equals(url)) return null;
        Set<String> set = new TreeSet<String>().descendingSet();
        if (url.contains("hy")) {
            String params = url.substring(url.indexOf("hy"));
            params = params.contains("?") ? params.substring(0, params.indexOf("?")) : params;
            set.add(params.contains("&") ? params.substring(0, params.indexOf("&")) : params);
        }
        if (url.contains("ref=")) {
            String params = url.substring(url.indexOf("ref="));
            set.add(params.contains("&") ? params.substring(0, params.indexOf("&")) : params);
        }
        if (url.contains("ch=")) {
            String params = url.substring(url.indexOf("ch="));
            set.add(params.contains("&") ? params.substring(0, params.indexOf("&")) : params);
        }
        String ref = "";
        for (String key : set) {
            ref += "&" + key;
        }
        return ref.substring(1);
    }

    public static void main(String[] args) {
        ChannelUrlFilter filter = new ChannelUrlFilter();
        String url = "http://baidu.com/hysss?ch=55&ref=777";
        String result = filter.evaluate(url);
        System.out.println(result);
    }

}
