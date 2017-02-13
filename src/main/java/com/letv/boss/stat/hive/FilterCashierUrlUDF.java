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
    		// pc 客户端用户中心
    		return "ref=PC_ClientUserCenter";
    	}else if(url.equals("https://zhifu.le.com/mz/tobuy/regular")){
    		// M站 个人中心会员续费
    		return "ref=M_PersonalCenter";
    	}else if(url.equals("https://zhifu.le.com/mz/tobuy/pro?fronturl=http%3A%2F%2Fm.letv.com%2Fvip")){
    		// M站 收银台切换超级影视会员收银台
    		return "ref=M_SwitchSuper";
    	}else if(url.equals("https://zhifu.le.com/mz/tobuy/regular?fronturl=http%3A%2F%2Fm.letv.com%2Fvip")){
    		// M站 收银台切换乐次元
    		return "ref=M_SwitchCommon";
    	}else if(url.contains("%2Fvplay")){
    		// 视频
    		Matcher m = Pattern.compile("\\w+?(\\d+).html").matcher(url);
    		if(m.find())
    			return "ref=Video_" + m.group(1);
    	}else{
    		Matcher m = Pattern.compile("(ref=.+?)&").matcher(url);
    		if(m.find())
    			return m.group(1);
    	}
        return null;
    }

    public static void main(String[] args) {
        FilterCashierUrlUDF udf = new FilterCashierUrlUDF();
        String url1 = "https://zhifu.le.com/tobuy/regular?ref=pfcyp&from=letv&fronturl=http%3A%2F%2Fwww.le.com%2Fptv%2Fvplay%2F_27468658.html%3Fch%3D360_ffdy";
        System.out.println(udf.evaluate(url1));
        String url2 = "https://zhifu.le.com/tobuy/regular?ref=yhzx&from=client";
        System.out.println(udf.evaluate(url2));
        String url3 = "https://zhifu.le.com/tobuy/pro?fronturl=http://client.pc.letv.com/play/10031776?t=p&ref=http%3A%2F%2Fclient.pc.letv.com%2Fmovie&pcVersion=7.3.2.180";
        System.out.println(udf.evaluate(url3));
    }
}
