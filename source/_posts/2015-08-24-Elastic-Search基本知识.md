title: Elastic Search基本知识
date: 2015-08-23 20:48:58
tags:
---
# 安装

下载安装文件

	wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.1.tar.gz
解压

	tar xvf elasticsearch-1.7.1.tar.gz
安装管理软件Marvel

	./bin/plugin -i elasticsearch/marvel/latest

# 客户端

## node client
节点客户端以无数据节点身份加入集群，本身不存储诗句，但是知道数据的位置，并且能够转发请求道对应节点上。
## transport client
不加入集群，只转发请求。
客户端都是以9300号端口交互，使用私有传输协议，ElasticSearch Transport Protocol。
http模式以9200端口交互。

# 操作

	curl -X<VERB> '<PROTOCOL>://<HOST>/<PATH>?<QUERY_STRING>' -d '<BODY>'
VERB包括 GET,POST,PUT,HEAD,DELETE
BODY为JSON格式的请求主体。

	Relational DB -> Databases -> Tables -> Rows -> Columns Elasticsearch -> Indices   -> Types  -> Documents -> Fields

关系类比。

一个集群可以包含多个索引，一个索引有多个类型，每个类型有多个文档，每个问的那个有多个字段。
一般来说，认为Document是最顶层结构/根对象 序列化成的JSON数据，而对象一般认为是一个JSON结构体，对象还能包含其他对象。
元数据主要有3个，_index,_type,_id。

## 创建

创建文档可以使用PUT，也可以使用POST，唯一的区别在于是否由用户提供_id

	POST /website/blog/
使用POST可以由ES自己生成_id，避免由于_id相同导致的碰撞，id为22位的UUID
使用

	PUT /website/blog/123?op_type=create
可以直接声明_id，但是如果id已经存在，则会替换旧的数据，_version版本号提高1，_create改为false，如果需要保证是创建而不是更新，可以使用显式的op_type参数，如果冲突，会返回409 Conflict，如果成功，会返回201 Created。
也可以使用简化

	PUT /website/blog/123/_create

## 获取

	GET /website/blog/123?pretty
可以获取文档。
参数可选
使用pretty可让文档显示的更加美观
使用_source可以控制_source字段返回的数据，ES可以仅仅返回用户需要的数据，例如_source=title,如果只使用_source，ES不返回metadata，只返回用户数据。
另外可以使用HEAD来确认文档是否存在，当返回为200时文档存在，返回为404时文档不存在

	curl -i -XHEAD http://localhost:9200/website/blog/123

## 删除

	DELETE /website/blog/123
使用DELETE来删除文档。不管文档是否删除成功，该文档的_version都会自增。

## 更新
更新可以直接使用PUT对已有数据进行更新。
也可以使用_update局部更新

## 搜索
### 空搜索
直接使用

	GET /_search
响应内容中有 `{took : times , hits : { total : n , hits : [ … ] }}`
Took表示本次请求花费的毫秒，hits表示匹配到的文档。文档中包含一个_score评分

```
{    
	"hits" : {
		"total" :14,
		"hits" : [
				{
					"_index":"us",
					"_type":"tweet",
					"_id":"7",
					"_score":1,
					"_source": {
								"date":	"2014-09-17",
								"name":	"John Smith",	
								"tweet":"The Query DSL is really powerful and flexible",
								"user_id": 2
								}        
				},
				... 9 RESULTS REMOVED ...       
		],       
		"max_score" :   1   
	},    
	"took" :4,    
	"_shards" : {       
		"failed" :0,       
		"successful" :10,       
		"total" :10   
	},
	"timed_out" :false
}
```
评分为relevance score，在提供了查询条件的情况下，文档按照相关性评分降序排列。
_shards表示参数查询的分片数。
time_out表示是否超时，如果要求响应速度，可以限制time_out，这样ES会在请求超时前返回收集到的结果

	GET /_search?timeout=10ms

### 限定搜索

	/index[,index]/_search 限制在几个索引间搜索数据
也可以使用通配符搜索。/g*/_search，以g开头的index中搜索。

	/index[,index]/type[,type]/_search 在index索引中，搜索type中的文档。

### 分页

	GET /_search?size=5&from=10

### 简单搜索

	GET /index/type/search?q=key:value
表示搜索key字段包含value的文档

	+k1:(v1 v3) -k2:v2 +date:>2014-09-10
表示必须含有k1:v1,v3和必须没有k2:v2，时间大于给定时间的文档

	GET /_search?q=value
