title: "MFC之设计模式分析"
date: 2012-11-25
---
#MFC之设计模式分析

![all](http://i.imgur.com/xPk2f.jpg)

##程序的起点 命运之始
既然是C++程序,必然是由main函数(MFC中是WinMain)开始的.MFC作为一个成熟的软件框架,自然有着老练的一套-一个程序的实例需要有唯一的初始化(这里并不表示一个程序只能打开一次(即一个实例),仅能有一个实例这是通过自己重载initApplication实现的,但是这并不是其初衷).因此在程序尚未初始化的时候,就利用全局函数AfxGetApp取得该程序theApp的对象指针,然后用该指针指导后续界面,功能的加载.

显然,**这里用的是Singleton模式**.不直接对类进行初始化转而利用函数获得该类的指针以保证仅有一个实例.
>`pApp->InitApplication() `

>`pApp->InitInstance()`

![Imgur](http://i.imgur.com/UPxku.jpg)

当然这里的Singleton和我们一般学习的不太相同,但是这也体现了设计模式并不是照搬的这一重要特点.设计模式并不是传统的模式,更应该说是一种设计思想,其实现方式可以各种各样.一般的Singleton采用将构造函数设置为protected,这样就可以避免client类错误初始化(Java Script就没有,所以需要用其他方法),然后设计一个静态static的指针返回该类指针.MFC中使用的更类似JS的方法:` ASSERT(AfxGetThread() == NULL);`.即,如果`AfxGetThread() == NULL`,那么初始化,否则失败.
借由Singleton模式,对程序进行初始化.基本顺序是
```
	1. pApp->InitInstance()
	2. CmyWinApp::InitInstance() 
	   {
		m_pMainWnd=new CMyFrameWnd;
	   }
	3. CMyFrameWnd::Create(){CreateEx();}
	4. CWnd::CreateEx(){PreCreateWindow();}
```

由于有RTTI的原因,所以有很多地方就不需要用到常用的设计模式了,因为已经能够自己识别自己的类型,就不需要另外的抽象和实现的分离.简单说一下,RTTI分为两种,均用C风格的MACRO来编写,动态识别分别为`DECLARE_DYNAMIC`和 `IMPLEMENT_DYNAMIC`,动态创建为`DECLARE_DYNCREATE`和`IMPLEMENT_DYNCREATE`.这里主要讨论设计模式,所以对RTTI不作细究.当然RTTI贯穿整个MFC,是非常重要的元素.

另外,并不仅仅只有pApp才用了Singleton模式,其他的例如CDC也有使用.

```
	void CScribbleView::OnDraw(CDC* pDC)
	{
		CScribbleDoc* pDoc = GetDocument();
		ASSERT_VALID(pDoc)//(此处和ASSERT功能类似,都是通过宏来判定指针是否NULL,需不需要初始化)
		//......
	}
```

-------------------
##Document-View 牵一发发动全身
Document为模式中的subject,负责管理数据,view则是observer,用于显示document中的数据,使用者通过view看到document,也可以通过view改变document,view是document对外显示的接口.但是,view并不是独立的,而是保存在document frame的窗口内的.当document变化的时候,就会调用updateAllView进行对所有观察者的更新.因为在单个view下可以有多个数据的存在,所以此时需要一种一对多的依赖关系,并且在document的状态改变的时候,所有依赖它的对象都会得到消息并且更新.这也是observer模式的初衷.
![observer2](http://i.imgur.com/pZ37k.jpg)

后面根据具体代码分析.CFrameWnd(派生于CObject的类都可以接受消息,消息网路这里不讨论了)接受到系统发出的WM_CREATE消息,然后引发`CFrameWnd::OnCreate()->CFrameWnd::OnCreateHelper()->CFrameWnd::OnCreateClient()->CFrameWnd::CreateView()`;

```
	void CFrameWnd::CreateView(CCreateContext* pContext,..)
	{
		CWnd* pView=(CWnd* ) pContext->m_pNewViewClass->CreateObject();
		pView->Create(....)
		//......
	}
```
![observer](http://i.imgur.com/8ZV9A.jpg)

建立了多个View以后,CDocument有m_ViewList维护一系列的View.CFrameWnd仅有CView* m_pViewActive.指示现在正在活动的View.如果CDocument发生改变,就会调用UpdateAllViews()函数,使整个m_ViewList里面的View都update.这就是observer模式了.

----------------
##文件serialization 永久机制
MFC之所以为应用程序框架,一个重要的特征就是能够将管理数据和负责数据显示的代码分离开来.看到这个特征,很自然的想起Bridge这样一种模式.正如无数设计模式的书上说的一样,设计模式是一种思想,它不立足于实现,一个很简单的例子:你一看到刚才那个特征,你就应该反应到这是桥接模式,但是你可以不知道桥接模式是怎么实现的,你只需要先知道概念,通过需求推导出模式,后面才是实现细节.这才是设计模式的根本.
![bridge](http://i.imgur.com/4ScY9.jpg)

CArchive和CFile的client类是CDocument.例如`CDocument::OnSaveDocument()`函数里面,

```
	void CDocument::OnSaveDocument(..)
	{
		CFile* pFile=GetFile(...)
		CArchive saveArchive(pFile,CArchive::Store);
		Serialize(saveArchive);
		//......
	}
```
CArchive(实际上是文件缓冲区)和CFile之间的串行化设计采用了桥接模式.CArchive实现client需要的一系列接口(包括输入输出流的重载(>>&<<)),数据则由CFile来操作,不考虑文件究竟以何种形式储存,数据的形式以及处理都是由CFile处理,实现了抽象于具体的分离.使得两个类CArchive和CFile可以在互不影响的情况下进行修改.所有需要写入文件读取文件的操作都在CArchive里面 ,它获得CFile作为参数,从而获取文件名,请求类型以及其他必要信息.
