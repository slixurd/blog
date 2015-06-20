title: "impress.js使用小记"
date: 2012-12-15
---

#前言

在偶然的机会下,接触到prezi这样一种展示工具,但是因为庞大的开发套件&收费让我止步,幸运的是,找到了impress.js这样一种替代品,如此精简而又优秀的展示工具.impress.js需要搭配html+Css实现,尽管已经有两三个visual design tool,但是效果差强人意,唯一一个比较满意的就是markdown2impress.不过由于需要实现自己的网页风格,还是决定全部自己写.下面就介绍一个如何设计一个基于impress.js的网页/展示.

----------------------------------
>首先还是先放官方demo以及我制作的presentation.

>[demo-slixurd](http://slixurd2.tk/person/presentation/presentation.html#/start-page) 对内容感兴趣的一样可以进入[OpenSource](http://slixurd2.tk/2012/12/14/opensource/)查看以及下载

>[demo-official](http://bartaz.github.com/impress.js/#/bored)

---------------------------------------
然后..一个JS如何实现一个网页呢?妈妈告诉我们,程序员们最重要的能力就是看源代码,所以当你下意识的点开查看源代码的时候,你已经开始迈出第一步了.原本想翻译作者的源代码的(因为作者把基本步骤都写在源代码里面了),不过看到已经有人翻译了,那二次劳动就免了,[点击这里阅读eyehere的翻译](http://eyehere.net/2012/impress-js-chinese-course-tutorial/) .鉴于网上的教程都是从一份英文教程翻译而来并且翻译的不知道如何评价.不过由于大体正确,我也没必要继续重复写,我就从另外的角度来讲好了.

就如同作者所说的一样
>>So if you want to build great presentation take a pencil and piece of paper. And turn off the computer.
Sketch, draw and write. Brainstorm your ideas on a paper. Try to build a mind-map of what you'd liketo present. It will get you closer and closer to the layout you'll build later with impress.js.


##布局
![impress](http://i.imgur.com/h3frn.jpg)

这是官方demo的布局.首先我们需要知道座标定位所需要的变量,impress.js一共提供了4个主要定位的参数(3d变换不算).

> `data-x="3500" //只要学过数学的都应该知道.这是直角座标系(装B的说法是-笛卡儿座标系)`

> `data-y="2100" //但是方向不一样,y是以下为正方向的`

> `data-rotate="180" //这个是旋转角度`

> `data-scale="6"//这个是放大倍数`

定位点均为该子页面未缩放及旋转前的左上角,所以我们可以在图上看到座标系的原点.(不是(0,0)标示的位置,而是黑色x轴那里.)我们需要为每一个页面做定位.所以设计在这里就显得很重要了.
倍数可以带小数,例如0.001,旋转角度可以是负数,也可以超过360(表示多次旋转),善用缩放和旋转是让presentation出彩的重要一环.所以,离开电脑,好好画一下布局,好好设计才是正道,像我这种做完以后都不敢放overview的千万不要学.

##基本结构
我们直接看全局结构吧,以下是最小结构

```
	<!DOCTYPE html>
	<head>
	  <link href="css/impress-demo.css" rel="stylesheet" />
	</head>
	
	<body>
	  <div id="impress">
	  <!--content start tag -->
	      <div id="first" class="step" data-x="0" data-y="0" data-rotate="180" data-scale="3">
 	        <p>the first try</p>
	      </div>
	  <!--end tag -->
	  </div>
	<script src="js/impress.js"></script>
	<script>impress().init();</script>
	</body>
	</html>
```

作为一个网页必须的元素当然都是必须有的,例如最外层的`<html>`标签,然后其中的`<head>`和`<body>`两个标签.谈谈impress.js需要的东西.

第一个:`<script src="js/impress.js"></script>//链接js脚本`

第二个:`<script>impress().init();</script>//这个也可以用他自带的其他api,不过一般init就足够了`

选择可有:`<link href="css/impress-demo.css" rel="stylesheet" />`

script最好就是直接放在body结束标签前,否则有机率无法载入.css样式表根据自己需要修改,删除,增加.
其实实际上,如果想偷懒的话,直接在我所标示的content tag中间加内容就可以了.

鉴于impress.js只支持chrome,safari,ff.所以做不支持的提示是很重要的,因此可以这么写`<body class="impress-not-supported">` 在能够支持的情况下,js会自动替换掉这个class(不信的话用chrome打开网页查看源代码,查看和直接阅读html的区别),无须担心.

最重要的就是#impress这个id,只有查找到这个标签的时候,才会执行impress.js.所以在body标签之后就是一个`<div id="impress"></div>`的标签,所有的内容都在里面.

然后就进入了子页面,每一个页面都是div,必须有的元素是:.step,x,y.例如上述例子
`<div id="first" class="step" data-x="0" data-y="0" data-rotate="180" data-scale="3">`
id是这个子页面的名称,最后仅仅只在地址栏有显示,是页面的唯一标识,所以不能够相同.然后是class="step"同时我们也可以用class="step slide"这种滑动页面,不过step是必须的,slide是可选的,同时如果自己有编写css,一样可以用自己的class.随后必需的是data-x,data-y.如果没有scale,默认为1,没有角度,默认为0;

另外,作者提供了data-z这个参数,也就是所谓的3d-transform,标示在z轴的位置.效果如同一开始的概览图的12号.另外还有data-rotate-x data-rotate-y  data-rotate-z 这些参数,唯一不同的是,这些的参数的单位是度数.而x,y,z使用的是px.此外还有一些参数感觉没有什么用的就没有解释了,都可以在源代码的注释里找到.

推荐源代码注释和本文都一起读,否则会觉得不知所以.关于css的部分我就不讲解了.我自己的presentation中最主要用的两个类是blurBG和pic.只是简单的圆角+背景+透明度+阴影的组合而已.可以自己尝试搭配,实在不会的话可以搭配各种代码审查(主流浏览器下按F12)查看css并做修改.
