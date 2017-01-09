package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.exec.UDFArgumentLengthException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDTF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.StructObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * 处理action_property字段
 */
public class GenericUDTFSplitAct extends GenericUDTF {

    public void close() throws HiveException {
    }

    public StructObjectInspector initialize(ObjectInspector[] parameter) throws UDFArgumentException {
        if (parameter.length != 1) {
            throw new UDFArgumentLengthException("split_act takes only one argument");
        }
        if (parameter[0].getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentException("split_act takes string as a parameter");
        }
        ArrayList<String> fieldNames = new ArrayList<String>();
        ArrayList<ObjectInspector> fieldOIs = new ArrayList<ObjectInspector>();
        fieldNames.add("act_fl");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        fieldNames.add("act_fragid");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        fieldNames.add("act_scid");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        fieldNames.add("act_name");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        fieldNames.add("act_pageid");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        fieldNames.add("act_wz");
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector);
        return ObjectInspectorFactory.getStandardStructObjectInspector(fieldNames, fieldOIs);
    }

    public void process(Object[] parameter) throws HiveException {
        Map<String, String> act_map = new HashMap<String, String>();
        String act_property = parameter[0].toString();
        String[] filters = {"fl", "fragid", "scid", "name", "pageid", "wz"};
        if (act_property != null && !"".equals(act_property) && !"-".equals(act_property)) {
            String[] s = act_property.split("&");
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
        String[] result = new String[6];
        for (int i = 0; i < filters.length; i++) {
            String str = "-";
            if (act_map.containsKey(filters[i])) {
                str = (String) act_map.get(filters[i]);
            }
            result[i] = str;
        }
        forward(result);
    }
}
