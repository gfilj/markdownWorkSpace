##classloader
1. 什么是classloader
	1. 编写完程序之后我们形成的是文件，如何将文件加载到内存中执行，这个时候就用到了classloader
	2. classloader是一个负责加载classes的对象，classloader类是一个抽象类，通过给出的一个类的二进制名称，classloader尝试定位和产生可以定义一个class的数据，在这其中最典型的一种策略就是把二进制的名字转换为文件名然后从文件系统中找到该文件
1. 线程安全
	1. 为什么是线程安全的？
	2. loadclass的实现就是线程安全的
		1. 先判断是否被加载过
		2. 从父类中加载
		3. 从自身的classloader中加载

3. loadClass（） 方法
	1. synchronized (getClassLoadingLock(name))--》getClassLoadingLock(name)--》parallelLockMap
		1. putIfAbsent好方法
		2. 为类的加载操作返回一个锁对象。为了向后兼容，这个方法这样实现:如果当前的classloader对象注册了并行能力，方法返回一个与指定的名字className相关联的特定对象，否则，直接返回当前的ClassLoader对象。
3. jvm的classLoader的加载机制
4. 两个classloader是加载同一个class可能一样也可能不一样，有可能是同一个classloader加载的，也有可能不是同一个classloader加载的
5. 关于classloader的加载问题，有一个最关键的地方就是有这样的需求，加载的时候需要家默认的加载顺序进行修改，首先加载子类的数据，只有在找不到的情况下，再去加载子类的东西，这和java默认的classloader加载正好是相反的，默认的classloader的加载顺序是从父类到子类的加载顺序过程，这个可以从源码看出，在源码上
6. 关于双亲委派模式的问题上面，如何实现的，看代码
7. 关于tomcat的classloader记载模式看代码
8. 关于如何实现要求中所需的classload加载顺序
	1. 在观看源码当中，发现可以将其加载顺序该过来，但是经过测试之后发现这样是不行的，因为这样的话联最基本的java类库都没有加载进来
	2. 既然无法修改classloader的加载顺序，那么可以这样进行修改在findclass上进行修改，如果找不到的话，去指定的classloader上去加载
	3. 这样确实可以解决很多问题，但是新一轮的问题出现了，在加载共有类的时候classloader加载相同的东西还是会加载两遍，这是一个很浪费的行为，或者是没有必要的，从另一个角度来讲，这样的话我们无法通过静态的方法获取classloader对象（原有父类的getParent方法被声明为final模式，这样的模式是无法进行重写，即便进行了重写，别其他父类的方法调用时，也会出现很多意想不到的问题）
	4. 那么如何进行解决呢，有两个需求，加载需要默认优先从子类加载，第二个需求就是从Thread.currentThread().getContextClassLoader().getParent()中获取到指定的共有的父classloader，那么现在的关键性问题来了，这两个需求是水火不相融的针对于同一classloader来说，
	5. 那就用两个classloader进行处理，如下图所示
	6. 