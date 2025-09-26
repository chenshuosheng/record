# Arthas 全方位学习手册

**Java 诊断利器 Arthas 完全指南**
涵盖下载安装、核心功能、实战技巧及生产环境最佳实践

```shell
graph TD
    A[Arthas学习路径] --> B[基础篇]
    A --> C[进阶篇]
    A --> D[实战篇]
    B --> B1[下载安装]
    B --> B2[快速启动]
    B --> B3[常用命令]
    C --> C1[热更新]
    C --> C2[内存分析]
    C --> C3[性能优化]
    D --> D1[CPU飙高]
    D --> D2[内存泄漏]
    D --> D3[慢请求]

```

![测试](https://qy.chinapsp.cn:39001/uploadCenter/api/public/hdfs/downloadFile?id=524c18cc-1f39-4cea-a523-69ead4e4a65a)



## 一、安装部署

### 1. 下载 Arthas

```shell
# 官方推荐下载方式
curl -O https://arthas.aliyun.com/arthas-boot.jar

# 或使用备用地址
wget https://alibaba.github.io/arthas/arthas-boot.jar
```

### 2. 安装依赖

```shell
# 确保已安装 Java 环境
java -version

# 推荐 JDK 8+
```

### 3. 快速验证

```shell
java -jar arthas-boot.jar -h
```



## 二、核心操作

### 1. 启动 Arthas

```shell
# 基础启动
java -jar arthas-boot.jar

# 指定目标进程
java -jar arthas-boot.jar 12345

# 无交互模式（输出到文件）
java -jar arthas-boot.jar -b -o /tmp/arthas.log
```

### 2. 进程选择

启动后选择目标 Java 进程：

```shell
[INFO] Found existing java processes:
  [1]: 8080 spring-boot-app.jar
  [2]: 9090 dubbo-service.jar
Input process index to attach: 
```

### 3. 停止 Arthas

| 命令       | 说明         | 效果            |
| :--------- | :----------- | :-------------- |
| `stop`     | 完全退出     | 释放所有资源    |
| `quit`     | 仅断开控制台 | Arthas 后台运行 |
| `shutdown` | 强制终止     | 立即停止诊断    |

### 4. 安全退出流程

```
[arthas@8080]$ stop  # 在控制台执行

# 验证是否退出
ps aux | grep arthas
```



## 三、基础诊断命令

### 1. 系统监控

```shell
dashboard   # 实时监控面板
thread      # 查看线程
jvm         # JVM 信息
sysenv      # 系统环境变量
telnet 127.0.0.1 3658  # 服务默认运行端口
```

### 2. 类/方法诊断

```shell
sc *Controller  # 查找类
sm UserService getUser  # 查看方法

# 方法执行监控
watch com.example.UserService getUser "{params,returnObj}" -x 3
```

### 3. 性能分析

```shell
# 最忙线程
thread -n 3

# 方法耗时追踪
trace com.example.Service * '#cost > 100'
```

### 4. 代码反编译

```shell
jad com.example.ProblemClass

# 只反编译方法
jad --source-only com.example.ProblemClass problemMethod
```



## 四、进阶技巧

### 1. 热更新代码

```shell
# 1. 反编译类
jad --source-only com.example.Service > /tmp/Service.java

# 2. 修改源码
vim /tmp/Service.java

# 3. 编译为字节码
mc /tmp/Service.java -d /tmp

# 4. 热部署
redefine /tmp/com/example/Service.class
```

### 2. 内存泄漏分析

```shell
# 1. 检查堆内存
memory

# 2. 查看对象实例
vmtool -x 3 --action getInstances --className com.example.LeakClass

# 3. 分析对象引用
heapdump /tmp/heapdump.hprof
```

### 3. 异步任务监控

```shell
# 监控线程池状态
ognl '@java.util.concurrent.ThreadPoolExecutor@getPoolSize()'

# 追踪 CompletableFuture
tt -t java.util.concurrent.CompletableFuture get
```

### 4. Web 请求分析

```shell
# 追踪 HTTP 请求
trace org.springframework.web.servlet.DispatcherServlet doDispatch

# 过滤慢请求
trace *Filter doFilter '#cost > 500'
```



## 五、生产环境实战

### 案例 1：CPU 飙高排查

```shell
# 1. 定位高CPU线程
thread -n 3

# 2. 查看线程堆栈
thread 123

# 3. 追踪问题方法
trace com.example.Service problemMethod
```

### 案例 2：接口响应慢

```shell
# 1. 监控请求链路
trace com.example.*Controller * '#cost > 1000'

# 2. 分析SQL性能
watch *Mapper queryData '{params, #cost}' -x 3

# 3. 检查连接池
ognl '@com.zaxxer.hikari.HikariDataSource@getHikariPoolMXBean()'
```

### 案例 3：内存 OOM 分析

```shell
# 1. 生成堆转储
heapdump /tmp/oom.hprof

# 2. 统计大对象
vmtool --action getInstances --className java.util.HashMap --limit 10

# 3. 分析对象引用
options unsafe true
stack java.lang.StringBuilder toString
```



## 六、最佳实践

### 1. 安全配置

```shell
# 启动时设置鉴权
java -jar arthas-boot.jar --telnet-port 3658 --http-port 8563 \
     --username admin --password mypass
```

### 2. 容器化部署

Dockerfile 示例：

dockerfile

```shell
FROM openjdk:8
RUN curl -o /opt/arthas.jar https://arthas.aliyun.com/arthas-boot.jar
ENTRYPOINT ["java","-jar","/opt/arthas.jar"]
```

### 3. 常用配置项

properties

```shell
# ~/.arthasrc 配置文件
async.result.timeout=30000
disable.command=jad,mc,redefine
history.file=/data/arthas/history.log
```

### 4. 性能优化技巧

```shell
# 减少监控开销
options sampleInterval 1000  # 采样间隔(ms)

# 限制数据输出
options json-format false

# 批处理命令
batch execute /path/to/commands.txt
```



## 七、资源推荐

1. **官方文档**
   https://arthas.aliyun.com/doc/
2. **在线教程**
   https://arthas.aliyun.com/doc/arthas-tutorials.html
3. **GitHub 仓库**
   https://github.com/alibaba/arthas
4. **案例集合**
   https://github.com/alibaba/arthas/issues?q=label%3Auser-case