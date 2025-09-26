## 用 **OpenSSL** 生成自签名证书用于 RabbitMQ TLS 加密



------



##  一、准备工作

确保系统安装了 `openssl`：

```shell
# Ubuntu/Debian
sudo apt update && sudo apt install openssl

# CentOS/RHEL
sudo yum install openssl

# macOS (已预装)
openssl version
```

------



##  二、创建证书目录

```shell
cd mnt/database/rabbitmq
mkdir rabbitmq-certs
cd rabbitmq-certs
```

------



##  三、生成 CA 根证书（Certificate Authority）

CA 用于签发服务器和客户端证书，是信任链的根。

```shell
# 生成 CA 私钥（2048位，无密码）
openssl genrsa -out ca.key 2048

# 生成 CA 自签名证书（有效期10年）
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
```

**填写信息示例**（可随意填，但 Common Name 建议写 `RabbitMQ CA`）：

```shell
Country Name (2 letter code) []: CN
State or Province Name (full name) []: Beijing
Locality Name (eg, city) []: Beijing
Organization Name (eg, company) []: MyCompany
Organizational Unit Name (eg, section) []: IT
Common Name (e.g. server FQDN or YOUR name) []: RabbitMQ CA
Email Address []: admin@example.com
```

生成文件：

- `ca.key` —— CA 私钥（保密！）
- `ca.crt` —— CA 证书（可分发给客户端信任）

------



## 四、生成 RabbitMQ 服务器证书

### 1. 生成服务器私钥

```shell
openssl genrsa -out server.key 2048
```



### 2. 生成证书签名请求（CSR）

```
openssl req -new -key server.key -out server.csr
```

填写信息示例**（关键：Common Name 必须是 RabbitMQ 服务的主机名或 IP，如 `rabbitmq` 或 `192.168.1.100`）：

```shell
Country Name (2 letter code) []: CN
State or Province Name (full name) []: Beijing
Locality Name (eg, city) []: Beijing
Organization Name (eg, company) []: MyCompany
Organizational Unit Name (eg, section) []: IT
Common Name (e.g. server FQDN or YOUR name) []: rabbitmq  👈 必须是客户端连接时使用的主机名！
Email Address []: admin@example.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:      👈 直接回车留空
An optional company name []:  👈 直接回车留空
```

> 🚨 **重要**：`Common Name` 必须和你的 Spring Boot 客户端配置中的 `spring.rabbitmq.host` 一致！
>  例如你配的是 `host: rabbitmq`，这里 CN 就必须是 `rabbitmq`。
>  如果是 IP，比如 `host: 192.168.1.100`，CN 就填 `192.168.1.100`。



### 3. 用 CA 签发服务器证书

```
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -sha256
```

✅ 生成文件：

- `server.key` —— 服务器私钥（保密！）
- `server.crt` —— 服务器证书

------



### 4. 操作示例

```shell
[root@node3 ~]# cd /mnt/database/rabbitmq
[root@node3 rabbitmq-certs]# openssl genrsa -out ca.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
...........................................................................+++++
........................................................................................................+++++
e is 65537 (0x010001)
[root@node3 rabbitmq-certs]# openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:Guangdong
Locality Name (eg, city) []:Guangzhou
Organization Name (eg, company) [Internet Widgits Pty Ltd]:YCL
Organizational Unit Name (eg, section) []:IT
Common Name (e.g. server FQDN or YOUR name) []:RabbitMQ CA
Email Address []:chenshuosheng@choicelink.cn
[root@node3 rabbitmq-certs]# openssl genrsa -out server.key 2048
Generating RSA private key, 2048 bit long modulus (2 primes)
..........................+++++
......................................+++++
e is 65537 (0x010001)
[root@node3 rabbitmq-certs]# openssl req -new -key server.key -out server.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:Guangdong
Locality Name (eg, city) []:Guangzhou
Organization Name (eg, company) [Internet Widgits Pty Ltd]:YCL
Organizational Unit Name (eg, section) []:IT
Common Name (e.g. server FQDN or YOUR name) []:rabbitmq
Email Address []:chenshuosheng@choicelink.cn

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@node3 rabbitmq-certs]# openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -sha256
Signature ok
subject=C = CN, ST = Guangdong, L = Guangzhou, O = YCL, OU = IT, CN = rabbitmq, emailAddress = chenshuosheng@choicelink.cn
Getting CA Private Key
[root@node3 rabbitmq-certs]
```



### 5. 说明

