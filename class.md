class<?> : 表示可以接受任何类型的class 使用通配符
###反射带构造参数的方法


###classloader加载出现的问题


###反射中获取字段和反射的方法中携带参数
由此可见，
getDeclaredMethod\*()获取的是类自身声明的所有方法，包含public、protected和private方法。  
getMethod\*()获取的是类的所有共有方法，这就包括自身的所有public方法，和从基类继承的、从接口实现的所有public方法。


###在类路径上获取所有相关的jar包路径其实是通过
classLoader.getResources(fileName)来进行获取的

两个元素equals返回true，hashcode不一定相等，同时都重写才相等。 
     hashcode相等的两个元素equals一定为true，即充分不必要。 

###序列化和构造函数的关系

