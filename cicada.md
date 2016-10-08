###cicada
1. 无服务器
2. 类似于hadoop管理 有个manager的结点 下面有多个exector结点 
3. 心跳监控
4. 调度中心



###spring 无法用appclassloader进行初始化
1.如果采用appclassloader进行初始化会导致在启动时的时候导入spring是通过appclassloader进行导入的，但是在导入子项目中的classloader是通过子项目中的appclassloader进行导入的，两者无法相等