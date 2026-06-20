---

# Docker 容器无法连接 QQ 企业邮箱 SMTP 问题排查与解决

## 一、问题现象

- **容器 messagesend-1**：无法发送邮件，连接 SMTP 服务超时
- **宿主机 node2**：删除 hosts 配置后测试失败，重新添加后恢复正常

---

## 二、排查过程

### 2.1 初始状态

**宿主机 node2 `/etc/hosts` 原有配置：**
```
157.255.202.11 smtp.exmail.qq.com
```
此时宿主机可以正常连接 SMTP 服务。

### 2.2 问题触发

**错误操作**：删除了 `/etc/hosts` 中的解析记录
```
# 删除后，smtp.exmail.qq.com 解析到真实 DNS IP
```

**结果**：
- 宿主机无法访问真实 DNS 解析出的 IP（网络不通）
- 容器内本来就没有 hosts 配置，一直无法访问

### 2.3 根因定位

| 问题                  | 说明                                                         |
| --------------------- | ------------------------------------------------------------ |
| 宿主机 hosts 被删除   | 导致解析到其他 IP，而宿主机无法访问那些 IP                   |
| 容器内没有 hosts 配置 | 容器一直解析到真实 DNS IP，同样无法访问                      |
| 网络限制              | 宿主机所在网络只能访问特定 IP `157.255.202.11`，无法访问其他 SMTP 服务器 IP |

### 2.4 恢复方法

**重新添加 hosts 记录：**
```bash
echo "157.255.202.11 smtp.exmail.qq.com" >> /etc/hosts
```

宿主机立即恢复正常，但容器仍需单独配置。

---

## 三、解决方案

### 3.1 修改 docker-compose.yml 添加 extra_hosts

```yaml
version: "3"
networks:
  servicenet:
    external: true
services:
  messagesend-1:
    image: choicelink_java8:1.2.1
    ports:
      - "8104:8104"
    restart: "always"
    container_name: messagesend-1
    environment:
      - TZ=Asia/Shanghai
      - sleep.second=5
      # ... 其他环境变量
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
    volumes:
      - ./xxlJobLog:/usr/jars/xxl-executor/xxlJobLog
      - ./log1:/log
      - ./messagesend1.jar:/messagesend.jar
      - /home/4.5/jars/wait.sh:/wait.sh
      - ./fonts:/usr/share/fonts
    entrypoint: /wait.sh -d ${NACOS_SERVER_ADDR},${POSTGRES_IP}:${POSTGRES_PORT},${XXJ_IP}:${XXJ_PORT} -c "exec java -Xms128m -Xmx256m -jar -Dspring.profiles.active=kirin -DcurrentPlatformId=${CURRENT_PLATFORM_ID} messagesend.jar> /dev/null"
    networks:
      servicenet: {}
    extra_hosts:
      - "smtp.exmail.qq.com:${SMTP_HOST_IP:-157.255.202.11}"
```

### 3.2 环境变量默认值语法说明

```yaml
${SMTP_HOST_IP:-157.255.202.11}
```

| 条件                        | 结果                  |
| --------------------------- | --------------------- |
| `SMTP_HOST_IP` 未设置或为空 | 使用 `157.255.202.11` |
| `SMTP_HOST_IP` 已设置       | 使用设置的值          |

### 3.3 可选：创建 .env 文件

```bash
# .env 文件内容
SMTP_HOST_IP=157.255.202.11
POSTGRES_IP=192.168.1.100
POSTGRES_PORT=5432
NACOS_SERVER_ADDR=192.168.1.101:8848
```

---

## 四、部署步骤

### 4.1 确保宿主机 hosts 配置正确

```bash
# 检查宿主机配置
cat /etc/hosts | grep smtp

# 如果没有，添加记录
echo "157.255.202.11 smtp.exmail.qq.com" >> /etc/hosts
```

### 4.2 重新创建容器

```bash
# 停止旧容器
docker-compose -f docker-compose1.yml down

# 重新创建并启动
docker-compose -f docker-compose1.yml up -d
```

### 4.3 验证配置

```bash
# 查看容器内 hosts 文件
docker exec messagesend-1 cat /etc/hosts | grep smtp

# 预期输出：
# 157.255.202.11 smtp.exmail.qq.com
```

---

## 五、核心结论

| 关键点                  | 说明                                                         |
| ----------------------- | ------------------------------------------------------------ |
| 宿主机 hosts 对容器无效 | 容器有独立的 `/etc/hosts`，不会继承宿主机配置                |
| 容器需要单独配置        | 必须通过 `extra_hosts` 或 `--add-host` 添加解析              |
| 网络访问受限            | 当前环境只能访问特定 IP `157.255.202.11`，其他 SMTP IP 不可达 |
| 宿主机删除 hosts 会失败 | 因为解析到其他不可达的 IP                                    |

---

## 六、注意事项

| 项目                        | 说明                                     |
| --------------------------- | ---------------------------------------- |
| 宿主机和容器 hosts 独立     | 两者需要分别配置                         |
| 删除宿主机 hosts 会导致失败 | 因为解析到其他不可达 IP                  |
| 容器重启手动修改丢失        | 必须通过 compose 或 `--add-host` 持久化  |
| 网络限制需提前了解          | 明确哪些 IP 是可达的，避免解析到其他地址 |

---

## 七、快速排查命令清单

```bash
# 检查宿主机 hosts
cat /etc/hosts | grep smtp

# 检查容器 hosts
docker exec messagesend-1 cat /etc/hosts | grep smtp

# 测试宿主机连通性
nc -zv smtp.exmail.qq.com 465

# 测试容器连通性
docker exec messagesend-1 nc -zv smtp.exmail.qq.com 465

# 查看容器内 DNS 解析
docker exec messagesend-1 nslookup smtp.exmail.qq.com
```

---

**文档版本**：v1.1  
**更新日期**：2026-06-11  
**适用环境**：Docker 20.10+, Docker Compose v3