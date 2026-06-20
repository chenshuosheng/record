报表官方文档： https://help.fanruan.com/finereport/doc-view-822.html

需要先安装 java 环境及tomcat，然后执行linux_amd64_FineReport-CN.sh安装报表到指定目录下，将%FR_HOME%\webapps目录下的 webroot 文件夹下的资源拷贝到%Tomcat_HOME%\webapps目录下的目标目录下（可以是自定义文件夹，将作为访问url的一部分）

默认访问地址：http://IP:端口号/工程名/decision，若指定了自定义文件夹（如：fineReport），则访问地址为：http://IP:端口号/fineReport/decision



时区不一致将导致下面异常：

```java
org.postgresql.util.PSQLException: FATAL: invalid value for parameter &quot;TimeZone&quot;: &quot;Asia/Beijing&quot;
	at org.postgresql.core.v3.QueryExecutorImpl.receiveErrorResponse(QueryExecutorImpl.java:2733)
	at org.postgresql.core.v3.QueryExecutorImpl.readStartupMessages(QueryExecutorImpl.java:2845)
	at org.postgresql.core.v3.QueryExecutorImpl.&lt;init&gt;(QueryExecutorImpl.java:176)
	at org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl(ConnectionFactoryImpl.java:323)
	at org.postgresql.core.ConnectionFactory.openConnection(ConnectionFactory.java:54)
	at org.postgresql.jdbc.PgConnection.&lt;init&gt;(PgConnection.java:273)
	at org.postgresql.Driver.makeConnection(Driver.java:446)
	at org.postgresql.Driver.connect(Driver.java:298)
	at com.fr.third.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1666)
	at com.fr.third.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1732)
	at com.fr.third.alibaba.druid.pool.DruidDataSource$CreateConnectionThread.run(DruidDataSource.java:2907)

```

解决方案(查询并更新服务器时区)

```shell
[root@node3 ~]# timedatectl
               Local time: 二 2025-11-04 14:03:56 CST
           Universal time: 二 2025-11-04 06:03:56 UTC
                 RTC time: 二 2025-11-04 06:04:23
                Time zone: Asia/Beijing (CST, +0800)
System clock synchronized: no

              NTP service: active
          RTC in local TZ: no
[root@node3 ~]#

# 将服务器时区改为 Asia/Shanghai
timedatectl set-timezone Asia/Shanghai

然后重启tomcat服务
```

