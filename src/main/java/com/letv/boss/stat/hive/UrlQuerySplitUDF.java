package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDF;

import java.net.URI;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

/**
 * 将URL中的参数按照key-value解析并保存
 * Created by kangxiongwei3 on 2017/2/7 14:27.
 */
public class UrlQuerySplitUDF extends UDF {

    /**
     * 将url的参数全部放在map中，解析结果中如果包含?或#特殊符号，则会去掉该符号之后的字符串
     *
     * @param url
     * @return
     */
    public Map<String, String> evaluate(String url) {
        Map<String, String> map = new HashMap<String, String>();
        try {
            //先把#号转码，否则获取不到#号后面的请求参数
            url = url.replaceAll("#", URLEncoder.encode("#", "UTF-8"));
            URI uri = new URI(url);
            String query = uri.getQuery();
            String[] params = query.split("&");
            for (String param : params) {
                if (!param.contains("=")) continue;
                int index = param.indexOf("=");
                String value = param.substring(index + 1);
                value = value.contains("?") ? value.substring(0, value.indexOf('?')) : value;
                value = value.contains("#") ? value.substring(0, value.indexOf('#')) : value;
                value = value.contains("/") ? value.substring(0, value.indexOf('/')) : value;
                map.put(param.substring(0, index), value);
            }
        } catch (Exception ignored) {

        }
        return map;
    }

    public static void main(String[] args) {
        UrlQuerySplitUDF udf = new UrlQuerySplitUDF();
        String url1 = "http://zhifu.le.com/tobuy/regular?ref=qny&fronturl=aaa#type=12";
        System.out.println(udf.evaluate(url1));
        String url2 = "http://zhifu.le.com/mz/tobuy/regular?group=8&ref=cn48";
        System.out.println(udf.evaluate(url2));
        String url3 = "http://localhost/aaa?front=http://aaa/b.html#type=456&ref=abc";
        System.out.println(udf.evaluate(url3));
        String url4 = "http://yuanxian.le.com/?ref=ym0101";
        System.out.println(udf.evaluate(url4));
    }

}
