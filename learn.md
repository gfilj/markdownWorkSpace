##  定时器写法
* 1.start 先执行一次任务，然后定时任务
* 2.定时任务继承自timerTask，实现方法即可
 
## log4j查找错误  
再打印错误日志的地方把必要的日志进行传入
	
## 信号量使用
* 只限于linux平台
*只限于USR2信号量
* 使用kill -s SIGUSR2 pid
 
 >
* public static class ShutdownSignal implements SignalHandler {  
	@Override  
	* public void handle(Signal sign) {  
		* SERVER_LOOP = false;  
		* LOG.info("server recv signal : " + sign.getName());  
	* }   
* }  
* Signal sign = new Signal("USR2");  
* Signal.handle(sign, new ShutdownSignal()); 
 

## 线程池的停止  
 
* if(executorService != null) {  
	* executorService.shutdown();  
	* try {  
		* executorService.awaitTermination(10, TimeUnit.SECONDS);  
	* } catch (InterruptedException e) {   
		* LOG.error("wait executor service exception : " + e.toString());  
	* }  
* }  
awaitTermination 等待线程池中的线程执行完毕，如果在指定时间内没有执行完毕，那么返回false
否则返回ture

shutdown 启动一次顺序关闭，执行以前提交的任务，但不接受新任务。如果已经关闭，则调用没有其他作用。		

## 线程join的方法
 join() 方法主要是让调用该方法的thread完成run方法里面的东西后， 在执行join()方法后面的代码

## 文件的创建
1. 先判断目录文件是否存在，如果不存在创建目录文件
2.	创建所需要的文件
3. 针对这个结构可以创建一个稳定的目录标量，创建什么文件直接传入即可

## redis删除的应用
1. 获取redis成功删除后的用量，假如不为0的话，那么说明删除成功，如果删除成功的话可以结合下一步的操作
2. 如果不为0为1或者2的话，那么是不是要考虑一下这种情况呢，如果这种情况发生那么可是和平台丢量有大大的关系了

##assert java关键字
主要在开发和测试时开启  
1. assert exp1 此时的exp1为一个boolean类型的表达式
2. assert exp1 : exp2 此时的exp1同上，而exp2可以为基本类型或一个Object
**point：**在测试方法中assert报错后，其后的代码不执行

##遍历map
1. keySet
2. values
3. entrySet  

针对取出的值可采用for循环进行便利  

* obj：Collection
* iterator

##修改map中的对象
在map中object的值修改之后，在map中存放的值已经改变，其实可以这么理解，map只是容器，存放对象的地址，我们把对改掉后，从map中查出来的值也就改变了

##排序


##system.exit
Zero => Everything Okay

