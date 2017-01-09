package com.letv.boss.stat.mongo.service;

import com.letv.boss.stat.mongo.model.Person;
import com.mongodb.Mongo;
import org.springframework.data.mongodb.core.MongoOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;

import static org.springframework.data.mongodb.core.query.Criteria.where;

/**
 * Created by kangxiongwei3 on 2016/10/12 20:53.
 */
public class MongoApp01 {

    public static void main(String[] args) {
        MongoOperations mongoOps = new MongoTemplate(new Mongo(), "test");
        mongoOps.insert(new Person("Joe", 34));

        Person person = mongoOps.findOne(new Query(where("name").is("Joe")), Person.class);

        System.out.println(person);

        //mongoOps.dropCollection("person");
    }


}
