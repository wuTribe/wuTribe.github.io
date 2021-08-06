---
title: Redis和MongoDB的区别
date: 2021-8-5 21:29:04
categories:
- 学习/面试
tags:
- 面试
- Redis
- MongoDB
description: 转载：Redis和MongoDB的区别
---

转载：[Redis和MongoDB的区别(面试受用)](https://www.cnblogs.com/java-spring/p/9488227.html)

项目中用的是MongoDB，但是为什么用其实当时选型的时候也没有太多考虑，只是认为数据量比较大，所以采用MongoDB。

最近又想起为什么用MongoDB，就查阅一下，汇总汇总：

之前也用过redis，当时是用来存储一些热数据，量也不大，但是操作很频繁。现在项目中用的是MongoDB，目前是百万级的数据，将来会有千万级、亿级。

就Redis和MongoDB来说，大家一般称之为**Redis缓存、MongoDB数据库**。这也是有道有理有根据的，

Redis主要把数据存储在内存中，其“缓存”的性质远大于其“数据存储“的性质，其中数据的增删改查也只是像变量操作一样简单；

MongoDB却是一个“存储数据”的系统，增删改查可以添加很多条件，就像SQL数据库一样灵活，这一点在面试的时候很受用。

# MongoDB语法与现有关系型数据库SQL语法比较

| MongoDB语法                                                  | MySql语法                                            |
| ------------------------------------------------------------ | ---------------------------------------------------- |
| `db.test.find({'name':'foobar'})`                            | `select * from test where name='foobar'`             |
| `db.test.find()`                                             | `select * from test`                                 |
| `db.test.find({'ID':10}).count()`                            | `select count(*) from test where ID=10`              |
| `db.test.find().skip(10).limit(20)`                          | `select * from test limit 10,20`                     |
| `db.test.find({'ID':{$in:[25,35,45]}})`                      | `select * from test where ID in (25,35,45)`          |
| `db.test.find().sort({'ID':-1})`                             | `select * from test order by IDdesc`                 |
| `db.test.distinct('name',{'ID':{$lt:20}})`                   | `select distinct(name) from testwhere ID<20`         |
| `db.test.group({key:{'name':true},cond:{'name':'foo'},reduce:function(obj,prev){prev.msum+=obj.marks;},initial:{msum:0}})` | `select name,sum(marks) from testgroup by name`      |
| `db.test.find('this.ID<20',{name:1})`                        | `select name from test whereID<20`                   |
| `db.test.insert({'name':'foobar','age':25})`                 | `insertinto test ('name','age') values('foobar',25)` |
| `db.test.remove({})`                                         | `delete * from test`                                 |
| `db.test.remove({'age':20})`                                 | `delete test where age=20`                           |
| `db.test.remove({'age':{$lt:20}})`                           | `delete test where age<20`                           |
| `db.test.remove({'age':{$lte:20}})`                          | `delete test where age<=20`                          |
| `db.test.remove({'age':{$gt:20}})`                           | `delete test where age>20`                           |
| `db.test.remove({'age':{$gte:20}})`                          | `delete test where age>=20`                          |
| `db.test.remove({'age':{$ne:20}})`                           | `delete test where age!=20`                          |
| `db.test.update({'name':'foobar'},{$set:{'age':36}})`        | `update test set age=36 where name='foobar'`         |
| `db.test.update({'name':'foobar'},{$inc:{'age':3}})`         | `update test set age=age+3 where name='foobar'`      |
| `db.test.find({"name":{$regex:"aaa"}})`                      | 模糊查询：$regex                                     |
| `db.getCollection('id_mapper').aggregate([{$group:{ _id :"$contract_id",count:{$sum:1}}},{$match:{count:{$gt:1}}}])` | 分组个数过滤                                         |
| `db.getCollection('id_mapper').find({"sinocardid":{$in:[null]}})` | 判断是否为空                                         |



# Mongodb与Redis应用指标对比

MongoDB和Redis都是NoSQL，采用结构型数据存储。二者在使用场景中，存在一定的区别，这也主要由于
二者在内存映射的处理过程，持久化的处理方法不同。MongoDB建议集群部署，更多的考虑到集群方案，Redis
更偏重于进程顺序写入，虽然支持集群，也仅限于主-从模式。

 

| 指标       | MongoDB(v2.4.9)                                              | Redis(v2.4.17)                                               | 比较说明                                                     |
| ---------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 实现语言   | C++                                                          | C/C++                                                        | -                                                            |
| 协议       | BSON、自定义二进制                                           | 类Telnet                                                     | -                                                            |
| 性能       | 依赖内存，TPS较高                                            | 依赖内存，TPS非常高                                          | Redis优于MongoDB                                             |
| 可操作性   | 丰富的数据表达、索引；最类似于关系数据库，支持丰富的查询语言 | 数据丰富，较少的IO                                           | MongoDB优于Redis                                             |
| 内存及存储 | 适合大数据量存储，依赖系统虚拟内存管理，采用镜像文件存储；内存占有率比较高，官方建议独立部署在64位系统（32位有最大2.5G文件限制，64位没有改限制） | Redis2.0后增加虚拟内存特性，突破物理内存限制；数据可以设置时效性，类似于memcache | 不同的应用角度看，各有优势                                   |
| 可用性     | 支持master-slave,replicaset（内部采用paxos选举算法，自动故障恢复）,auto sharding机制，对客户端屏蔽了故障转移和切分机制 | 依赖客户端来实现分布式读写；主从复制时，每次从节点重新连接主节点都要依赖整个快照,无增量复制；不支持自动sharding,需要依赖程序设定一致hash机制 | MongoDB优于Redis；单点问题上，MongoDB应用简单，相对用户透明，Redis比较复杂，需要客户端主动解决。（MongoDB 一般会使用replica sets和sharding功能结合，replica sets侧重高可用性及高可靠性，而sharding侧重于性能、易扩展） |
| 可靠性     | 从1.8版本后，采用binlog方式（MySQL同样采用该方式）支持持久化，增加可靠性 | 依赖快照进行持久化；AOF增强可靠性；增强可靠性的同时，影响访问性能 | MongoDB优于Redis                                             |
| 一致性     | 不支持事务，靠客户端自身保证                                 | 支持事务，比较弱，仅能保证事务中的操作按顺序执行             | Redis优于MongoDB                                             |
| 数据分析   | 内置数据分析功能（mapreduce）                                | 不支持                                                       | MongoDB优于Redis                                             |
| 应用场景   | 海量数据的访问效率提升                                       | 较小数据量的性能及运算                                       | MongoDB优于Redis                                             |