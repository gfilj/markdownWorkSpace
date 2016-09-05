##classloader
1. 线程安全
2. loadclass的实现就是线程安全的
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