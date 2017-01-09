package com.letv.boss.stat.hive;

import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.exec.UDFArgumentLengthException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorConverters;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;
import org.apache.hadoop.io.Text;

public class GenericUDFSplitColumn extends GenericUDF {
    private transient ObjectInspectorConverters.Converter[] converters;

    public Object evaluate(GenericUDF.DeferredObject[] arguments)
            throws HiveException {
        assert (arguments.length == 3);
        if ((arguments[0].get() == null) || (arguments[1].get() == null) || (arguments[2].get() == null)) {
            return null;
        }
        Text s = (Text) this.converters[0].convert(arguments[0].get());
        Text regex = (Text) this.converters[1].convert(arguments[1].get());
        Text filterkey = (Text) this.converters[2].convert(arguments[2].get());

        StringBuffer result = new StringBuffer();

        String[] filters = {"fl", "name"};
        String[] arrayOfString1;
        int j = (arrayOfString1 = s.toString().split(regex.toString(), -1)).length;
        for (int i = 0; i < j; i++) {
            String str = arrayOfString1[i];
            String act_key = str.substring(0, str.indexOf("="));
            String act_value = str.substring(str.indexOf("=") + 1);
            for (int k = 0; k < filters.length; k++) {
                if (act_key.equals(filters[k])) {
                    result.append(act_value).append(",");
                }
            }
        }
        return result;
    }

    public String getDisplayString(String[] children) {
        assert (children.length == 3);
        return "split_act(" + children[0] + ", " + children[1] + "," + children[2] + ")";
    }

    public ObjectInspector initialize(ObjectInspector[] arguments)
            throws UDFArgumentException {
        if (arguments.length != 3) {
            throw new UDFArgumentLengthException(
                    "The function SPLIT_ACT(s, regexp,filterkey) takes exactly 3 arguments.");
        }
        this.converters = new ObjectInspectorConverters.Converter[arguments.length];
        for (int i = 0; i < arguments.length; i++) {
            this.converters[i] = ObjectInspectorConverters.getConverter(arguments[i],
                    PrimitiveObjectInspectorFactory.writableStringObjectInspector);
        }
        return
                ObjectInspectorFactory.getStandardListObjectInspector(
                        PrimitiveObjectInspectorFactory.writableStringObjectInspector);
    }
}
