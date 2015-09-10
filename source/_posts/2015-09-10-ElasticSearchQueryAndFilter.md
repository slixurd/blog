title: ElasticSearch的搜索和过滤
help: true
date: 2015-09-10 15:31:46
tags:
---
# 查询

## Match
Match查询接收一个类型为text/numerics/dates的值，分析后返回一个查询，例如 `{"match":{ k:v } }`。

默认的match查询是bool类型的，这意味着match提供的字符串会被分析器拆分成子串，然后构造成Bool查询,例如quick Fox会被拆成quick和fox。
因此match查询提供了一个operator参数，可以用于设置or/and来控制bool查询，默认是or。另外还有一个 minimum_should_match参数来控制should子句应该匹配的最少的数目。
例如有内容为Quick Fox的文档(并且不是Not_Analyzed的域)，当提供v为fox one的条件搜索时，可以匹配结果，因为倒排链表保存的就是fox，而且match的内容fox one会被拆分成fox和one去匹配。

Match查询需要和Term查询区分，Term查询不会分析单词串，如果查找Fox，那么在倒排索引中就找不到数据。

zero_terms_query参数有none和all两个值，表示当所有词被分析器移除时（例如to be or not to be）查询应该返回所有文档还是什么都不返回。


## Multi_match查询
基于query查询提供的查询。
```
query: v
fields: [k1,k2]
```
和query不同的是，fields的参数可以提供通配符支持，比如fields可以填入*name用于匹配last_name, first_name。由于query需要计算评分，所以这里可以指定某个field的权重。例如subject^3表示subject的权重为其余field的3倍。multi_match实际上会生成在dis_max查询下的多个match查询。可以通过把use_dis_max设为false来将dis_max转换为bool查询。

multi_match的type参数可以决定查询结果的排序。有以下几个值：
1. best_fields:匹配所有field，但是用得分最高的match查询来决定整个查询的分数。tie_breaker参数可以让其他field的_score也参与计算。最终计算为Best_score + SUM _score * tie_breaker。
2. most_fields:匹配所有field，然后加权平均，如果没有指定权重就直接使用算数平均值

## Term查询
这个查询仅仅匹配给定字段中含有关键字的文档，而且是未经分析的关键字。Term查询还可以指定加权属性Boost(float)。
```
"term":{
     "k":{
          "value":v,
          "boost":10.0
     }
}
"term":{k:v}
```
## Terms查询
和Term查询一样，关键字不予分析。提供多个关键字所有，可以配置minimum_match属性，表示至少有minimum_match个词条应该被匹配。
```
"terms":{
     k:[v1,v2],
     "minimum_match":1
}
```
## Common查询
主要解决因为高频词（例如stop words)造成的查询问题，例如一个关键字a and b，如果使用正常的match查询，那么and被分析器拆开单独匹配文档时会匹配到大量的文档。因此需要对这类高频词进行处理。这里提供一个cutoff_frequency，定义一个值，来决定什么样的词是低频词，例如提供0.01，表示词频低于1%的为低频词。另外还可以提供high_freq_operator/low_freq_operator来决定词条间的关系，可以设置为and，or，例如high_freq_operator:and表示高频词组需要都出现，文档才能被匹配。
```
common:{
     k:{
          query:v,
          cutoff_frequency:0.01
     }
}
```

## Match_phrase查询
类似于match查询，不过不需要指定operator。而是以slop的值来构建短语查询。
当slop为1时，表示词条和文档之间能有多少个未知词条。默认为0.表示 a b不能和a and b匹配。

## Query String查询
Lucene式查询。`query_string:{query: +k:v^10 -k:v +k:(+v +v) +v}`。可以指定不带k时默认查询的k，default_field默认为_all。
lowercase_expand_terms表示是否需要将词条转换为小写再来查找，默认为true。
可以指定查询的fields。另外还有一个use_dis_max参数，值为bool。
Dis表示Disjunction，可以跨多个字段查询，每个字段有不同权重。Max表示对给定词条，直邮最高分的才在最后评分中，而不是简单求和。

此外还有一个simple_query_string。这个查询在query的参数有无效部分的情况下，会忽视无效部分，而不会抛出异常。

## IDS查询
标志符查询。
`ids:{ values: [id,id,id….] }`
返回匹配这些id的文档。可以制定type。

## Prefix查询 
前缀查询。查询字符串前缀。查询的字符串不会被分析，所以quick Fox不可以被Fo匹配。

## Fuzzy查询
模糊查询。可以让用户以crme查出crime这样的文档
value提供查询的词条。min_similarity表示最小相似度，对于字符串而言这应该在0-1之间，对数值而言，这是差值的绝对值，例如最小相似度是3，对于值20，可以匹配17-23之间的值，对日期而言，可以设为1d,1m,1s，表示时间相差长度。

## Wildcard查询
通配符查询。支持通配符*,?。*匹配任意字符串,?匹配任意字符。

## Range查询
查询一个字段在某个范围内的文档。使用gte,lte,le,te作为参数，具体范围作为值。

## Dis Max查询
最大分查询。
和multi_match的best_field一样。用得分最高的match查询来决定整个查询的分数。tie_breaker参数可以让其他field的_score也参与计算。最终计算为Best_score + SUM _score * tie_breaker。
```
"query": {
     "dis_max": {
          "tie_breaker": 0.7,
          "boost": 1.2,
          "queries": []
     }
}
```
## 正则查询
提供正则表达式查询。查询词条可以包含正则表达式。

## Bool查询
提供should,must,must_not的子句。

## Boosting查询
加权查询。
提供positive和negative查询。positive部分不改变_score，negative部分降低_score。需要提供negative_boost参数表示降分的程度。

# 过滤
查询用于使用不同条件得到结果及其评分，然而要在不影响评分的情况下获得子集，就需要过滤器。
过滤器不需要耗费CPU计算评分，因此相对速度比较快，而且过滤能够被索引。

过滤有两个大类型。
一个是post_filter,和query同级，执行操作时先通过query查询文档，再使用过滤器过滤。
而另外一种filtered过滤，内部包含query和filter，会先过滤再查询。性能稍微好一点。

过滤器类型大体和查询相似。

## Range过滤器。
用于过滤范围。

## Exists 过滤器。
提供一个field作为参数，要求返回的文档必须有该field

## Missing过滤器
和exists相反，要求文档必须没有field字段。
另外还提供null_value参数，用于判断什么是“没有”该字段，例如null_value为0，表示所有field为0的文档或者没有该field的文档都会被返回。existence表示需要检查field的值，和null_value需要一起使用。

## Script过滤器
用于计算过滤。script: `"1000 - doc['num'] > 100"`。找出1000-num大于100的文档。

## Type过滤器
`type: { value : FIELD }`
限制返回的文档的TYPE

## Limit过滤器
限定单个shard返回的文档数目。

## And/Or/Not
可以使用逻辑过滤器，内部可以套嵌多个过滤器。

其余可以使用的查询都可以套嵌在Query中，功能一样，只是不影响评分。

