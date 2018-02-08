// ORM class for table 'hook_stat_test'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Thu Dec 01 15:38:25 CST 2016
// For connector: org.apache.sqoop.manager.MySQLManager
import org.apache.hadoop.io.BytesWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapred.lib.db.DBWritable;
import com.cloudera.sqoop.lib.JdbcWritableBridge;
import com.cloudera.sqoop.lib.DelimiterSet;
import com.cloudera.sqoop.lib.FieldFormatter;
import com.cloudera.sqoop.lib.RecordParser;
import com.cloudera.sqoop.lib.BooleanParser;
import com.cloudera.sqoop.lib.BlobRef;
import com.cloudera.sqoop.lib.ClobRef;
import com.cloudera.sqoop.lib.LargeObjectLoader;
import com.cloudera.sqoop.lib.SqoopRecord;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class hook_stat_test extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private java.sql.Date date;
  public java.sql.Date get_date() {
    return date;
  }
  public void set_date(java.sql.Date date) {
    this.date = date;
  }
  public hook_stat_test with_date(java.sql.Date date) {
    this.date = date;
    return this;
  }
  private Integer pv;
  public Integer get_pv() {
    return pv;
  }
  public void set_pv(Integer pv) {
    this.pv = pv;
  }
  public hook_stat_test with_pv(Integer pv) {
    this.pv = pv;
    return this;
  }
  private Integer uv;
  public Integer get_uv() {
    return uv;
  }
  public void set_uv(Integer uv) {
    this.uv = uv;
  }
  public hook_stat_test with_uv(Integer uv) {
    this.uv = uv;
    return this;
  }
  private String hook;
  public String get_hook() {
    return hook;
  }
  public void set_hook(String hook) {
    this.hook = hook;
  }
  public hook_stat_test with_hook(String hook) {
    this.hook = hook;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof hook_stat_test)) {
      return false;
    }
    hook_stat_test that = (hook_stat_test) o;
    boolean equal = true;
    equal = equal && (this.date == null ? that.date == null : this.date.equals(that.date));
    equal = equal && (this.pv == null ? that.pv == null : this.pv.equals(that.pv));
    equal = equal && (this.uv == null ? that.uv == null : this.uv.equals(that.uv));
    equal = equal && (this.hook == null ? that.hook == null : this.hook.equals(that.hook));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof hook_stat_test)) {
      return false;
    }
    hook_stat_test that = (hook_stat_test) o;
    boolean equal = true;
    equal = equal && (this.date == null ? that.date == null : this.date.equals(that.date));
    equal = equal && (this.pv == null ? that.pv == null : this.pv.equals(that.pv));
    equal = equal && (this.uv == null ? that.uv == null : this.uv.equals(that.uv));
    equal = equal && (this.hook == null ? that.hook == null : this.hook.equals(that.hook));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.date = JdbcWritableBridge.readDate(1, __dbResults);
    this.pv = JdbcWritableBridge.readInteger(2, __dbResults);
    this.uv = JdbcWritableBridge.readInteger(3, __dbResults);
    this.hook = JdbcWritableBridge.readString(4, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.date = JdbcWritableBridge.readDate(1, __dbResults);
    this.pv = JdbcWritableBridge.readInteger(2, __dbResults);
    this.uv = JdbcWritableBridge.readInteger(3, __dbResults);
    this.hook = JdbcWritableBridge.readString(4, __dbResults);
  }
  public void loadLargeObjects(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void loadLargeObjects0(LargeObjectLoader __loader)
      throws SQLException, IOException, InterruptedException {
  }
  public void write(PreparedStatement __dbStmt) throws SQLException {
    write(__dbStmt, 0);
  }

  public int write(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeDate(date, 1 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeInteger(pv, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(uv, 3 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeString(hook, 4 + __off, 12, __dbStmt);
    return 4;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeDate(date, 1 + __off, 91, __dbStmt);
    JdbcWritableBridge.writeInteger(pv, 2 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeInteger(uv, 3 + __off, 4, __dbStmt);
    JdbcWritableBridge.writeString(hook, 4 + __off, 12, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.date = null;
    } else {
    this.date = new Date(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.pv = null;
    } else {
    this.pv = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.uv = null;
    } else {
    this.uv = Integer.valueOf(__dataIn.readInt());
    }
    if (__dataIn.readBoolean()) { 
        this.hook = null;
    } else {
    this.hook = Text.readString(__dataIn);
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.date.getTime());
    }
    if (null == this.pv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.pv);
    }
    if (null == this.uv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.uv);
    }
    if (null == this.hook) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, hook);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.date) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.date.getTime());
    }
    if (null == this.pv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.pv);
    }
    if (null == this.uv) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeInt(this.uv);
    }
    if (null == this.hook) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, hook);
    }
  }
  private static final DelimiterSet __outputDelimiters = new DelimiterSet((char) 44, (char) 10, (char) 0, (char) 0, false);
  public String toString() {
    return toString(__outputDelimiters, true);
  }
  public String toString(DelimiterSet delimiters) {
    return toString(delimiters, true);
  }
  public String toString(boolean useRecordDelim) {
    return toString(__outputDelimiters, useRecordDelim);
  }
  public String toString(DelimiterSet delimiters, boolean useRecordDelim) {
    StringBuilder __sb = new StringBuilder();
    char fieldDelim = delimiters.getFieldsTerminatedBy();
    __sb.append(FieldFormatter.escapeAndEnclose(date==null?"null":"" + date, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(pv==null?"null":"" + pv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(uv==null?"null":"" + uv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(hook==null?"null":hook, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    __sb.append(FieldFormatter.escapeAndEnclose(date==null?"null":"" + date, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(pv==null?"null":"" + pv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(uv==null?"null":"" + uv, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(hook==null?"null":hook, delimiters));
  }
  private static final DelimiterSet __inputDelimiters = new DelimiterSet((char) 1, (char) 10, (char) 0, (char) 0, false);
  private RecordParser __parser;
  public void parse(Text __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharSequence __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(byte [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(char [] __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(ByteBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  public void parse(CharBuffer __record) throws RecordParser.ParseError {
    if (null == this.__parser) {
      this.__parser = new RecordParser(__inputDelimiters);
    }
    List<String> __fields = this.__parser.parseRecord(__record);
    __loadFromFields(__fields);
  }

  private void __loadFromFields(List<String> fields) {
    Iterator<String> __it = fields.listIterator();
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.date = null; } else {
      this.date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.pv = null; } else {
      this.pv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.uv = null; } else {
      this.uv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.hook = null; } else {
      this.hook = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.date = null; } else {
      this.date = java.sql.Date.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.pv = null; } else {
      this.pv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.uv = null; } else {
      this.uv = Integer.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.hook = null; } else {
      this.hook = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    hook_stat_test o = (hook_stat_test) super.clone();
    o.date = (o.date != null) ? (java.sql.Date) o.date.clone() : null;
    return o;
  }

  public void clone0(hook_stat_test o) throws CloneNotSupportedException {
    o.date = (o.date != null) ? (java.sql.Date) o.date.clone() : null;
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("date", this.date);
    __sqoop$field_map.put("pv", this.pv);
    __sqoop$field_map.put("uv", this.uv);
    __sqoop$field_map.put("hook", this.hook);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("date", this.date);
    __sqoop$field_map.put("pv", this.pv);
    __sqoop$field_map.put("uv", this.uv);
    __sqoop$field_map.put("hook", this.hook);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("date".equals(__fieldName)) {
      this.date = (java.sql.Date) __fieldVal;
    }
    else    if ("pv".equals(__fieldName)) {
      this.pv = (Integer) __fieldVal;
    }
    else    if ("uv".equals(__fieldName)) {
      this.uv = (Integer) __fieldVal;
    }
    else    if ("hook".equals(__fieldName)) {
      this.hook = (String) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("date".equals(__fieldName)) {
      this.date = (java.sql.Date) __fieldVal;
      return true;
    }
    else    if ("pv".equals(__fieldName)) {
      this.pv = (Integer) __fieldVal;
      return true;
    }
    else    if ("uv".equals(__fieldName)) {
      this.uv = (Integer) __fieldVal;
      return true;
    }
    else    if ("hook".equals(__fieldName)) {
      this.hook = (String) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