| 步骤 | 命令                                               | 是否正确 | 说明                                                         |
| ---- | -------------------------------------------------- | -------- | ------------------------------------------------------------ |
| 1    | `openssl genrsa -out ca.key 2048`                  | ✅        | 成功生成 CA 私钥                                             |
| 2    | `openssl req -x509 -new -nodes -key ca.key ...`    | ✅        | 成功生成 CA 证书，信息填写完整合理                           |
| 3    | `openssl genrsa -out server.key 2048`              | ✅        | 成功生成服务器私钥                                           |
| 4    | `openssl req -new -key server.key -out server.csr` | ✅        | 成功生成 CSR，**最关键的是 `Common Name = rabbitmq`，和 Spring Boot 配置中的 `host: rabbitmq` 完全匹配** |
| 5    | `openssl x509 -req -in server.csr -CA ...`         | ✅        | 成功用 CA 签发服务器证书，输出 `Signature ok` 表示成功       |



### 6. 额外验证

为了 100% 确保私钥和证书匹配，建议执行以下验证命令：


```shell
# 1. 验证 CA 证书和 CA 私钥是否匹配
openssl x509 -noout -modulus -in ca.crt | openssl md5
openssl rsa -noout -modulus -in ca.key | openssl md5

# 2. 验证服务器证书和服务器私钥是否匹配
openssl x509 -noout -modulus -in server.crt | openssl md5
openssl rsa -noout -modulus -in server.key | openssl md5
```

✅ 如果每组两个命令输出的 MD5 **完全相同**，说明匹配无误。

------



##  五、为 RabbitMQ 准备证书文件

RabbitMQ 需要 `.pem` 格式的证书文件（包含证书 + 私钥）：

```shell
# 合并服务器证书和私钥
cat server.crt server.key > server.pem

# 检查内容
cat server.pem
```

最终用于 RabbitMQ 的文件：

- `server.pem` —— 服务器证书+私钥
- `ca.crt` —— CA 证书（用于验证客户端证书，如果启用双向 TLS）

在宿主机执行：

```shell
# 进入证书目录
cd /mnt/database/rabbitmq/rabbitmq-certs

# 确保有 server.pem（如果没有，合并生成）
cat server.crt server.key > server.pem

# 设置权限（RabbitMQ 容器内用户是 rabbitmq，UID 999）
sudo chown -R 999:999 /mnt/database/rabbitmq/rabbitmq-certs
sudo chmod 600 /mnt/database/rabbitmq/rabbitmq-certs/*
```

------



## 六、配置 RabbitMQ 启用 TLS

编辑 `rabbitmq.conf`：

```shell
## ===== TLS 配置（核心安全配置） =====
listeners.ssl.default = 5671
ssl_options.cacertfile = /opt/certs/ca.crt
ssl_options.certfile   = /opt/certs/server.pem
ssl_options.keyfile    = /opt/certs/server.pem
ssl_options.verify     = verify_peer
ssl_options.fail_if_no_peer_cert = false

## ===== 禁用明文端口 =====
listeners.tcp = none

## ===== 管理界面 HTTPS 配置 =====
management.ssl.port = 15671
management.ssl.cacertfile = /opt/certs/ca.crt
management.ssl.certfile   = /opt/certs/server.pem
management.ssl.keyfile    = /opt/certs/server.pem

## ===== 认证机制（保持默认即可） =====
## 不需要特别配置 auth_mechanisms，PLAIN over TLS 是安全的！
## RabbitMQ 默认支持 PLAIN 和 AMQPLAIN，我们用 PLAIN over TLS 就够了

# 连接限制
# 限制每个连接的最大通道数，防止客户端创建过多通道消耗服务器资源
channel_max = 2047	
# 设置心跳检测间隔为60秒，检测连接是否存活，防止僵尸连接占用资源	
heartbeat = 60
# 设置最大帧大小为128KB，平衡性能和内存使用，避免过大帧导致内存溢出
frame_max = 131072

# 默认配置
# 使用默认的虚拟主机
default_vhost = /
# 指定默认用户
default_user = administrator
# 允许配置所有资源
default_permissions.configure = .*
# 允许读取所有队列和交换器
default_permissions.read = .*
# 允许向所有队列发送消息
default_permissions.write = .*

## ===== 日志配置 =====
log.connection.level = info
log.channel.level = warning
management.http_log_dir = /var/log/rabbitmq/management-access.log
```



编辑 rabbitmq-yaml

