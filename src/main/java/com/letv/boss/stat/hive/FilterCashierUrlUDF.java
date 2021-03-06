package com.letv.boss.stat.hive;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.hive.ql.exec.UDF;

/**
 * 过滤收银台URL 按ref统计
 * @author changyue1
 */
public class FilterCashierUrlUDF extends UDF {

    public String evaluate(String url) {
    	if(StringUtils.isEmpty(url))
    		return null;
    	if(url.contains("from=client")){
    		// pc 客户端
    		return "ref=PC_Client";
    	//}else if(url.equals("https://zhifu.le.com/mz/tobuy/regular")){
    	}else if(url.equals("https://ibuy.le.com/v2/buy/package.html?frontUrl=")){
    		// M站 个人中心会员续费
    		return "ref=M_PersonalCenter";
    	//}else if(url.equals("https://zhifu.le.com/mz/tobuy/pro?fronturl=http%3A%2F%2Fm.letv.com%2Fvip")){
    	}else if(url.equals("https://ibuy.le.com/v2/buy/package.html?vipId=9&frontUrl=&ref=")){
    		// M站 收银台切换超级影视会员收银台
    		return "ref=M_SwitchSuper";
    	//}else if(url.equals("https://zhifu.le.com/mz/tobuy/regular?fronturl=http%3A%2F%2Fm.letv.com%2Fvip")){
    	}else if(url.equals("https://ibuy.le.com/v2/buy/package.html?frontUrl=&ref=")){
    		// M站 收银台切换乐次元
    		return "ref=M_SwitchCommon";
    	}else if(url.contains("%2Fvplay")){
    		// 视频
    		Matcher m = Pattern.compile("\\w+?(\\d+).html").matcher(url);
    		if(m.find())
    			return "ref=Video_" + m.group(1);
    	}else{
    		Matcher m = Pattern.compile("(ref=[\\w%.]+)").matcher(url);
    		if(m.find()){
    			String ref = m.group(1);
    			return ref.length() > 128? ref.substring(0, 128): ref;
    		}
    	}
        return null;
    }

    public static void main(String[] args) {
        FilterCashierUrlUDF udf = new FilterCashierUrlUDF();
        String url1 = "https://zhifu.le.com/tobuy/regular?ref=pfcyp&from=letv&fronturl=http%3A%2F%2Fwww.le.com%2Fptv%2Fvplay%2F_27468658.html%3Fch%3D360_ffdy";
        System.out.println(udf.evaluate(url1));
        String url2 = "https://zhifu.le.com/tobuy/regular?ref=yhzx&from=client";
        System.out.println(udf.evaluate(url2));
        String url3 = "https://zhifu.le.com/tobuy/pro?fronturl=http://client.pc.letv.com/play/10031776?t=p&ref=http%3A%2F%2Fclient.pc.letv.com1231231231231231231231231231231231231231231231231231231231231231231231231231231212312312312312312312312312312312312312312312312312312312312312312%2Fmovie&pcVersion=7.3.2.180";
        System.out.println(udf.evaluate(url3));
        String url4 = "https://zhifu.le.com/tobuy/pro?ref=ym03089#type=952";
        System.out.println(udf.evaluate(url4));
        String url5 = "https://ibuy.le.com/v2/buy/package.html?frontUrl=http%3A%2F%2Fwww.le.com%2Fptv%2Fvplay%2F27369532.html%23vid%3D27369532&ref=pfcyp&from=letv&fronturl=http%3A%2F%2Fwww.le.com%2Fptv%2Fvplay%2F27369532.html%";
        System.out.println(udf.evaluate(url5));
    }
}
