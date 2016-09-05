###centos7连接外网
* 可以在刚开始设置开启网络连接
* 设置完之后，安装就可以连接网络了
* 以下是是关于安装完之后的截图
 
![](D:\workspace\github\com.gdoifaonrriut.analysis.iosbendi\dataanalyse\cenos7net.png)
![](D:\workspace\github\com.gdoifaonrriut.analysis.iosbendi\dataanalyse\cenos7net1.png)

###yum更新安装源
1. yum clean all
2. rpm --rebuilddb
3. yum update
###install wget
 yum -y install wget
###centos7 ifconfig:commont not find
1. yum install net-tools
###安装jdk

1. 卸载

	---
	1.	rpm -qa | grep java/openjdk
	2.	rpm -qa | grep gcj
	3.	将查出来的包都卸载掉
		* yum -y remove + name
			
	---
2. 下载以及解压
	> tar -zxvf + name
3. 配置环境变量
 	
	---
	vim /etc/profile
	"#jdk配置
	JAVA_HOME=/usr/local/jdk7
	JRE_HOME=/usr/local/jdk7/jre
	PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
	CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
	export JAVA_HOME JRE_HOME PATH CLASSPATH

	---

4. 设置环境变量迅速生效
	> source /etc/profile
	> . /etc/profile

###sodu 权限 
* mv移动并且重新命名文件

###修改主机名字
* 修改修改完成之后重启启动计算机
> vim /etc/sysconfig/network
* 或者直接采用hostname xxx是文件名字临时生效

###查看系统位数
>getconf LONG_BIT

###linux防火墙

---
1. 查看以及修改
	>vim /etc/sysconfig/iptables
2. 开启和关闭
	>service iptables stop --停止  
	>service iptables start --启动
3. 查看当前状态
	>sudo /etc/init.d/iptables status

yum install iptables-services
systemctl stop/start/restart/status iptables.service
systemctl stop firewalld.service
---
###linuxdns
* /etc/resolv.conf
* nslookup
###curl测试网址
* curl url-->用于测试防火墙的配置
* [curl更多用法](http://www.linuxdiyf.com/linux/2800.html)
###查看内网地址
> ifconfig可显示对应的网卡ip地址，刚好可以看到内网的ip地址
###修改path
针对系统的path变量，不需要每次都去找这个路径，这样会很方便
  
---
1. 查看当前的系统路径
	> echo $PATH
2. 设置当前的系统路径[详细介绍](http://www.360doc.com/content/10/0818/15/935385_46953760.shtml)
	* PATH="$PATH:/my_new_path"
	* 修改/etc/profile
	* ~/.bashrc
	
---
###sudo出现和系统一样的命令
1. vim ~/.bash_profile 
2. sudo vim /etc/profile
3. 按照[第二种做法](http://www.cnblogs.com/A-Song/archive/2013/03/09/2951951.html) 
4. source ~/.bash_profile 
5. sudo source /etc/profile

###安装zookeeper
1.解压
>






