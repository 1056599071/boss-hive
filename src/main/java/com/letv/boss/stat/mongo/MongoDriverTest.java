package com.letv.boss.stat.mongo;

import com.mongodb.MongoClient;
import com.mongodb.MongoCredential;
import com.mongodb.ServerAddress;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Jdbc访问Mongo
 * Created by kangxiongwei3 on 2016/9/28 17:36.
 */
public class MongoDriverTest {

    public static void main(String[] args) throws ClassNotFoundException, SQLException, ParseException {
        //mongoOperation();
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
        Date today = format.parse("2016-09-28");
        System.out.println(today.getTime());
        Date yesterday = format.parse("2016-09-27");
        System.out.println(yesterday.getTime());
    }

    private static void mongoOperation() {
    /*MongoClient client = new MongoClient("localhost", 27017);
    MongoDatabase database = client.getDatabase("test");*/

        ServerAddress serverAddress1 = new ServerAddress("10.212.23.161", 9005);
        ServerAddress serverAddress2 = new ServerAddress("10.212.23.162", 9005);
        ServerAddress serverAddress3 = new ServerAddress("10.212.23.163", 9005);

        List<ServerAddress> serverAddressesList = new ArrayList<ServerAddress>();
        serverAddressesList.add(serverAddress1);
        serverAddressesList.add(serverAddress2);
        serverAddressesList.add(serverAddress3);

        MongoCredential credential = MongoCredential.createScramSha1Credential("admin", "admin", "NmNmODhkMmI0M2Z".toCharArray());
        List<MongoCredential> credentials = new ArrayList<MongoCredential>();
        credentials.add(credential);

        MongoClient client = new MongoClient(serverAddressesList, credentials);
        MongoDatabase mongoDatabase = client.getDatabase("music_in");
        System.out.println("成功连接到数据库" + mongoDatabase.getName());

        MongoCollection<Document> collection = mongoDatabase.getCollection("user_record");

        //检索所有文档
        /**
         * 1. 获取迭代器FindIterable<Document>
         * 2. 获取游标MongoCursor<Document>
         * 3. 通过游标遍历检索出的文档集合
         * */
        FindIterable<Document> findIterable = collection.find();
        MongoCursor<Document> mongoCursor = findIterable.iterator();
        int i = 0;
        while (mongoCursor.hasNext()) {
            Document document = mongoCursor.next();
            Object userId = document.get("user_id");
            Object ctime = document.get("ctime");
            Date date = new Date((Long) ctime);
            SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String firstTime = format.format(date);
            System.out.println("userId = " + userId + ", firstTime = " + firstTime);
            i++;
        }
        System.out.println("一共查询到" + i + "条记录");
    }


}
