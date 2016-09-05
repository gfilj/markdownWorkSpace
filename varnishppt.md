#varnish
1. varnish的特点
2. varnish和其他cache服务器的比较
3. varnish的后端存储
4. varnish的vcl处理流程
5. varnish的统计工具
6. varnish的使用
7. varnish中内置公共变量和函数
##varnish的特点
Varnish是一款高性能的开源HTTP加速器，它有以下几个特点

1. VCL(Varnish Configuration Language)：非常灵活；
2. Health checks：完善的健康检查机制；
3. ESI(Edge Side Includes)：在HTML中嵌入动态脚本文件。
4. Directors：后端服务器的调度方式：random，round-robin，client，hash，DNS。
5. Purging and banning：强大的缓存清除功能，可以以正则表达式的形式清除缓存。
6. Logging in Varnish：Varnish的log不是记录在文件中的，而是记录在共享内存中。当日志大小达到分配的共享内存容量，覆盖掉旧的日志。以这种方式记录日志比文件的形式要快很多，并且不需要磁盘空间。
7. 丰富的管理程序：varnishadm，varnishtop，varnishhist，varnishstat以及varnishlog等。
##varnish,squid,apache,nginx 缓存的比较
这几种缓存都是用于做加速服务，下面是利用webbench测试数据
<pre><code>/usr/local/bin/webbench -c 100 -t 20 http://127.0.0.1:8080/00/01/RwGowEtWvcQAAAAAAAAWHH0Rklg81.gif
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.
Benchmarking: GET http://127.0.0.1:8080/00/01/RwGowEtWvcQAAAAAAAAWHH0Rklg81.gif
100 clients, running 20 sec.
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
从测试结果来看 varnish > nginx > apache > squid

##varnish相比较于nginx proxy_cache
1. 可以进行正则匹配批量删除 这对于各种格式的缩图清除很给力
2. 可以监控内存的状态，内存不够的时候可以自动进行覆盖 
3. 性能优于nginx proxy-cache

##varnish的后端存储
varnish支持多种不同类型的后端存储，这可以在varnishd启动时使用-s选项制定

* file:使用特定的文件存储全部的缓存数据，并通过操作系统的mmap()系统调用将整个缓存文件映射至内存区域
* malloc:直接向操作系统申请内存
* persistent(experimental):与file的功能相同，但可以持久化存储数据，仍处于测试期

varnish无法追踪某缓存对象是否存入了文件，从而也就无从得知磁盘上的缓存文件是否可用，因此file存储方法在varnish停止或者重新启动的时会清除数据，  
persistent方法的出现对此有了一个弥补，但persistent仍处于测试阶段，例如目前尚无法有效处理要缓存的对象总体大小超出缓存空间的情况，所以仅使用于有着巨大缓存空间的场景

##varnish主要流程
1. 请求刚来的时候先到的是**vcl_recv**模块
	* 无法识别交由**vcl_pipe**
	* 可以识别但pass(不可以或者不用缓存)**vcl_pass**
	* 可以识别可以缓存的**vcl_hash**
2. **vcl_hash**判断缓存中此对象是否存在
	* 存在**vcl_hit**
	* 不存在**vcl_miss**
3. **vcl_hit**校验条件pass(类似于过期，等其他在vcl中声明的条件)
	* 不满足**vcl_deliver**
	* 满足**vcl_pass**
4. **vcl_miss**校验条件pass(类似于过期，等其他在vcl中声明的条件)
	* 不满足**Fetch backend**
	* 满足**vcl_pass**
5. **vcl_pass**调用**fetch backend**
6. **fetch backend**之后进行**vcl_fetch**
7. **vcl_fectch**校验条件pass(类似于过期，等其他在vcl中声明的条件)
	* 可以缓存的调用缓存机制
	* pass的不进行缓存
	* 最后走向**vcl_deliver**
8. 由 **vcl_deliver**响应客户端


##varnish工具
1. varnishlog
-c 客户端日志 -b 后端服务的日志 
2. varnishncsa
用apache的格式显示出日志，和varnishlog的参数类似
3. vanishstat
统计varnish的缓存命中次数，未命中次数，请求数，缓存大小等。
4. varnishhist 读取共享日志，不断更新显示最新N个请求的柱状图，主要针对于完成耗时
5. varnishsizes 读取共享日志，不断更新显示最新N个请求的柱状图，主要针对请求量
6. varnishtop 展现访问最多的log 日志
	1. varnishtop -i rxurl 客户端请求最多的日志
	2. varnishtop -i txurl 后端服务器访问最多的次数
 
##varnish使用

1. varnish 的启动
2. varnish 配置server
3. 配置缓存的有效时间
4. 指定Object的ttl
5. 针对cookie的操作
6. 针对Accept-Encoding设置
7. 缓存删除（ban and purge）
8. 使用esi
9. 默认的行为
10. gzip和esi
11. 健康检查和轮询策略
12. 结合java请求调用varnish
###varnish的启动
<pre><code>/usr/local/varnish-2.1.5/sbin/varnishd **-f** /usr/local/varnish-2.1.5/etc/varnish/default.vcl **-T** 127.0.0.1:2000 **-a** 0.0.0.0:80 **-s** file,/tmp,200M  
</pre></code>

