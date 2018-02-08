// ORM class for table 'data_test'
// WARNING: This class is AUTO-GENERATED. Modify at your own risk.
//
// Debug information:
// Generated date: Fri Nov 18 18:47:19 CST 2016
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

public class data_test extends SqoopRecord  implements DBWritable, Writable {
  private final int PROTOCOL_VERSION = 3;
  public int getClassFormatVersion() { return PROTOCOL_VERSION; }
  protected ResultSet __cur_result_set;
  private Long aa;
  public Long get_aa() {
    return aa;
  }
  public void set_aa(Long aa) {
    this.aa = aa;
  }
  public data_test with_aa(Long aa) {
    this.aa = aa;
    return this;
  }
  private String id;
  public String get_id() {
    return id;
  }
  public void set_id(String id) {
    this.id = id;
  }
  public data_test with_id(String id) {
    this.id = id;
    return this;
  }
  private String uid;
  public String get_uid() {
    return uid;
  }
  public void set_uid(String uid) {
    this.uid = uid;
  }
  public data_test with_uid(String uid) {
    this.uid = uid;
    return this;
  }
  private String uuid;
  public String get_uuid() {
    return uuid;
  }
  public void set_uuid(String uuid) {
    this.uuid = uuid;
  }
  public data_test with_uuid(String uuid) {
    this.uuid = uuid;
    return this;
  }
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof data_test)) {
      return false;
    }
    data_test that = (data_test) o;
    boolean equal = true;
    equal = equal && (this.aa == null ? that.aa == null : this.aa.equals(that.aa));
    equal = equal && (this.id == null ? that.id == null : this.id.equals(that.id));
    equal = equal && (this.uid == null ? that.uid == null : this.uid.equals(that.uid));
    equal = equal && (this.uuid == null ? that.uuid == null : this.uuid.equals(that.uuid));
    return equal;
  }
  public boolean equals0(Object o) {
    if (this == o) {
      return true;
    }
    if (!(o instanceof data_test)) {
      return false;
    }
    data_test that = (data_test) o;
    boolean equal = true;
    equal = equal && (this.aa == null ? that.aa == null : this.aa.equals(that.aa));
    equal = equal && (this.id == null ? that.id == null : this.id.equals(that.id));
    equal = equal && (this.uid == null ? that.uid == null : this.uid.equals(that.uid));
    equal = equal && (this.uuid == null ? that.uuid == null : this.uuid.equals(that.uuid));
    return equal;
  }
  public void readFields(ResultSet __dbResults) throws SQLException {
    this.__cur_result_set = __dbResults;
    this.aa = JdbcWritableBridge.readLong(1, __dbResults);
    this.id = JdbcWritableBridge.readString(2, __dbResults);
    this.uid = JdbcWritableBridge.readString(3, __dbResults);
    this.uuid = JdbcWritableBridge.readString(4, __dbResults);
  }
  public void readFields0(ResultSet __dbResults) throws SQLException {
    this.aa = JdbcWritableBridge.readLong(1, __dbResults);
    this.id = JdbcWritableBridge.readString(2, __dbResults);
    this.uid = JdbcWritableBridge.readString(3, __dbResults);
    this.uuid = JdbcWritableBridge.readString(4, __dbResults);
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
    JdbcWritableBridge.writeLong(aa, 1 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeString(id, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(uid, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(uuid, 4 + __off, 12, __dbStmt);
    return 4;
  }
  public void write0(PreparedStatement __dbStmt, int __off) throws SQLException {
    JdbcWritableBridge.writeLong(aa, 1 + __off, -5, __dbStmt);
    JdbcWritableBridge.writeString(id, 2 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(uid, 3 + __off, 12, __dbStmt);
    JdbcWritableBridge.writeString(uuid, 4 + __off, 12, __dbStmt);
  }
  public void readFields(DataInput __dataIn) throws IOException {
this.readFields0(__dataIn);  }
  public void readFields0(DataInput __dataIn) throws IOException {
    if (__dataIn.readBoolean()) { 
        this.aa = null;
    } else {
    this.aa = Long.valueOf(__dataIn.readLong());
    }
    if (__dataIn.readBoolean()) { 
        this.id = null;
    } else {
    this.id = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.uid = null;
    } else {
    this.uid = Text.readString(__dataIn);
    }
    if (__dataIn.readBoolean()) { 
        this.uuid = null;
    } else {
    this.uuid = Text.readString(__dataIn);
    }
  }
  public void write(DataOutput __dataOut) throws IOException {
    if (null == this.aa) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.aa);
    }
    if (null == this.id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, id);
    }
    if (null == this.uid) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, uid);
    }
    if (null == this.uuid) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, uuid);
    }
  }
  public void write0(DataOutput __dataOut) throws IOException {
    if (null == this.aa) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    __dataOut.writeLong(this.aa);
    }
    if (null == this.id) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, id);
    }
    if (null == this.uid) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, uid);
    }
    if (null == this.uuid) { 
        __dataOut.writeBoolean(true);
    } else {
        __dataOut.writeBoolean(false);
    Text.writeString(__dataOut, uuid);
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
    __sb.append(FieldFormatter.escapeAndEnclose(aa==null?"null":"" + aa, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(id==null?"null":id, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(uid==null?"null":uid, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(uuid==null?"null":uuid, delimiters));
    if (useRecordDelim) {
      __sb.append(delimiters.getLinesTerminatedBy());
    }
    return __sb.toString();
  }
  public void toString0(DelimiterSet delimiters, StringBuilder __sb, char fieldDelim) {
    __sb.append(FieldFormatter.escapeAndEnclose(aa==null?"null":"" + aa, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(id==null?"null":id, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(uid==null?"null":uid, delimiters));
    __sb.append(fieldDelim);
    __sb.append(FieldFormatter.escapeAndEnclose(uuid==null?"null":uuid, delimiters));
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
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.aa = null; } else {
      this.aa = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.id = null; } else {
      this.id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.uid = null; } else {
      this.uid = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.uuid = null; } else {
      this.uuid = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  private void __loadFromFields0(Iterator<String> __it) {
    String __cur_str = null;
    try {
    __cur_str = __it.next();
    if (__cur_str.equals("null") || __cur_str.length() == 0) { this.aa = null; } else {
      this.aa = Long.valueOf(__cur_str);
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.id = null; } else {
      this.id = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.uid = null; } else {
      this.uid = __cur_str;
    }

    __cur_str = __it.next();
    if (__cur_str.equals("null")) { this.uuid = null; } else {
      this.uuid = __cur_str;
    }

    } catch (RuntimeException e) {    throw new RuntimeException("Can't parse input data: '" + __cur_str + "'", e);    }  }

  public Object clone() throws CloneNotSupportedException {
    data_test o = (data_test) super.clone();
    return o;
  }

  public void clone0(data_test o) throws CloneNotSupportedException {
  }

  public Map<String, Object> getFieldMap() {
    Map<String, Object> __sqoop$field_map = new TreeMap<String, Object>();
    __sqoop$field_map.put("aa", this.aa);
    __sqoop$field_map.put("id", this.id);
    __sqoop$field_map.put("uid", this.uid);
    __sqoop$field_map.put("uuid", this.uuid);
    return __sqoop$field_map;
  }

  public void getFieldMap0(Map<String, Object> __sqoop$field_map) {
    __sqoop$field_map.put("aa", this.aa);
    __sqoop$field_map.put("id", this.id);
    __sqoop$field_map.put("uid", this.uid);
    __sqoop$field_map.put("uuid", this.uuid);
  }

  public void setField(String __fieldName, Object __fieldVal) {
    if ("aa".equals(__fieldName)) {
      this.aa = (Long) __fieldVal;
    }
    else    if ("id".equals(__fieldName)) {
      this.id = (String) __fieldVal;
    }
    else    if ("uid".equals(__fieldName)) {
      this.uid = (String) __fieldVal;
    }
    else    if ("uuid".equals(__fieldName)) {
      this.uuid = (String) __fieldVal;
    }
    else {
      throw new RuntimeException("No such field: " + __fieldName);
    }
  }
  public boolean setField0(String __fieldName, Object __fieldVal) {
    if ("aa".equals(__fieldName)) {
      this.aa = (Long) __fieldVal;
      return true;
    }
    else    if ("id".equals(__fieldName)) {
      this.id = (String) __fieldVal;
      return true;
    }
    else    if ("uid".equals(__fieldName)) {
      this.uid = (String) __fieldVal;
      return true;
    }
    else    if ("uuid".equals(__fieldName)) {
      this.uuid = (String) __fieldVal;
      return true;
    }
    else {
      return false;    }
  }
}
