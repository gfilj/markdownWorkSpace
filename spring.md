###@Component([name])
spring会主动注册一个bean，如果不主动声明会以类名首字母小写的形式注册bean的名字，还有一个相同的注释是为@Named,只有细微的差别，其他的地方还是一样的
###@ComponentScan([name])
1. 组件扫描默认不会开启，只有声明为这个的时候组件扫描才会开启
2. 这个组件如果不声明会在当前默认的下面进行寻找，
3. @ComponentScan(basePackages="soundsystem")
4. @ComponentScan(basePackages={"soundsystem", "video"})
5. @ComponentScan(basePackageClasses={CDPlayer.class, DVDPlayer.class})
###@RunWith*(SpringJUnit4ClassRunner.class)
have a Spring application context automatically created when the test starts
###@ContextConfiguration
load its configuration from the CDPlayerConfig class.
###@Autowired
2.2 
###explicit configuration
* java
* xml
###@Configuration
Creating a configuration class

