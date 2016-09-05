##安装varnish
[click here](http://www.cnblogs.com/littlehb/archive/2012/02/11/2346319.html)
  
###automake: 未找到命令  
yum install autoconf  
yum install automake  
  
###[libtoolize: command not found](http://blog.csdn.net/bingqingsuimeng/article/details/8237869)  
yum install libtool*

`对于未找到命令这一说，网上查找需要用rpm进行安装还要修改配置文件感觉挺繁琐的，其实yum本身就是安装程序，我采用了yum的安装命令，结果可以安装成功`  

###No backends or directors found in VCL program, at least one is necessary.  
解决办法：没有设置varnish配置文件

配置文件中不能出现英文中的句号  

###Varnish启动：  
/usr/local/varnish/sbin/varnishd -f /usr/local/varnish/etc/varnish/default.vcl -T 127.0.0.1:2000 -a 0.0.0.0:80 -s file,/tmp,200M 
###[找不到varnishstat等命令](http://blog.csdn.net/keketrtr/article/details/49586225)
yum install -y automake autoconf libtool ncurses-devel libxslt groff pcre-devel pkgconfig
###varnishstat

###varnish线上配置的地址
1. bjyz-simg-origin-1.server.163.org
2. bjyz-simg-origin-3.server.163.org
3. bjyz-simg-origin-2.server.163.org
4. bjyz-simg-origin-4.server.163.org
5. bjyz-simg-purge-2.server.163.org
6. bjyz-simg-3.server.163.org
7. bjyz-simg-6.server.163.org
8. bjyz-simg-4.server.163.org
9. bjyz-simg-5.server.163.org
10. bjyz-simg-purge-1.server.163.org
11. bjyz-simg-1.server.163.org
12. bjyz-simg-2.server.163.org
* bjyz-simg-test.server.163.org
* bjyz-simg-test-origin.server.163.org
###curl用法

####使用的proxy服务器及其端口：-x 
curl -x 
####显示http头部信息
curl -I
####指定method
curl -X

然后进行缓存判定和生成，以及缩图服务的实时处理  

1. 明天先将基本流程跑通
2. 然后开始清理缓存服务的顺序问题


###实时缩图服务
Facebook 百万并发  
varnish缓存服务--》nginx--》varnish（缩略图缓存）--》缩略图服务--》varnish（原图缓存）原图服务  
对于分布式部署，因为采用无状态式的分发采用轮询和一致性hash是一样的嘛，估计不会一样，肯定不一样的，这个图片在这台机器上缓存就可能不会在下台机器上缓存，所以必须用hash，来进行匹配，这样才能保证相同的缓存服务请求往一台机器上发送，  

用轮询的话，可能会只往一台上发送， 等数据量上来的时候，每台机器上都有  
分布式部署清除缓存   nos--》清除varnish各级缓存，每台机器都得清除啊  
先登录跳板机  
**ssh -p1046**  
sudo -iu appops  
whereis varnishd  

###本地启动
/usr/local/varnish/sbin/varnishd -f /usr/local/varnish/etc/varnish/default.vcl -T 127.0.0.1:2000 -a 0.0.0.0:80 -s file,/tmp,200M


###Varnishlog 日志格式[-b(服务器)/-c(客户端)]
https://www.varnish-cache.org/docs/trunk/reference/vsl.html


Varnishlog b 服务端日志  
Varnishlog c 客户端日志  
**varnishlog -c -i Hash** 查看hash的日志

###Varnishstat 
统计信息  缓存命中次数，未命中次数，请求数，缓存大小等
机器上的启动命令
/usr/sbin/varnishd -P /var/run/varnishd.pid -a :6081 -T localhost:6082 -f /etc/varnish/default.vcl -S /etc/varnish/secret -s malloc,256m

###接口文档
新接口对s.cimg.163.com以及nos缩图进行了兼容，如果原图来自nos调用方式如下：

https://cimg.ws.126.net/?url=cms-bucket.nosdn.127.net/catchpic/D/DA/DAC6DA5F87D46328BF59B2CE748D978A.jpg?imageView&thumbnail=300x300&quality=85&type=webp

非nos图片调用方式:

https://cimg.ws.126.net/?url=img3.cache.netease.com/photo/0096/2012-10-16/400x400_8DUPEAFS4GJ60096.jpg&thumbnail=300x300&quality=85&type=webp

缓存清理：

curl  'cimg.ws.126.net/purge/?url=img3.cache.netease.com/photo/0096/2012-10-16/400x400_8DUPEAFS4GJ60096.jpg&thumbnail=300x300&quality=85&type=webp' -x 223.252.199.5:80

curl   'cimg.ws.126.net/purge/?url=cms-bucket.nosdn.127.net/catchpic/D/DA/DAC6DA5F87D46328BF59B2CE748D978A.jpg?imageView&thumbnail=300x300&quality=85&type=webp' -x 223.252.199.5:80


1.  nos 缓存清理：  
2.  cdn缓存清理：网宿、快网  
3.  杭州入口varnish     
4.  北京服务purge       清缓存顺序  
	a  img1.cache.bn.neteasse.com 原图  
	b  取原图 缓存清理  
	c  varnish缓存清理  



新接口对s.cimg.163.com以及nos缩图进行了兼容，如果原图来自nos调用方式如下：

https://mobilepic.ws.126.net/?url=cms-bucket.nosdn.127.net/catchpic/D/DA/DAC6DA5F87D46328BF59B2CE748D978A.jpg?imageView&thumbnail=300x300&quality=85&type=webp

非nos图片调用方式:

https://mobilepic.ws.126.net/?url=img3.cache.netease.com/photo/0096/2012-10-16/400x400_8DUPEAFS4GJ60096.jpg&thumbnail=300x300&quality=85&type=webp

dypic.ws.126.net
cmspic.ws.126.net
mobilepic.ws.126.net
cimg.ws.126.net
cimg.ws.netease.com
###varnish教程
1. [varnish](http://anykoro.sinaapp.com/2012/01/31/varnish3-0%E4%B8%AD%E6%96%87%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)



###测试varnish的部署效果
curl -I   'http://s.cimg.163.com/i/cms-bucket.nosdn.127.net/d74134e974e04c1d9fe794979d045ef520160714145638.gif.50x50.auto.gif'   -x 127.0.0.1:6666
###varnish PURGE
curl -X PURGE  -I   'http://s.cimg.163.com/i/cms-bucket.nosdn.127.net/d74134e974e04c1d9fe794979d045ef520160714145638.gif.50x50.auto.gif'   -x 127.0.0.1:6666
###注意
再请求是localhost的时候，hash存储会将头部省略掉没有host，只有path


###varnish的配置文件

###varnish相较于proxycache的好处
1. 内存监控，可以查询varnish当期内存使用了多少
varnishstat，varnishlog
2. 可以使用正则匹配将可以匹配的所有缩图请求的缓存都可以清除掉
具体使用正则匹配的方式
两种方式进行配置，一种采用purge 单个删除，一种采用ban 正则匹配删除，
3. varnish自定义vcl语言，这个语言很强大
具体如何使用vcl的方式


###varnish ppt内容设计
1. 什么是varnish
2. varnish,squid,apache,nginx缓存的对比
3. varnish工具
4. varnish流程
5. varnish的后端存储
###varnish,squid,apache,nginx缓存的对比
现在主流的cache有上面这个几种，那究竟应该选择哪一个呢，经过测试之后发现：
<pre><code>/usr/local/bin/webbench -c 100 -t 20 http://127.0.0.1:8080/00/01/RwGowEtWvcQAAAAAAAAWHH0Rklg81.gif
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.
varnish
Speed=476508 pages/min, 47258114 bytes/sec.
Requests: 158836 susceed, 0 failed.
squid
Speed=133794 pages/min, 7475018 bytes/sec.
Requests: 44598 susceed, 0 failed.
apache
Speed=160890 pages/min, 15856005 bytes/sec.
Requests: 53630 susceed, 0 failed.
nginx
Speed=304053 pages/min, 30121517 bytes/sec.
Requests: 101351 susceed, 0 failed.
</pre></code>
总的看起来是varnish > nginx > apache > squid
###varnish 工具
1. varnishlog 查看varnish的所有日志
	* 	Varnishlog -b 服务端日志  
		Varnishlog -c 客户端日志  
		**varnishlog -c -i Hash** 查看hash的日志
2. varnishncsa 类似apache 形式的日志
3. varnishstat varnish中的各种统计信息包括缓存命中次数，未命中次数，请求数，缓存大小等
###varnish流程
varnish内置流程涉及到几个varnish的几个内置函数 

1. 在vcl_recv的结果如果可以查询缓存并可以识别
	* 无法识别vcl_pipe
	* 可以识别但不是可缓存的对象交由vcl_pass
	* 可以识别也可以缓存的时候交由vcl_hash
2. vcl_hash 查询缓存中是否存在
	* 如果命中交由vcl_hit处理
	* 如果未命中交由vcl_miss处理
3. vcl_hit检查是否为pass（过期或者其他限定不能缓存的状态）
	*. 不是pass，直接递交vcl_deliver模块进行相应
	*. 是pass交由vcl_passc处理
4. vcl_miss检查时候为pass
	*. 如果为pass递交由vcl_pass
	*. 如果不是直接递从后台(proxy)取数据
5. vcl_pass(proxy)直接从后台取数据
6. 从后台取完数据走vcl_fetch模块，能缓存的就缓存，不缓存的直接缓存，最后交由vcl_deliver进行处理

###varnish的后端存储
1. 基于内存进行缓存，重启后数据将消失。
2. file：使用特定的文件存储全部的缓存数据
3. malloc：使用malloc()库调用在varnish启动时向操作系统申请指定大小的内存空间以存储缓存对象；
4. persistent(experimental)：与file的功能相同，但可以持久存储数据(即重启varnish数据时不会被清除)；仍处于测试期
5. 说明：在重启的时候，Varnish无法追踪某缓存对象是否存入了缓存文件，从而也就无从得知磁盘上的缓存文件是否可用，因此，file存储方法在varnish停止或重启时会清除数据。

###