```shell
version: "3"
networks:
  servicenet:
    external: true

services:
  rabbitmq:
    image: rabbitmq:latest
    container_name: rabbitmq
    restart: always
    environment:
      RABBITMQ_DEFAULT_USER: 'administrator'
      RABBITMQ_DEFAULT_PASS: 'Xinxibu1717...'
    ports:
      #- "15672:15672"   # HTTP 管理界面（可选，建议内网访问）
      - "15671:15671"   # HTTPS 管理界面（推荐）
      - "5671:5671"     # AMQP over TLS 端口（必须）
      # - "5672:5672"   # 注释或删除明文端口！
    volumes:
      - "/mnt/database/rabbitmq/conf:/etc/rabbitmq"
      - "/mnt/database/rabbitmq/data:/var/lib/rabbitmq"
      - "/mnt/database/rabbitmq/log:/var/log/rabbitmq"
      - "/mnt/database/rabbitmq/rabbitmq-certs:/opt/certs"  # 挂载证书目录  # 设置权限（RabbitMQ 容器内用户是 rabbitmq，UID 999）
      #sudo chown -R 999:999 /mnt/database/rabbitmq/rabbitmq-certs
      #sudo chmod 600 /mnt/database/rabbitmq/rabbitmq-certs/*
    logging:
      driver: json-file
      options:
        max-size: "100m"
        max-file: "2"
    networks:
      servicenet: {}
```



## 七、详细排查与修复过程

### 7.1 步骤 1：确认 RabbitMQ 监听状态

```
docker exec rabbitmq rabbitmqctl status
```

输出片段：

```
Listeners

Interface: [::], port: 5671, protocol: amqp/ssl, purpose: AMQP 0-9-1 and AMQP 1.0 over TLS
Interface: [::], port: 15671, protocol: https, purpose: HTTP API over TLS (HTTPS)
```

✅ **确认：TLS 监听已启用，协议正确。**

------



### 7.2 步骤 2：确认网络监听（IPv6）

```
docker exec rabbitmq ss -tlnp -6 | grep 5671
```

输出：

```
LISTEN 0      128     [::]:5671                [::]:*    users:(("beam.smp",pid=19,fd=42))
```

✅ **确认：容器内监听 IPv6 5671 端口。**

------



### 7.3 步骤 3：确认宿主机端口映射

```
docker port rabbitmq
```

输出：

```
5671/tcp -> 0.0.0.0:5671
15671/tcp -> 0.0.0.0:15671
25672/tcp -> 0.0.0.0:25672
```

✅ **确认：宿主机已映射 5671 端口，外部可访问。**

------



### 7.4 步骤 4：测试 TLS 连接（关键验证）

bash深色版本

```
openssl s_client -connect localhost:5671 -CAfile /mnt/database/rabbitmq/rabbitmq-certs/ca.crt
```

关键输出解读：

| 输出内容                                         | 含义                                |
| ------------------------------------------------ | ----------------------------------- |
| `CONNECTED(00000003)`                            | TCP 连接成功                        |
| `Verify return code: 0 (ok)`                     | 证书验证通过                        |
| `New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384` | 使用 TLS 1.3 强加密                 |
| `Server certificate`                             | 显示服务端证书信息，Subject/CN 匹配 |

✅ **结论：TLS 握手成功，加密通信已建立，无明文传输。**

------



### 7.5 步骤 5：验证 HTTPS 管理界面（辅助验证）

bash深色版本

```
curl -k -I https://localhost:15671
```

输出：

```
HTTP/1.1 200 OK
server: Cowboy
date: Tue, 16 Sep 2025 00:15:30 GMT
content-length: 1074
content-type: text/html
cache-control: no-cache
```

✅ **结论：HTTPS 管理界面正常，TLS 配置全局生效。**

------



### 7.6 步骤 6：端口扫描验证（模拟安全扫描器）

```
nmap -p 5671,15671 --script ssl-cert localhost
```

输出片段：

```
5671/tcp  open  amqps
| ssl-cert: Subject: commonName=rabbitmq
| Issuer: commonName=RabbitMQ CA
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2025-09-15T07:11:14
|_Not valid after:  2035-09-13T07:11:14

15671/tcp open  unknown
| ssl-cert: Subject: commonName=rabbitmq
| Issuer: commonName=RabbitMQ CA
...
```

✅ **结论：nmap 识别为加密端口（amqps），证书信息完整，符合安全要求。**

------



## 八、安全合规结论

