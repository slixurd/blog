title: "MyBoxyBeta 设计模式分析"
date: 2012-11-27
---

#MyBoxyBeta之架构设计
----------------------------
##前言:
这个游戏已经写完很久很久很久了,当时还没有学会用git,版本管理是用最简单的打包src然后标明日期时间,现在看起来真是很幼稚的东西.当时是由两个大二的同学带着刚入大一下学期的我来开始的这个项目,实在是非常感谢.

在简单的设计模式入门以后,才发现他们当时设计的架构已经非常不错了,对于我这样面对对象的新手来说,我当时的任务就是一个码农,由带队的老大设计好整个架构然后分配任务给我,很羞愧的是,我先自己按照功能需求完成细节(具体需求可以看DOC文档),然后再添加接口来匹配上层建筑.拿Mirror_Area,Black_Hole,Exclude_Hole来做例子吧,全部都是派生自Area这一个类的,我写的时候确是将三个具体类先完成,然后看到需要匹配基类,就将写好的类当中的需要独立的功能独立出来放入公共的接口当中.

最后当我们完成整个程序的时候,基本框架的确是对了,但是我们疏忽了一点,性能!对于一个android的机器来说,并没有那么多的性能提供给我们,我们在初始化的时候,每一次的level select都会重新创建对象,最后虽然有释放,但是不管是android的还是java的GC都无法令人满意,我们在接近完成的时候是想修改的,无奈耦合的地方太多,难以修改.然后我们约定,在有限的将来当中,如果还有机会,要重构这个游戏.具体思路很简单,第一次进入游戏的时候就将所有需要用到的对象初始化,以后如果不需要用到,采用隐藏的方式而不是销毁,这样可以避免多次初始化造成的内存爆炸.

---------------------------------
##基本结构
首先,我们知道android的main入口其实就是Activity,本游戏一共有3个Activity,分别代表3个界面.前两个界面只涉及通过intent的activity的切换,十分简单,不作详解,同时,关于游戏引擎AndEngine也不作讨论,只讨论MyBoxyBetaActivity,即游戏界面.

![IMG](http://i.imgur.com/qEssM.jpg) ![IMG](http://i.imgur.com/fOVDu.jpg) ![IMG](http://i.imgur.com/TQHA5.jpg)

------------------------
###游戏操作类
![IMG](http://i.imgur.com/twfc5.jpg)
游戏操作类一共有4个,其中最主要的当然是MyBoxyBetaActivity,控制着其他控制类的的操作,我把它称为controler.下面有3个属于关联关系的操作类,分别是Boxy_GameFinish,Boxy_level,Boxy_refresh.作用一看便知,分别用来结束游戏,初始化关卡,刷新关卡.

![IMG](http://i.imgur.com/YlwIO.jpg)

而操作实体我称之为Object.基类Boxy_object拥有接口(interface) CommonFunction. Boxy_object派生3个主要的"实体类型",分别是区域,板,特殊元件.其中板和特殊元件又是互相关联的.这3个类具体派生的类见UML图.

![IMG](http://i.imgur.com/Ymfez.jpg)

为了减少操作类和具体实体类之间的耦合,所以以Boxy_object作为操作类可以直接使用的元素,所有需要生成具体实体都需要依赖Boxy_object这个基类,这样也能强制所有的具体实体都拥有相同的接口以方便初始化,销毁,启用以及休眠.

![IMG](http://i.imgur.com/howTO.jpg)

###Boxy_level类
Boxy_level类以一个数组private final static float[] level来储存所有的游戏关卡数据,每次需要初始化就根据当前关卡读取数组就可以了.读取关卡数据结束以后,就进入public void InitialObject()函数,进行具体实体的初始化,这里采用的是简单工厂模式,因为在组合并不多的情况下,没有必要使用抽象工厂或者其他的模式,

![Init object](http://i.imgur.com/sIWwM.jpg)

```
	public Boxy_Object[] object_array=new Boxy_Object[level_num]
	for(i=0;i<level_num;++i)
	{
		seeker=level_start_index;
		switch((int)level[seeker])
		{
		case 11:
			object_array[i]=(Boxy_Object)new Boxy_NormalBoard(..);
			break;
		case 12:
			object_array[i]=(Boxy_Object)new Boxy_WoodBoard(..);
			break;
		case 13:
			object_array[i]=(Boxy_Object)new Boxy_BlackHole(..);
			break;
		..
		}
	}
```

通过这样的工厂类,可以使得MyBoxyBetaActivity本身并不实际与各个具体实体相关联,当需要增加实体个数,种类的时候,只需要在level数据中增加就可以了,虽然并没有做成抽象工厂,但是我们的目的是可以轻松增加游戏关卡,而不是为了模式而作模式.尽管这里违背了开放-封闭原则,但是却依然易于维护,如果盲目增加工厂类,就会造成类数量过多反而不好维护的问题.

###Boxy_GameFinish类
Boxy_GameFinish类是负责当一个关卡结束的时候,销毁当前所有的实体的(其实这里希望做到的是隐藏,而不是销毁).当然,这个类本身并没有任何能够销毁实体的函数,他所做的仅仅指示发出消息罢了,通过这个消息,然后通知level类进行public void DestroyLevel()随后object基类调用public void destroy()这个函数而已,通过一个消息而监管所有的元素,这里采用的是观察者模式.

![destroy object](http://i.imgur.com/Xwq9l.jpg)

```
	public void DestroyLevel()
	{
	int lv_num=(int)level[level_start_index];
	for(int i=0;i<lv_num;++i)
	{
		if(object_array[i]!=null)
		{
			if(!object_array[i].isrubbish)
				object_array[i].destroy();
			else
				object_array[i]=null;
		}
		java.lang.System.gc();
	}
```

###Boxy_refresh
Boxy_refresh是在用户并没有通过这一关的时候刷新本关关卡重新开始游戏的,最主要就是其中的三句而已.

```
		parent.level.DestroyLevel();	
		parent.level=new Boxy_Level(parent.level_index,parent);
		parent.level.InitialObject();
```

