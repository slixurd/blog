title: "SpringSeed-极简笔记软件"
date: 2013-08-06
---

SpringSeed
=================

## 前言

已经几个月没有上过OMG! Ubuntu了,今天突然兴起翻了一下,就看到这个优秀的笔记软件.正如作者所说的一样,这个笔记软件简洁,美观,没有一丝累赘的功能,由node-webkit驱动,整个软件本身(不包括nw)才3M.虽然目前只有Ubuntu版本,不过大概在windows下也可以使用,毕竟nw就是为此而生的.此前我也不知道原来有node-webkit这样的东西,查了以后才发现nw实在太优秀了.前端从此可以开发本地软件了,而且相比常规开发而言,更容易做出优秀的界面和交互,这些都是native app难以做到的.(当然,也有缺点,例如下载打包好的deb,几乎都是30M以上,因为需要放一个40M的nw执行文件,下载一个无所谓,但是下载多了以后未免觉得烦)

## 软件介绍

![springseed](http://i.imgur.com/WWJ2oNz.jpg)

其实真不用介绍,这个软件的功能很简单很简单,只要会markdown,这个软件几乎是立刻就能学会的.当然这里的markdown和标准的markdown也不太相同,在目录coffeescript/app.coffee里稍微翻一下就可以发现这个markdown标准是作者自己实现的(虽然说写的和通用的markdown也差不多),而非标准的markdown,所以有的特性无法支持,也有不同的语法,例如 `~~~` , `~~`.基本功能都有.代码高亮也需要另外添加.

另外有一个bug,有时直接输入网站地址以后点击不会在浏览器打开页面,而是直接在软件本身就打开了这个网页,此时无法后退回软件界面.只能关掉重开,幸好软件本身是隔一段时间就保存的,不会丢失太多数据.当然这个问题不是软件写的有问题,应该是nw自身的问题,之前使用koala(一个SASS,LESS的预处理器)也有同样的问题.

还有一个比较严重的BUG,如果在登录了dropbox被自动同步以后,退出dropbox,然后继续编辑以写的笔记,隔一段时间再登录dropbox,笔记会被还原到上次被同步的状态.切记切记= =......

![dropbox](http://i.imgur.com/qn18tSy.png)

用markdown的好处就是,做完笔记以后可以直接copy到github pages上,只要稍微注意语法即可.其实,之前还遇到一个非常优秀的软件[marboo](http://marboo.biz)的,可惜作者不愿意开源,只有mac版,而且UI做的非常的抱歉.另外大概会有人质疑,为什么不用神器evernote,为什么不用国产的wiz.之前都试用过,感觉非常的不好.以前我在windows下的时候常用的软件是MyBase,一款很多年都不更新但是我依然无法抛弃的软件.然后直到去年10月我转投linux以后就开始用cherryTree了.我本身并不太需要多设备多平台同步,因为我写的要么是学习记录,要么是零零碎碎的想法,前者需要的时候我会直接发到github pages上然后通过pocket来让我各个终端可以查看,后者更需要在电脑面前慢慢补完,很多东西是不在电脑前做不了的..其他原因就不详述了.

用markdown的另外一个好处就是,作为前端,在只需要基础的表达的时候完全可以只用markdown的语法来写,但是无法满足需求的时候我可以通过直接编写html和内联样式来达到我想要的效果.由于写了一段时间的css了,现在感觉写代码比所见即所得的编辑器更加有效率和稳定,虽然这样违背了markdown的初衷.


