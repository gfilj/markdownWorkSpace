###Kafka最新版本的安装
1. 不需要安装zookeeper，
2. 默认启动的时候会无法发送数据报  Leader Not Available Kafka in Console Producer
	* 解决办法：在server.property中配置advertised.listeners=PLAINTEXT://hostname:9092
3. 针对consumer的group.id问题，无从得知
	1. 那么最直接的办法就是讲group.id 设置进入配置文件中启动kafka