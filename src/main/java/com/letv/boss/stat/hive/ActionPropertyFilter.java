package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDF;

import java.util.HashMap;
import java.util.Map;

public class ActionPropertyFilter extends UDF {
    public String evaluate(String act_property, String split, String filter) {
        Map<String, String> act_map = new HashMap();
        StringBuffer result = new StringBuffer();
        if ((!"".equals(act_property)) && (!"-".equals(act_property)) && (act_property != null)) {
            String[] s = act_property.split(split);
            for (int i = 0; i < s.length; i++) {
                if ((s[i] != null) && (!"".equals(s[i])) && (s[i].contains("="))) {
                    String act_key = s[i].substring(0, s[i].indexOf("="));
                    String act_value = s[i].substring(s[i].indexOf("=") + 1);
                    if (!act_map.containsKey(act_key)) {
                        act_map.put(act_key, act_value);
                    }
                }
            }
        }
        String[] filters = filter.split("\\+");
        for (int i = 0; i < filters.length; i++) {
            String str = "-";
            if (act_map.containsKey(filters[i])) {
                str = (String) act_map.get(filters[i]);
            }
            result.append(str).append(",");
        }
        return result.toString();
    }
}
