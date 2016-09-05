##maven中profile的使用
<pre><code>&lt;profiles>  
        &lt;profile>  
             &lt;id>profileTest1&lt;/id>  
             &lt;properties>  
                    &lt;hello>world&lt;/hello>  
             &lt;/properties>  
             &lt;activation>  
                    &lt;activeByDefault>true&lt;/activeByDefault>  
             &lt;/activation>  
        &lt;/profile>  
          
        &lt;profile>  
             &lt;id>profileTest2&lt;/id>  
             &lt;properties>  
                    &lt;hello>andy&lt;/hello>  
             &lt;/properties>  
        &lt;/profile>  
 &lt;/profiles>  
</pre></code>

1. profile的激活方式
	1. 使用activeByDefault设置激活
		1. profile中的activation元素中指定激活条件
		2. activeByDefault为true的时候就表示当没有指定其他profile为激活状态时，该profile就默认会被激活
			1. 当我们使用**mvn package –P profileTest2**的时候将激活profileTest2
	3. 