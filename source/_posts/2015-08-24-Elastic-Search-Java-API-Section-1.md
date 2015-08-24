title: Elastic Search Java API Section 1
date: 2015-08-24 16:25:37
tags:
---

# 配置
Maven配置。现在es的最新的release版本为1.7.1
```
<dependency>
     <groupId>org.elasticsearch</groupId>
     <artifactId>elasticsearch</artifactId>
     <version>${es.version}</version>
</dependency>
```

# 客户端类型
## Node Client
 
加入ES集群中，但是不持有数据，不会被选举成为Master节点(作为clients时)，能够获取整个集群状态，执行API时可以减少一次网络跳跃。
因为Node Client拥有集群的数据，操作可以自动路由到操作最终会被执行的节点，而不需要制定double hop。
适用于客户端中需要少量生存时间较长的连接，并且Node Client相比Transport Client更加效率。

通过cluster.name加入集群。可以直接配置resoures/elasticsearch.yml设置cluster.name，也可以使用代码加入特定集群。
```
Node node = NodeBuilder.nodeBuilder().clusterName("yourclustername").node(); Client client = node.client();
```
如果希望这个节点不保存数据，不被选为Master，需要指定`nodeBuilder.client(true)`。或者将node.data设置为false。
data和client的区别在于，data只是不保存数据，但是可以被选为master，client不保存数据，也不会被选为master。
在需要进行单元测试时，可以将node设置为local模式。运行在本地JVM上，本地的两个服务可以组成一个集群。

## Transport Client
不加入集群中，只有通信的作用。用于将应用和集群解耦，用于快速创建和销毁连接，更加轻量级。
在没有修改集群名字的情况下可以直接使用TransportClient。
```
Client client = new TransportClient()
        .addTransportAddress(new InetSocketTransportAddress("host1", 9300))
        .addTransportAddress(new InetSocketTransportAddress("host2", 9300));

// on shutdown
client.close();
```
如果集群名字不是默认的”elasticsearch”，就需要修改yml配置或者在代码中配置。否则会提示None of the configured nodes are available
```
Settings setting = ImmutableSettings.settingsBuilder().put("cluster.name", "slixurd").build();
Client client = new TransportClient(setting)
     .addTransportAddress(new InetSocketTransportAddress("172.16.63.129", 9300));
```

# 客户端操作

## 索引
增加一个文档实际上就是将文档添加到一个特定的索引上。
生成Json文档有如下4种方式。
1. 手写Json，用String自己生成一个Json。
2. 使用Map，正如一般的kv对一样，该怎么写怎么写。
3. Jackson，可以简单的将bean序列化为Json。
```
ObjectMapper mapper = new ObjectMapper();
String json = mapper.writeValueAsString( bean );
```
4. 使用Elasticsearch Helper
```
XContentBuilder builder = XContentFactory.jsonBuilder()
    .startObject()
        .field("k", "v")
    .endObject()
String json = builder.string();
```

新建的API为：
```
IndexRequestBuilder prepareIndex(String index, String type, @Nullable String id);
IndexRequestBuilder prepareIndex(String index, String type);
```
可以通过client使用prepareIndex
```
IndexResponse response = client.prepareIndex("twitter","tweet","3").setSource(json).execute().actionGet();
```
SetSource函数可以接收一个Mapper，或者一个XContentBuilder,也可以接收一个字符串。
execute返回一个future的子类，actionGet得到ES包装后的一个Response。这个IndexResponse中包含index,id,type,version,created五个属性。

## 获取
```
GetResponse response = client.prepareGet(index, type, id).execute().actionGet();
GetResponse response = client.prepareGet(index, type, id).setOperationThreaded(false).execute().actionGet();
```
通过GetResponse保存获得的数据。prepareGet检索对应的文档。还可以使用setOperationThreaded控制执行的线程，默认为true，执行在其他线程上。

## 删除
```
DeleteResponse response = client.prepareDelete(index, type, id).execute().actionGet();
```
## 修改
通过UpdateRequest创建Request，然后使用client的update函数更新
```
UpdateRequest updateRequest = new UpdateRequest(index, type, id);
updateRequest.doc(jsonBuilder().startObject().field(key, value).endObject());
client.update(updateRequest).get();
```
也可以使用prepareUpdate函数,get相当于execute().actionGet()。
```
UpdateResponse response = client.prepareUpdate(index, type, id).setDoc(doc).get();
```
API还提供了一个类似Mysql的INSERT ... ON DUPLICATE KEY UPDATE函数 upsert。
```
UpdateResponse response = client.prepareUpdate(index, type, id)
     .setUpsert(XContentFactory.jsonBuilder().startObject().field(k1, v1).endObject())
     .setDoc(XContentFactory.jsonBuilder().startObject().field(k1, v2).endObject()).get();
```
当index，type，id三者决定的唯一文档不存在时，那么插入k1，v1的这个对象，如果文档存在，则把k1更新为v2.

## Bulk API
```
BulkRequestBuilder bulkRequest = client.prepareBulk();
bulkRequest.add(client.prepareIndex(index, type, id).setSource(doc1));
bulkRequest.add(deleteRequest);
BulkResponse bulkResponse = bulkRequest.execute().actionGet();
```
BulkResponse内部包含一个数组，为每一个失败的请求保留一份记录。
可以用于批量更新，批量删除，批量索引。