| 检查项                | 结果 | 详细说明                                       |
| --------------------- | ---- | ---------------------------------------------- |
| 是否启用 TLS 加密     | ✅ 是 | `rabbitmqctl status` 显示 `protocol: amqp/ssl` |
| 是否使用强加密协议    | ✅ 是 | TLSv1.3 + AES-256-GCM / ChaCha20               |
| 证书是否有效且受信    | ✅ 是 | 由私有 CA 签发，`openssl` 验证返回码 0         |
| 宿主机端口是否开放    | ✅ 是 | `docker port` 显示映射，`telnet` 可连接        |
| 是否存在明文传输      | ❌ 否 | 所有通信强制 TLS，无明文 AMQP                  |
| 是否符合等保/审计要求 | ✅ 是 | 满足“通信加密”、“证书管理”、“访问控制”要求     |

------



## 九、优化建议

### 9.1 强制 IPv4 监听（推荐）

修改 `rabbitmq.conf`：

```
listeners.ssl.1 = 0.0.0.0:5671
```

重启后：

```
docker exec rabbitmq ss -tlnp | grep 5671
```

→ 可直接看到 IPv4 监听，避免工具误判。



### 9.2 启用双向 TLS（mTLS）

如需客户端证书认证：

ini深色版本

```
ssl_options.verify = verify_peer
ssl_options.fail_if_no_peer_cert = true
```

并分发客户端证书。

### 9.3 防火墙放行（如启用）

```
firewall-cmd --permanent --add-port=5671/tcp
firewall-cmd --permanent --add-port=15671/tcp
firewall-cmd --reload
```

------



## 附录

### 附录 A：完整 `openssl s_client` 输出（关键片段）

```
CONNECTED(00000003)
depth=0 C = CN, ST = Guangdong, L = Guangzhou, O = YCL, OU = IT, CN = rabbitmq
verify return:1
---
Certificate chain
 0 s:... CN=rabbitmq
   i:... CN=RabbitMQ CA
 1 s:... CN=RabbitMQ CA
   i:... CN=RabbitMQ CA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIDqjCCApICFFKBiLkiHuN3dVdpCxY8ahBNvltaMA0GCSqGSIb3DQEBCwUAMIGS
...
-----END CERTIFICATE-----
---
SSL handshake has read 2762 bytes and written 405 bytes
Verification: OK
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Server public key is 2048 bit
Verify return code: 0 (ok)
```



### 附录 B：证书签发命令（参考）

```
# 生成 CA
openssl req -new -x509 -keyout ca.key -out ca.crt -days 3650 -subj "/C=CN/ST=Guangdong/L=Guangzhou/O=YCL/OU=IT/CN=RabbitMQ CA/emailAddress=xxx@xxx.com"

# 生成 Server Key
openssl genrsa -out server.key 2048

# 生成 CSR
openssl req -new -key server.key -out server.csr -subj "/C=CN/ST=Guangdong/L=Guangzhou/O=YCL/OU=IT/CN=rabbitmq/emailAddress=xxx@xxx.com"

# CA 签发
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650
```



### 附录 C：日志片段（TLS 启动成功）

log深色版本

```
2025-09-15 07:48:39.662392+00:00 [info] <0.717.0> started TLS (SSL) listener on [::]:5671
2025-09-15 07:48:39.662511+00:00 [info] <0.718.0> started TLS (SSL) listener on [::]:15671
```





> **Spring Boot 2.5.2 不支持 `spring.rabbitmq.ssl.trust-store=file:/path/to/ca.crt` 直接加载 PEM 格式的 `.crt` 文件！**

它只支持加载 **Java TrustStore（JKS 或 PKCS12 格式）**。

------

## ✅ 解决方案（适用于 Spring Boot 2.5.2）

需要将 `ca.crt`（PEM 格式）转换为 Java 能识别的 **JKS 格式 TrustStore**，然后配置路径。

------

## 步骤 1：生成 JKS 格式的 truststore

在宿主机执行：

```shell
cd /mnt/database/rabbitmq/rabbitmq-certs

# 删除旧文件（如有）
rm -f truststore.jks

# 导入 ca.crt 到 JKS 格式（密码设为 Xinxibu1717，可自定义）
keytool -import \
  -alias rabbitmq-ca \
  -file ca.crt \
  -keystore truststore.jks \
  -storepass Xinxibu1717 \
  -noprompt
```

✅ 执行后会生成 `truststore.jks`

------

## 步骤 2：修改 Spring Boot 配置

在application-kirin.yml` 中：

```
spring:
  rabbitmq:
    host: rabbitmq
    port: 5671
    username: administrator
    password: Xinxibu1717...
    requested-auth-mechanism: PLAIN
    ssl:
      enabled: true
      trust-store: file:/app/config/certs/truststore.jks   # 👈 指向 JKS 文件
      trust-store-type: JKS                                # 👈 必须指定类型
      trust-store-password: Xinxibu1717                        # 👈 必须和生成时一致