* -f用来指定配置文件
* -T指定管理台的访问地址
* -a指定Varnish监听地址
* -s指定Varnish以文件方式来缓存资源，地址为/tmp，大小200MB。

###varnish 配置 servers
<pre><code>backend default {
      .host = "127.0.0.1";
      .port = "80";
}
</pre></code>
###配置缓存的有效时间
通过在请求中添加Cache-Control 和Age  设置缓存的有效时间
<pre><code>Cache-Control: public, max-age=600
Cache-Control: nocach
</pre></code>
###指定Object的ttl
在vcl_fetch模块中重写
<pre><code>sub vcl_fetch {
    if (req.url ~ "^/legacy_broken_cms/") {
        set beresp.ttl = 5d;
    }
}
</pre></code>
###针对cookie的操作
1.设置固定请求漠视cookie
<pre><code>在vcl_recv中添加如下代码
if ( !( req.url ~ ^/admin/) ) {
  unset req.http.Cookie;
}
</pre></code>
2.设置缓存制定的cookie
<pre><code>sub vcl_recv {
  if (req.http.Cookie) {
    set req.http.Cookie = ";" + req.http.Cookie;
    set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
    set req.http.Cookie = regsuball(req.http.Cookie, ";(COOKIE1|COOKIE2)=", "; \1=");
    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

    if (req.http.Cookie == "") {
        remove req.http.Cookie;
    }
}
</pre></code>
###针对Accept-Encoding设置
正常化规范Accept-Encoding
<pre><code>if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
        # No point in compressing these
        remove req.http.Accept-Encoding;
    } elsif (req.http.Accept-Encoding ~ "gzip") {
        set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate") {
        set req.http.Accept-Encoding = "deflate";
    } else {
        # unknown algorithm
        remove req.http.Accept-Encoding;
    }
}
</pre></code>
###缓存删除（ban and purge）
purge 删除指定的固定缓存
<pre><code>acl purge {
        "localhost";
        "192.168.55.0"/24;
}
sub vcl_recv {
        # allow PURGE from localhost and 192.168.55...
        if (req.request == "PURGE") {
                if (!client.ip ~ purge) {
                        error 405 "Not allowed.";
                }
                return (lookup);
        }
}
sub vcl_hit {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}
sub vcl_miss {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}
</pre><code>
测试命令 `curl -I   'http://s.cimg.163.com/i/cms-bucket.nosdn.127.net/d74134e974e04c1d9fe794979d045ef520160714145638.gif.50x50.auto.gif'   -x varnishserver:6666`

ban匹配正则表达式批量产出缓存
<pre><code>sub vcl_recv {
	if (req.http.X-Purge-Regex) {
 	       if (!client.ip ~ purge) {
        	    error 405 "Varnish says nope, not allowed.";
       		}
        	ban_url(req.http.X-Purge-Regex);
        	error 200 "The URL has been Banned.";
	}
	   	 set req.backend = baz;
}</pre></code>

测试命令`curl -X PURGE -H 'X-Purge-Regex: ^/assets/*.css' varnishserver:6666`
###使用esi
esi的机制可以将网页中的各种元素进行缓存，而不是整个页面，这样对于那些可以复用的网页元素是非常有用的
esi的常用命令：

* esi:include
* esi:remove
* <!--esi ...--/>

<pre><code>sub vcl_fetch {
    if (req.url == "/test.html") {
       set beresp.do_esi = true; /* Do ESI processing               */
       set beresp.ttl = 24 h;    /* Sets the TTL on the HTML above  */
    } elseif (req.url == "/cgi-bin/date.cgi") {
       set beresp.ttl = 1m;      /* Sets a one minute TTL on        */
                                 /*  the included object            */
    }
}
</pre></code>
###默认的行为
1. 如果varnish检查客户端支持gzip，那么varnish会强制重写Accept-Encoding header
2. 如果客户端不支持，varnish针对压缩的请求头会在deliver的时候自动解压缩

###Gzip和esi
gzip和esi的结合是非常好的，当在处理esi的片段是 varnish会自动解压缩这个片段

###高级的后端配置
可以配置轮询策略以及健康检查的策略
<pre><code>backend server1 {
	.host = "server1.example.com";
	.probe = {
		.url = "/";
		.interval = 5s;
		.timeout = 1 s;
		.window = 5;
		.threshold = 3;
	}
}
backend server2 {
	.host = "server2.example.com";
	.probe = {
		 .url = "/";
		 .interval = 5s;
		 .timeout = 1 s;
		 .window = 5;设定后端主机基于最近的几次探测
		 .threshold = 3;成功几次算是后端服务器正常
	}
}
director example_director round-robin {
{
      .backend = server1;
	  .weight = 1;
}
# server2
{
      .backend = server2;
	  .weight = 1;
}

}
</pre></code>
###结合java使用varnish
java 调用清除缓存，最主要的就是修改请求头中的信息，
<pre><code>HttpHost host = new HttpHost(urlHost, urlPort, urlProtocol);
HttpClient httpclient = HttpClientBuilder.create().build();
Builder config = RequestConfig.custom().setConnectTimeout(300)
		.setConnectionRequestTimeout(300);
