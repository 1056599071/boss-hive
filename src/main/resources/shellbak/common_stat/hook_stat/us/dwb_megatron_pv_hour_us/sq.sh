sqoop-export --connect "jdbc:mysql://10.110.94.162:3829/bosstdy?useUnicode=true&amp;amp;characterEncoding=UTF-8" --username bosstdy_w --password 4f0aedbb8955ce8 --table data_test --export-dir /user/hive/warehouse/dm_boss.db/temp_uid --update-mode allowinsert --input-fields-terminated-by '\001';

