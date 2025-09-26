# Docker 环境下使用 Arthas 完全指南

## 一、Docker 中使用 Arthas 的 4 种方式

### 方法 1：进入容器直接运行（推荐）

```shell
# 1. 进入容器
docker exec -it <container_name> /bin/bash

# 2. 下载 Arthas
curl -O https://arthas.aliyun.com/arthas-boot.jar

# 3. 启动诊断
java -jar arthas-boot.jar

# 4. 选择目标 Java 进程
```

### 方法 2：预装 Arthas 到镜像

dockerfile

```shell
FROM openjdk:11

# 安装 Arthas
RUN curl -o /opt/arthas-boot.jar https://arthas.aliyun.com/arthas-boot.jar

# 设置诊断脚本
COPY diagnose.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/diagnose.sh

ENTRYPOINT ["java", "-jar", "/app.jar"]
```

创建诊断脚本 `diagnose.sh`：

```shell
#!/bin/bash
# 启动应用
java -jar /app.jar &

# 启动 Arthas
java -jar /opt/arthas-boot.jar -f /diagnose-commands.txt
```

### 方法 3：挂载 Arthas 到运行中容器

```shell
# 1. 宿主机下载 Arthas
wget https://arthas.aliyun.com/arthas-boot.jar

# 2. 复制到容器
docker cp arthas-boot.jar <container_name>:/opt

# 3. 进入容器使用
docker exec -it <container_name> java -jar /opt/arthas-boot.jar
```

### 方法 4：使用诊断专用容器

```shell
# 1. 创建共享 PID 命名空间
docker run -d --name myapp your-java-app

# 2. 启动诊断容器
docker run -it --rm \
  --pid=container:myapp \
  --net=container:myapp \
  -v $(pwd)/arthas:/opt \
  openjdk:11 \
  java -jar /opt/arthas-boot.jar
```



## 二、容器环境特殊配置

### 1. 解决权限问题

```shell
# 在 docker run 中添加权限
docker run --cap-add=SYS_PTRACE ...
```

### 2. 精简镜像的特殊处理

对于 Alpine 等精简镜像：

```shell
# 安装必要依赖
apk add --no-cache openjdk11-jre-headless curl
```

### 3. Kubernetes 中的使用

```shell
apiVersion: v1
kind: Pod
metadata:
  name: java-app
spec:
  containers:
  - name: app
    image: your-java-app
  - name: arthas
    image: openjdk:11
    command: ["sleep", "infinity"]
    securityContext:
      capabilities:
        add: ["SYS_PTRACE"]
```

进入 Arthas 容器：

```shell
kubectl exec -it java-app -c arthas -- java -jar /opt/arthas-boot.jar
```



## 三、容器专用诊断技巧

### 1. 诊断内存泄漏

```shell
# 生成堆转储到共享卷
heapdump /shared-volume/heapdump.hprof

# 在宿主机分析
docker cp <container>:/shared-volume/heapdump.hprof .
```

### 2. 网络问题诊断

```shell
# 查看容器内网络连接
netstat -tunlp

# 检查 DNS 解析
watch -n 1 'cat /etc/resolv.conf'
```

### 3. 文件系统分析

```shell
# 查看容器内文件变化
vmtool --action getInstances --className java.io.File \
  --express 'instances[0].listFiles()'
```

### 4. 容器资源限制诊断

```shell
# 检查 CGroup 限制
cat /sys/fs/cgroup/memory/memory.limit_in_bytes
cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us
```



## 四、生产环境最佳实践

### 1. 安全访问控制

```shell
# 启动时添加认证
java -jar arthas-boot.jar \
  --telnet-port 3658 \
  --http-port 8563 \
  --username admin \
  --password ${ARTHAS_PASSWORD}
```

### 2. 资源消耗限制

```shell
# 限制 Arthas 内存使用
JAVA_TOOL_OPTIONS="-Xmx128m" java -jar arthas-boot.jar
```

### 3. 自动化诊断脚本

创建 `diagnose-commands.txt`：

```shell
# 自动执行诊断命令
thread -n 3
jvm
dashboard -i 5000 -n 3
stop
```

启动时执行：

```shell
java -jar arthas-boot.jar -f diagnose-commands.txt -o /tmp/diagnose.log
```

### 4. 容器构建优化

dockerfile

```shell
# 使用多阶段构建减小镜像
FROM openjdk:11 as arthas
RUN curl -o /arthas.zip https://arthas.aliyun.com/download/latest?mirror=aliyun \
 && unzip /arthas.zip

FROM your-java-app:latest
COPY --from=arthas /arthas /opt/arthas
```



## 五、常见问题解决方案

### Q1：无法附加到进程

**错误**：`attach fail, targetPid: 1, error: ptrace(ATTACH) operation not permitted`
**解决**：

```shell
docker run --cap-add=SYS_PTRACE ...
```

### Q2：容器内缺少 JDK

**解决**：

dockerfile

```shell
# 基于 JRE 镜像添加 JDK 工具
FROM openjdk:11-jre
RUN apt-get update && apt-get install -y openjdk-11-jdk-headless
```

### Q3：Arthas 版本兼容性

```shell
# 指定兼容旧 JVM 的版本
java -jar arthas-boot.jar --use-version 3.6.7
```

### Q4：容器内存不足

```shell
# 使用精简版命令
thread -n 3 --plain
```



## **关键提示**：生产环境使用后务必执行 `stop` 命令退出 Arthas，避免长期驻留容器。对于 Kubernetes 环境，建议使用临时诊断 Sidecar 容器，用完即销毁。