表示含有value的文档。因为ES会将所有的字段拼接起来，形成一个_all字段，最终被ES索引。
    
一般搜索结构：
```
{
	QUERY_NAME: {
		FIELD_NAME: {
			ARGUMENT: VALUE,
			ARGUMENT: VALUE,
			...
		}
	} 
}
```

### 过滤

* term : `"term":{ k:v }` 主要用于精确匹配，包括bool，日期，数字，未经分析的字符串。
* terms : `"terms":{ k:[v1,v2] }` 可以用于精确匹配多个值。
* range : `"range": { k:{"lte":20,"gte":30} }` 可以用于指定范围查找数据，范围操作符包含:gt,gte,lt,lte
* exists|missing : `"exists":{ "field":"k" }` 这两个过滤语句仅用于已经找到文档后的过滤
* bool过滤 : 
	```
	"bool": { 
		"must": { 
			"term": { "folder": "inbox" }
			},
		"should": [{ … },{ … }] 
	}
	```
	可以用来合并多个过滤条件查询结果的布尔逻辑。
    must表示多个结果的完全匹配，must_not表示多个结果的完全匹配的否定，should表示至少有一个查询条件匹配

### 查询

* match_all : `"match_all": {}` 表示匹配所有文档
* match : match是一个标准查询
* multi_match : `"multi_match":{ k:v, k:[v,v] }` 允许一次查询多个字段
* bool查询 : 
	```
	"bool": { 
		"must": { 
			"match": { "title": "how to make millions" }
		} 
	}
	```
	bool查询相比bool过滤多了一部查询_score的步骤

### 组合查询

过滤和查询需要放置在对应的context当中，过滤对应filter，查询对应query
由于search API中只能使用query语句，所以多重查询中需要使用filtered来包含query和其他过滤语句。
例如同时使用match查询和term过滤。
```
"query": { 
	"filtered": { 
		"query": { "match": { k:v } }, 
		"filter": { "term": { k:v } } 
	}
}
```
如果想要匹配所有的文档，可以忽略query语句的match查询，这样filtered会默认补充一个match_all的查询。以下两句效果相同。

```
 "query": { "filtered": { "query": { "match_all": { } } , "filter": { "term": { k:v } } }
 "query": { "filtered": { "filter": { "term": { k:v } } }
```
另外，过滤语句中可以使用query方式代替bool过滤子句。
例如 `"must_not": { "query" : { ... } }` 但是这种方式使用比较少。

### 查询检测 - validate API
validate API可以用于检测查询语句是否合法。

	GET /index/type/_validate/query <BODY>
如果需要查询具体错误信息，可以加上explain参数,query?explain
如果查询语句合法的情况下，explain会针对每一个index返回不同的描述。因为不同的index有不同的映射关系和分析器，例如tweet:powerful这样的查询语句，在一个分析器里可能查询powerful单词，在另外一个使用english分析器的index里就是查询power单词。

### 排序
#### 默认排序： _score
一般情况下得到的文档都以_score降序排列，相关性高的排在前面。过滤语句不影响_score，如果使用了match_all或者隐式使用了match_all，那么所有的文档的得分都是1.

#### 字段值排序
使用sort对字段值进行排序。

	{ "query" : { … }, "sort": { "date": { "order": "desc" } } }
如果使用了sort排序，那么在没有显式指定track_scores为true的情况下，每一个文档的_score和查询的max_score都不会被计算。
因为相关性的计算比较消耗性能，如果指定了排序规则，就没有必要计算了。另外假如排序是date的情况下，date会被转成timestamp用于计算。

如果需要顺序排列时，可以使用简写。 `"sort": "key"`
如果需要多级排序，可以使用： `"sort": [ k1:{"order": "desc" }, k2:{"order": "desc" } ]`
如果需要排列的字段是一个数组，那么可以使用min, max, avg 或 sum这些模式来排序。`"sort": { k1:{"order": "desc","mode": "min" } }`

如果对于针对全文搜索而使用了analyzer的字段上进行排序，很难得到正确的结果。因此针对这些值，需要重新指定类型。
默认：
```
"tweet": {
	"type":"string",
	"analyzer": "english"
}
```
修改后：
```
"tweet": {
    "type":     "string",
    "analyzer": "english",
    "fields": {
        "raw": { 
            "type":  "string",
            "index": "not_analyzed"
        }
    }
}
```
tweet 字段用于全文本的 analyzed 索引方式不变。新增的 tweet.raw 子字段索引方式是 not_analyzed。
后面可以使用 `"sort": "tweet.raw"` 来对这个字段进行排序。