Positive => Something I expected could potentially go wrong went wrong (bad command-line, can't find file, could not connect to server)

Negative => Something I didn't expect at all went wrong (system error - unanticipated exception - externally forced termination e.g. kill -9)

##死循环
for(;;){
}

##文件当中classpath的声明

##[CountDownLatch](http://www.iteye.com/topic/1002652)
一个同步辅助类，在完成一组正在其他线程中执行的操作之前，它允许一个或多个线程一直等待。
主要方法
 public CountDownLatch(int count);
 public void countDown();
 public void await() throws InterruptedException
 
构造方法参数指定了计数的次数
countDown方法，当前线程调用此方法，则计数减一
awaint方法，调用此方法会一直阻塞当前线程，直到计时器的值为0

##<T> T[] toArray(T[] a);
返回包含此 collection 中所有元素的数组；返回数组的运行时类型与指定数组的运行时类型相同。

##分词系统
[api地址](http://doc.gotomao.com/apidoc!ikanalyzer.html)

##Thread.getStackTrace
返回一个表示该线程堆栈转储的堆栈跟踪元素数组。如果该线程尚未启动或已经终止，则该方法将返回一个零长度数组。如果返回的数组不是零长度的，则其第一个元素代表堆栈顶，它是该序列中最新的方法调用。最后一个元素代表堆栈底，是该序列中最旧的方法调用。

##Thread.getStat
thread.getState().name().equals("WAITING")
##获取栈顶元素
stackTrace[stackTrace.length-1]
##StackTraceElement.getLineNumber
返回源行的行号，该行包含由该堆栈该跟踪元素所表示的执行点。  
通常，该方法派生自相关 class 文件的 LineNumberTable 属性（根据 The Java Virtual Machine Specification 中的第 4.7.8 小节）。
##Collections.synchronizedList
1. Collections.synchronizedSet
返回指定 collection 支持的同步（线程安全的）collection。为了保证按顺序访问，必须通过返回的 collection 完成 所有对底层实现 collection 的访问。
2. 在返回的 collection 上进行迭代时，用户必须手工在返回的 collection 上进行同步：
3. think：
	1. 为什么不是同一个锁就不是线程安全的
	>1. 一个等待的对象锁，一个等待的链表锁，要说不安全那就是这样的情况了，一个进程等待进入对象锁之后又创建了好几个线程进行并发修改对象中的列表，那么即便你加了对象锁，列表也是无论如何不安全的，
	>2. 两个等待的根本不是同一个锁
4. 通过对[源码的分析](http://my.oschina.net/infiniteSpace/blog/305425)得知Collections.synchronizedList针对传入的list中的基本操作进行了synchronized控制，加锁的对象是list本身，
这样针对list基本的写法就不需要加synchronized特殊关键字了
5. 在基本操作中，针对list.iterator()或者list.iterator(int index)方法没有提供加锁控制的方式，所有在遍历的时候针对列表加锁控制
6. 如果封装一个原子性操作，需要对list本身进行加锁
<pre><code>public boolean putIfAbsent(E x) {  
	synchronized (list) {  
	    boolean absent = !list.contains(x);  
	    if (absent)  
	        list.add(x);  
	    return absent;  
	}  
}   
</code></pre>

##[java泛型](http://m.blog.csdn.net/article/details?id=1748731)
1. 灵活性：不用考虑对象的具体类型，就可以对对象进行一定的操作，对任何对象进行相同的操作
2. 局限性：由于没有考虑对象的具体类型，因此在一般情况下不能使用对象自带的接口函数
3. 最佳用途：1.不用考虑实现容器类（该容器可以存储对象，也可以取出对象，而不用考虑对象的具体类型，用泛型类实现容器）
4. 实现原理：
	1. 泛型是在编译器而不是虚拟机中实现的，
	>编译器一定要把范型类修改为普通类，才能够在虚拟机中执行。在java中，这种技术称之为“擦除”，也就是用Object类型替换范型 **原生类**
5. 范型类可以继承自某一个父类，或者实现某个接口，或者同时继承父类并且实现接口，这样的话，就可以对类型调用父类或接口中定义的方法了
<pre><code>public class Pair<T extends Comparable>{   
	public boolean setSecond(T newValue) {   
		boolean flag = false;  
		If(newValue.compareTo(first)>0) {  
			 second = newValue;  
			 flag = true;  
		}  
		return flag;  
	}   
	private T first;   
	private T second;   
}</code></pre>
6. 为了简化范型的设计，无论是继承类还是实现接口，一律使用extends关键字。
7. 若同时添加多个约束，各个约束之间用“&”分隔
8. 定义一个函数，该函数接受一个范型类作为参数
	> 1. 对于这种形参，实参的类型必须和他完全一致，即也应该是一个元素为Number的list才可以，其他的实参一律不行
	> 2. Integer确实是Number的子类，但是，ArrayList<Integer>并不是ArrayList<Number>的子类，二者之间没有任何的继承关系
	> 3. 在函数内部，我们把Float类型的元素插入到链表中。因为链表是Number类型，这条语句没问题。但是，如果实参是一个Integer类型的链表，他能存储Float类型的数据吗？？显然不能，这样就会造成运行时错误。于是，编译器干脆就不允许进行这样的传递。
9. 定义一个范型方法要比Wildcard稍微灵活一些，可以往链表中添加T类型的对象，而Wildcard中是不允许往链表中添加任何类型的对象的。
10. Wildcard支持另外一个关键字super，而范型方法不支持super关键字。换句话说，如果你要实现这样的功能：“**传入的参数应该是指定类的父类**”，范型方法就无能为力了，只能依靠Wildcard来实现
	1. 泛型函数，帮助函数
	<pre><code>//把取出的元素再插入到链表中
	//帮助函数  
    public static <T>void helperTest5(ArrayList<T> l, int index) {  
        T temp = l.get(index);  
        l.add(temp);  
    }
    //主功能函数
    public static void test5(ArrayList<? super Integer> l) {  
        Integer n = new Integer(45);  
        l.add(n);    
        helperTest5(l, 0);   //通过帮助类，将指定的元素取出后再插回去。  
    }</code></pre>

## Java中的ReentrantLock和synchronized两种锁定机制的对比

##正则解析json
<pre><code>public static void main(String[] args) throws Exception {
    String str = "{\"username\":\"zs\",\"password\":\"123123\",\"phone\":\"13612345678\"}";
    Matcher m =Pattern.compile("\"(.*?)\":\"(.*?)\"").matcher(str);
    while(m.find()){
        System.out.println(m.group(1)+"="+m.group(2));
    }
}</pre></code>

##Volatile
[Java 理论与实践: 正确使用 Volatile 变量](http://www.ibm.com/developerworks/cn/java/j-jtp06197.html)  
####心得：
1. Volatile变量只能提供可见性，可见性是相对于读操作，线程能自动发现volatile变量的最新值
2. Volatile变量的当前值和修改后的值之间没有任何约束，也就是我们不需要关心当前值，直接在其上面修改即可
3. volatile变量可以用于简易型和伸缩性的优化
4. 正确使用Volatile的条件
	1. 对变量的写操作不依赖于当前值
		1. 为什么这么说呢？
		2. 因为如果依赖于当前值那么，就需要先读取当期的值，再修改和设置会内存，这样操作就不是原子性的了
		3. Volatile保证那部分操作是原子性的?
		4. 那么需要了解一下[volatile的实现原理](http://www.infoq.com/cn/articles/ftf-java-volatile)
		5. 在volatile变量在执行时转变为汇编代码时实在前面增加了lock前缀
			* 将当前处理器缓存行的数据会写回到系统内存。
			* 这个写回内存的操作会引起在其他CPU里缓存了该内存地址的数据无效。
		6. 那么就明白了volatile具体操作的是那部分了，他只能保证当前数据能及时被其他线程看见，就是能保证修改数据后读操作的正确性，但是基于读操作出来的数据在修改的时候就会出现问题
		7. 缓存一致性机制会阻止同时修改被两个以上处理器缓存的内存区域数据
	2. 该变量没有包含在具有其他变量的不变式中。
3. 这就说明可以写入volatile变量的有效值独立于任何程序的状态
3. volatile 的限制 —— 只有在状态真正独立于程序内其他内容时才能使用 volatile 
4. Volatile的正确使用
	1. 状态标志
	2. 一次性安全发布（one-time safe publication）
	3. 独立观察（independent observation）
	4. “volatile bean” 模式
	5. 开销较低的读－写锁策略
		synchronized 确保增量操作是原子的，并使用 volatile 保证当前结果的可见性
	6. LinkedTransferQueue
		* 在使用Volatile变量时，用一种追加字节的方式来优化队列出队和入队的性能
		* 为什么追加字节就能提高性能呢
		* 因为如果队列的头节点和尾节点都不足64字节的话，处理器会将它们都读到同一个高速缓存行中，在多处理器下每个处理器都会缓存同样的头尾节点，当一个处理器试图修改头接点时会将整个缓存行锁定，那么在缓存一致性机制的作用下，会导致其他处理器不能访问自己高速缓存中的尾节点，而队列的入队和出队操作是需要不停修改头接点和尾节点，所以在多处理器的情况下将会严重影响到队列的入队和出队效率。Doug lea使用追加到64字节的方式来填满高速缓冲区的缓存行，避免头接点和尾节点加载到同一个缓存行，使得头尾节点在修改时不会互相锁定
##[可伸缩性原则](http://www.infoq.com/cn/articles/scalability-principles)
从最简单的水平来看，可伸缩性就是做更多的事情。更多的事情可以是响应更多的用户请求，执行更多的工作，或处理更多的数据。设计软件这件事本身是复杂的，而让软件做更多的工作也有其特有的问题。这篇文章针对构建可伸缩软件系统提出了一些原则和方针。
##锁的两种特性
1. 互斥性（mutual exclusion）
	* 互斥即一次只允许一个线程持有某个特定的锁，因此可使用该特性实现对共享数据的协调访问协议，这样，一次就只有一个线程能够使用该共享数据。
2. 可见性（visibility）
	* 可见性要更加复杂一些，它必须确保释放锁之前对共享数据做出的更改对于随后获得该锁的另一个线程是可见的 —— 如果没有同步机制提供的这种可见性保证，线程看到的共享变量可能是修改前的值或不一致的值，这将引发许多严重问题
##Java 7中的TransferQueue
1. [first](http://ifeve.com/java-transfer-queue/)
2. [second](http://blog.csdn.net/yjian2008/article/details/16951811)
## [Java happens-before](http://ifeve.com/easy-happens-before/)
1. happens-before规则不是描述实际操作的先后顺序，是用来描述可见性的一种规则
	* 为什么是这个样子
	* 看官方说法的通俗解释：
		* 如果线程1解锁了moniter a，接着线程2锁定了a，那么线程1解锁a之前的写操作对线程2均可见（线程1 和线程2 可以是同一个线程） 
			* 针对这条规则引发了我无数的联想，哇塞，在程学中也会存在线程1解锁a之前的写操作对于线程2不可见的话，那是什么情况，线程不安全了吧，哇塞，那运用到生活中该如何
		* 如果线程1写入了Volatile变量v（这里和后续的“变量”都指的是对象的字段、类字段和数组元素），接着线程2读取了v，那么，线程1写入v及之前的写操作都对线程2可见（线程1和线程2可以是同一个线程）
		* 线程t1写入的所有变量（所有action都与那个join有hb关系，当然也包括线程t1终止前的最后一个action了，最后一个action及之前的所有写入操作，所以是所有变量），在任意其它线程t2调用t1.join()成功返回后，都对t2可见。
		* 线程中上一个动作及之前的所有写操作在该线程执行下一个动作时对该线程可见（也就是说，同一个线程中前面的所有写操作对后面的操作可见）
		* 传递性
2. 衍生出的其他happens-before原则：
	1. 如ReentrantLock的unlock与lock操作，又如AbstractQueuedSynchronizer的release与acquire，setState与getState等等。
2. 看个CopyOnWriteArrayList的例子
	1. 这个例子中的可见性就是利用上述开销较低的读-写锁的策略进行的，不过在设置过程当中采用了一种新的手段保证线程安全性，那就是在通过加锁的过程当中采用set Volatile的方式通知其他线程重启读取共享的值，那么get方法就不需要同不了，提高了伸缩性
##[AbstractQueuedSynchronizer](https://bigbully.github.io/AbstractQueuedSynchronizer)  

##CAS
CAS:Compare and Swap, 翻译成比较并交换。 
##url uri difference
[url is a type of uri](http://webmasters.stackexchange.com/questions/19101/what-is-the-difference-between-a-uri-and-a-url)  
uri contains url and urn and so on 
###HTTP如何发送purge请求并且使用proxy模式

###正则表达式的使用
匹配是否正确：
String macReg = "^([0-9a-fA-F]{2})(([/\\s:-][0-9a-fA-F]{2}){5})$";
if(str.matches(macReg)){
	returnValue = true;
}

匹配寻找字段：Pattern pattern = Pattern.compile("^([0-9a-fA-F]{2})(([/\\s:-][0-9a-fA-F]{2}){5})$");
Matcher matcher=urlUserAgentInfoIdPattern.matcher(url);
if(matcher.find()){
	return matcher.group(1);
}

###总结http的调用
http的调用
###spring4 当中不使用web.xml如何进行操作

###common lang3 中 EqualsBuilder和 HashCodeBuilderde 的用法，如何使用
查看源码之后发线就是提供默认的实现

###tmux是什么东西
一个非常强大的东西，

###总结varnish和proxycache清理有何异同
1. 之前说到的一个原因好像是因为现在的方式清楚的时候呢不知道缓存在那台机器上清楚不干净，这样会导致一些问题
2. varnish可以正则匹配清除
3. varnish自动可以进行缓存图像之类的东西，采用的是hash存储
4. 需要网上查询进行补充
5. varnish进行配置时的问题

###数组拷贝的方法
System.arraycopy(src, srcPos, dest, destPos, length)

##分布式锁实现方案
1.acl-->access control
####zookeeper 实现方式


##数组默认的排序算法是如何实现的

##泛型类用于抹除累的差异性
这个在编译的时候回进行自动编译和实现
这也就是反射机制的强大之处