```

> ⚠️ 注意：
>
> - `trust-store` 必须以 `file:` 开头，表示外部文件
> - `trust-store-type` 必须是 `JKS`
> - `trust-store-password` 必须和你生成时设置的密码一致（这里是 `Xinxibu1717`）

------

## 步骤 3：修改 `docker-compose.yml`，挂载 JKS 文件

yaml深色版本

```
version: "3"
services:
  your-springboot-app:   # 👈 替换为你的服务名
    image: your-app-image:latest
    container_name: myapp
    restart: always
    ports:
      - "8080:8080"
    volumes:
      - "/mnt/database/rabbitmq/rabbitmq-certs/truststore.jks:/app/config/certs/truststore.jks:ro"
      #  :ro---是 “read-only” 的缩写，意思是：容器内只能读取这个文件，不能修改或删除它。
    environment:
      - SPRING_RABBITMQ_SSL_ENABLED=true
      - SPRING_RABBITMQ_SSL_TRUST_STORE=file:/app/config/certs/truststore.jks
      - SPRING_RABBITMQ_SSL_TRUST_STORE_TYPE=JKS
      - SPRING_RABBITMQ_SSL_TRUST_STORE_PASSWORD=Xinxibu1717
      # 如果你还需要配置 host/port/username/password，也可以在这里设置：
      - SPRING_RABBITMQ_HOST=rabbitmq
      - SPRING_RABBITMQ_PORT=5671
      - SPRING_RABBITMQ_USERNAME=administrator
      - SPRING_RABBITMQ_PASSWORD=Xinxibu1717...
    networks:
      servicenet: {}

networks:
  servicenet:
    external: true
```

------

## ✅ 验证是否成功

启动应用后，查看日志：

```
INFO  o.s.a.r.c.CachingConnectionFactory - Created new connection: ... SSL connection...
```

✅ 出现 `SSL connection` 表示 TLS 握手成功！

如果报错：

- `Unrecognized SSL message` → 客户端没开 SSL，或连错端口（5672 vs 5671）
- `unable to find valid certification path` → 证书不匹配或路径错误
- `Invalid keystore format` → 文件不是 JKS 格式，或密码错误

------

## 🔁 证书轮换怎么办？

1. 在宿主机重新生成 `truststore.jks`
2. 重启 Spring Boot 容器（无需重新打包镜像！）

```
# 重新生成
keytool -import -alias rabbitmq-ca -file ca.crt -keystore truststore.jks -storepass Xinxibu1717 -noprompt

# 重启应用
docker-compose restart your-springboot-app
```

------

## ✅ 最终目录结构

深色版本

```
/mnt/database/rabbitmq/
├── rabbitmq-certs/
│   ├── ca.crt          # 原始证书
│   ├── server.pem
│   └── truststore.jks  # 👈 专门为 Spring Boot 2.5.2 生成的
├── conf/
│   └── rabbitmq.conf
└── docker-compose.yml
```

------

## 🎯 总结

| 项目             | 配置                                                         |
| ---------------- | ------------------------------------------------------------ |
| Spring Boot 版本 | 2.5.2（较老）                                                |
| 证书格式支持     | 仅 JKS/PKCS12，不支持 PEM                                    |
| 解决方案         | 用 `keytool` 生成 `truststore.jks`                           |
| 配置方式         | `trust-store: file:/path`, `trust-store-type: JKS`, `trust-store-password: ...` |
| 证书管理         | 外部挂载，支持热更新                                         |

------





```shell
rabbitmq-certs/
-rw------- ca.crt     # ✅ CA 根证书（客户端信任用）
-rw------- ca.key     # ✅ CA 私钥（签发服务器证书用，不要外泄！）
-rw------- ca.srl     # ✅ CA 序列号文件（openssl 自动生成，用于签发证书时递增序列号）
-rw------- server.crt # ✅ 服务器证书（由 CA 签发）
-rw------- server.csr # ✅ 证书签名请求（可删除，不影响运行）
-rw------- server.key # ✅ 服务器私钥（必须保密！）
-rw------- server.pem # ✅ 合并文件（server.crt + server.key）→ RabbitMQ TLS 所需格式
-rw------- truststore.jks
cd /mnt/database/rabbitmq/rabbitmq-certs

# 设置所有证书文件为 rabbitmq 用户可读（UID 999）
sudo chown -R 999:999 .
sudo chmod 644 *.crt *.pem *.jks
sudo chmod 600 *.key  # 私钥保持严格权限
```