if (WAY.PROXY == way) {
	this.setURI(URI.create(urlPath));
	HttpHost proxy = new HttpHost(urlProxyHost, urlProxyPort, urlProtocol);
	config.setProxy(proxy);
}
if (WAY.DEFAULT == way){
	this.setURI(URI.create(urlPath));
}
if (WAY.REG == way) {
	this.setHeader("X-Purge-Regex", "^" + regUrl + "*");
}
this.setConfig(config.build());
try {
	HttpResponse response = httpclient.execute(host, this);
	 System.out.println(String.format("statusLine:%s, content:%s",
	 response.getStatusLine(),
	 response.getEntity().toString()));
	return new PurgeResult(response.getStatusLine().getStatusCode(),
			response.getStatusLine().getReasonPhrase());
} catch (Exception e) {
	System.out.println(String.format("connect failed!"));
}
</pre></code>

###varnish内置的公共变量
1. 针对请求到达后可以使用的变量
	* req.backend 指定对应的后端主机
	* server.ip 表示服务器端IP
	* client.ip 表示客户端IP
	* req.request 指定请求的类型，例如GET、HEAD和POST等
	* req.url 指定请求的地址
	* req.proto 表示客户端发起请求的HTTP协议版本
	* req.http.header 表示对应请求中的HTTP头部信息
	* req. restarts ;/.l表示请求重启的次数，默认最大值为4
2. Varnish在向后端主机请求时，可以使用的公用变量
	* beresp.request 指定请求的类型，例如GET合HEAD等
	* beresp.url 指定请求的地址
	* beresp .proto 表示客户端发起请求的HTTP协议版本
	* http.header 表示对应请求中的HTTP头部信息
	* beresp .ttl 表示缓存的生存周期，也就是cache保留多长时间，单位是秒
3. 从cache或后端主机获取内容后，可以使用的公用变量
	* obj.status 表示返回内容的请求状态代码，例如200、302和504等
	* obj.cacheable 表示返回的内容是否可以缓存，也就是说，如果HTTP返回的是200、203、300、301、302、404或410等，并且有非0的生存期，则可以缓存
	* obj.valid 表示是否是有效的HTTP应答
	* obj.response 表示返回内容的请求状态信息
	* obj.proto 表示返回内容的HTTP协议版本
	* obj.ttl 表示返回内容的生存周期，也就是缓存时间，单位是秒
	* obj.lastuse 表示返回上一次请求到现在的间隔时间，单位是秒
4. 对客户端应答时，可以使用的公用变量
	* resp.status 表示返回给客户端的HTTP状态代码
	* resp.proto 表示返回给客户端的HTTP协议版本
	* resp.http.header 表示返回给客户端的HTTP头部信息
	* resp.response 表示返回给客户端的HTTP状态信息
###varnish 的内置函数
* regsub(str,regex,sub) 匹配正则表达式的字符串
* regsuball(str,regex,sub)：这两个用于基于正则表达式搜索指定的字符串并将其替换为指定的字符串；但regsuball()可以将str中能够被regex匹配到的字符串统统替换为sub，regsub()只替换一次；
* ban(expression)：
* ban_url(regex)：Bans所有其URL能够由regex匹配的缓存对象；
* purge：从缓存中挑选出某对象以及其相关变种一并删除，这可以通过HTTP协议的PURGE方法完成；
* hash_data(str)：
* return()：当某VCL域运行结束时将控制权返回给Varnish，并指示Varnish如何进行后续的动作；其可以返回的指令包括：lookup、pass、pipe、hit_for_pass、fetch、deliver和hash等；  
但某特定域可能仅能返回某些特定的指令，而非前面列出的全部指令；
* return(restart)：重新运行整个VCL，即重新从vcl_recv开始进行处理；每一次重启都会增加req.restarts变量中的值，而max_restarts参数则用于限定最大重启次数。


##演讲
大家好，这是我总结varnish的一些使用心得，今天和大家分享一下
我将从以下几个方面来介绍我对varnish的认识，varnish是一个应用加速器，主要通过缓存静态文件来加速应用，

缓存静态文件
varnish的一切缓存策略都是可以配置的
健康检查机制会配置在一个周期内进行几次检查，然后几次检查通过可以认为后端服务器是正常的，以及超时时间等
esi 
varnish 的访问速度更快，并发性更高，稳定性更好

varnish的file使用与环节

内存不够的时候会自动调用vcl_discard模块