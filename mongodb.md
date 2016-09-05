###mongodb
分布式数据库
###插入命令
1. MongoDB 不需要预先定义 collections，在数据第一次插入时 collections 被自动创建。
2. 在一个 collections 中不同的 documents 可以有不同的字段。这个重点介绍一下就是每条数据中的item数量是不一样的
![db.dbname.find()](D:\tools\works\workspace\md\png\mongodbfind.png)
3. 在 collections 中的每个 documents 在插入时会分配一个不同的 ObjectId，字段为 "_id"。

db.dbname.save({string:"hello",num:1});

###批量插入

for (var i = 1; i <= 30; i++) db.things.save({id : i, name : 'aaa'});

###查询数据库中的数据
db.dbname.find()

###显示所有的collection
show collections;

###删除collection
db.集合名.drop()

###删除指定集合内包含有这文档的


###针对java的操作
* **$set**
	* 思考：
		* 如何直接更新子对象中的数据，直接采用如下的操作会将("$set", new BasicDBObject().append("detail", new BasicDBObject("records",100))),会直接将子对象进行覆盖
	* $set: { "favorites.artist": "Pisanello", type: 3 }  
		1. 受官网上的例子启发，更新子对象中的数据字段采用"favorites.artist"，直接更新首层字段中的数据采用
		2. type：3	在java的方法中亦是如此
* **$inc**
	* 亦是如此


###mongodb 中的聚合操作
1. [官方介绍](https://docs.mongodb.com/getting-started/java/aggregation/)
2. [代码参考](http://stackoverflow.com/questions/32748587/multiple-group-in-mongodb-aggregation-with-java)
3. [group名命令中的参数](https://docs.mongodb.com/manual/reference/operator/aggregation/group/#pipe._S_group)  
4. 官方的介绍上只有关于  aggregation _id singal 的解释 但是现在想实现的情况是 muti 的情况 
于是我将代码改为
<pre><code>AggregateIterable<Document> iterable = dao.getCollection("load_action_response_time").aggregate(asList(new Document("$group",new Document("_id", "$jobName")
		.append("_id", "$actionId")
		.append("totalnum", new Document("$sum", 1))
		.append("totalResponseSize", new Document("$sum", "$responseSize"))
		.append("totalResponsTime", new Document("$sum", "$responseTime")))));
</pre></code>
这个样子是不起作用的，参考mongo的命令，对应的样子应该是
<pre><code>{ "$group" : { "_id" : { "productID": "$productID", 
	         "articleID": "$articleID", "colour":"$colour",
	         "set&size": { "sku" : "$skuID", "size" : "$size" },  
	        }, 
	}
},
</code></pre>

那么我就按照这样的方式写成如下的形式
<pre><code>	.aggregate(asList(new Document("$group",
new Document("_id",  new Document("jobName","$jobName").append("actionId", "$actionId"))
.append("totalnum", new Document("$sum", 1)
.append("totalnum", new Document("$sum", 1))
.append("totalResponseSize", new Document("$sum", "$responseSize"))
.append("totalResponsTime", new Document("$sum", "$responseTime")))));
</pre></code>


###分组排序
61.135.251.180:27017  bizme/fbizgg
