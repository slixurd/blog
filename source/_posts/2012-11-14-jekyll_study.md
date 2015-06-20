title: "jeykll 记录"
date: 2012-11-14
---

##google analytics&&disqus
不知道原因为何，在自己建立的github pages中无法引用作者提供的analytics和disqus，那就自己修改一下吧。步骤很简单。
如下代码：

```
	<script type="text/javascript">
	  var _gaq = _gaq || [];
	  _gaq.push(['_setAccount', 'UA-XXXXX-Y']);
	  _gaq.push(['_trackPageview']);
	  (function() {
	    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-		analytics.com/ga.js';
	    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();
	</script>
```


最后，可以将自己的`_includes`的`analytics-providers`文件夹和`analytics`都删掉，因为没用了。注意，记得用git rm来删除，否则最后上传到git上还是有的，除非你先删除整个分支，不过就显得过于麻烦了。既然删除了JB提供的套件，其实`_config.yml`文件里面相应的部分也可以删除了。为了简洁和减少错误着想，都删了比较好，也不会以后看到突然不知道是什么。

disqus基本操作都和analytics一样，就不复述了，记得自己去`disqus.com`注册申请帐号然后得到自己的shortname。选择install instruction的时候点universal code，复制粘贴到post.html文件的comment段就可以了.

```
	<div id="disqus_thread"></div>
	<script type="text/javascript">
	/* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
	var disqus_shortname = 'slixurd'; // required: replace example with your forum shortname	/* * * DON'T EDIT BELOW THIS LINE * * */
	(function() {
	var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
	dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
	(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
	})();
	</script>
	<noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
	<a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
```    
------------------

#Jekyll bootstrap架构
+ __\_layout__文件夹里面有3个文件，default，page，post。分别对应3种页面的格式。很显然，就是自己建立的文章的layout，就像一般写blog要求在_posts文件夹下直接用rake生成一样。实质就是引用了post格式。打开3个文件都可以看到源代码。什么都没做，例如page只是引用了

    \{ % include JB/setup  %\}
    \{ % include themes/twitter/page.html  %\} <br/>
仅此而已。应该是为了方便切换theme所设计的。

+ __\_includes/themes/twitter/__就是主要的页面layout了。需要增加的可以自行添加html，记得留下content就可以配合markdown一起使用了。
+ __\_includes/JB__这个文件夹就是一些作者写的扩展功能，例如taglist里面如何提取相同tag形成list的。当然用的都是liquid语言。
+ __\_asset__是整个页面的布局，包括图片，包括css。如果想要修改颜色，背景图片，为webkit加上透明，阴影各种效果都是写在css里面。最后还有一个_site文件夹。这个文件夹是jekyll --server编译出来的，就是别人所能见到的网站，当然据说github编译的时候，都会加上`safe`参数，这个文件夹在github上看不到的。
+ __根目录__
>+ __CNAME__显而易见解析使用的，内容只有一句，自己的域名。当然在此之前需要先修改自己domain的A记录，改为github的地址，ping下可以得到。
>+ __\_config.yml__估计看过作者介绍的人也不会不知道这是什么了。如果不知道的话，不想看英文的话，有博客简单翻译了一部分，基本足够用。<http://www.mceiba.com/develop/jekyll-introduction.html> 
>+ __\*\*.html__ 这个就是你的顶栏会出现的页面，或者应该说你点进pages以后会看到的所有网页。默认的顶栏有5个。分别对应5个html文件（Archive，Tags，Categories，Pages，还有index），需要自己在顶栏增加页面参照模板来增加就可以了，例如about页面。需要的只是选择page这种layout，然后包含JB自带的设定，也就是`include JB/setup`这一句，剩下的部分就自己补全吧，想用md写也行，直接写html也行。最后出现在\_site的结果是一样的。

+ __markdown__会鸟语的直接看鸟语吧，不会的可以看翻译版本<http://wowubuntu.com/markdown/#autolink>,鸟语版本链接：<http://daringfireball.net/projects/markdown/syntax>

