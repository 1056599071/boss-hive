package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDF;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 过滤url参数，如果包含ref=xxx或者以hy开头，则匹配成功
 */
public class FilterUrlUDF extends UDF {
    private URL uri = null;
    private Pattern p = null;

    public String getUrlRef(String url) {
        try {
            this.uri = new URL(url);
        } catch (MalformedURLException e) {
            return null;
        }
        return this.uri.getQuery();
    }

    public String evaluate(String url) {
        if ((url != null) && (!"".equals(url)) && (url.contains("?"))) {
            String urlRef = getUrlRef(url);
            String regex = "((ref=\\w+)|(hy\\w+))";
            if ((urlRef != null) && ((urlRef.contains("ref")) || (urlRef.startsWith("hy")))) {
                this.p = Pattern.compile(regex);
                Matcher m = this.p.matcher(urlRef);
                if (m.find()) {
                    urlRef = m.group(1);
                    return urlRef;
                }
            }
        }
        return null;
    }

    public static void main(String[] args) {
        FilterUrlUDF udf = new FilterUrlUDF();
        String url1 = "http://zhifu.le.com/tobuy/regular?ref=qny&fronturl=#type=12";
        System.out.println(udf.evaluate(url1));
        String url2 = "http://zhifu.le.com/mz/tobuy/regular?group=8&ref=cn48";
        System.out.println(udf.evaluate(url2));
    }
}
