# Nginx 使用文档

## 目录

1. 概述
2. 安装与部署
3. 配置文件结构
4. 核心配置指令
5. 虚拟主机配置
6. HTTPS配置
7. 负载均衡
8. 缓存配置
9. 安全配置
10. 性能优化
11. 日志管理
12. 常见问题
13. 附录

------

## 概述

### 什么是 Nginx？

Nginx（发音为 "engine-x"）是一款高性能的 HTTP 和反向代理服务器，也是一个 IMAP/POP3/SMTP 代理服务器。它以高并发、低内存占用和模块化架构著称。

### 主要特性

- **高性能**：事件驱动、异步非阻塞架构
- **反向代理**：支持负载均衡和故障转移
- **静态文件服务**：高效处理静态内容
- **SSL/TLS 终端**：支持 HTTPS 终止
- **WebSocket 支持**：全双工通信协议
- **Gzip 压缩**：减少传输数据量
- **访问控制**：基于 IP、密码等
- **URL 重写**：强大的 rewrite 模块
- **缓存功能**：代理缓存、FastCGI 缓存

### 应用场景

- Web 服务器
- 反向代理和负载均衡器
- API 网关
- 静态资源服务器
- 媒体流服务器
- 邮件代理服务器

------

## 安装与部署

### Ubuntu/Debian

```
# 更新包列表
sudo apt update

# 安装 Nginx
sudo apt install nginx

# 启动 Nginx
sudo systemctl start nginx

# 设置开机自启
sudo systemctl enable nginx

# 检查状态
sudo systemctl status nginx
```



### CentOS/RHEL

```
# 添加 EPEL 仓库
sudo yum install epel-release

# 安装 Nginx
sudo yum install nginx

# 启动 Nginx
sudo systemctl start nginx

# 设置开机自启
sudo systemctl enable nginx
```



### 从源码编译安装

```
# 下载源码
wget http://nginx.org/download/nginx-1.24.0.tar.gz
tar -zxvf nginx-1.24.0.tar.gz
cd nginx-1.24.0

# 配置编译选项
./configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_gzip_static_module

# 编译安装
make
sudo make install
```



### Docker 部署

```
# 拉取官方镜像
docker pull nginx:latest

# 运行容器
docker run -d \
    --name my-nginx \
    -p 80:80 \
    -p 443:443 \
    -v /path/to/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v /path/to/html:/usr/share/nginx/html:ro \
    nginx
```



### 验证安装





```
# 检查版本
nginx -v
nginx version: nginx/1.24.0

# 测试配置文件
nginx -t
nginx: configuration file /etc/nginx/nginx.conf test is successful

# 检查编译模块
nginx -V
```



------

## 配置文件结构

### 默认配置文件位置

```
/etc/nginx/
├── nginx.conf              # 主配置文件
├── conf.d/                 # 额外的配置文件
├── sites-available/        # 可用的虚拟主机配置
├── sites-enabled/          # 启用的虚拟主机配置（符号链接）
├── modules-available/      # 可用模块配置
├── modules-enabled/        # 启用模块配置
└── snippets/               # 可重用的配置片段
```



### nginx.conf 结构示例

```
# 全局块 - 影响 Nginx 整体运行的配置
user www-data;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Events 块 - 影响 Nginx 服务器与用户的网络连接
events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

# HTTP 块 - 代理、缓存、日志等配置
http {
    # HTTP 全局配置
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # 基本设置
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml;
    
    # 包含其他配置
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```



### 配置文件层次结构

```
nginx.conf (主配置文件)
    ├── http { ... } (HTTP 上下文)
    │   ├── server { ... } (虚拟主机)
    │   │   ├── location / { ... }
    │   │   ├── location /api/ { ... }
    │   │   └── location ~ \.php$ { ... }
    │   └── upstream { ... } (上游服务器)
    └── events { ... } (事件模型)
```



------

## 核心配置指令

### 全局配置指令

```
# 运行用户和组
user nginx nginx;

# 工作进程数（建议设置为 CPU 核心数）
worker_processes auto;

# 错误日志位置和级别
error_log /var/log/nginx/error.log warn;
# 级别：debug, info, notice, warn, error, crit

# PID 文件位置
pid /var/run/nginx.pid;

# 工作进程可以打开的最大文件描述符数
worker_rlimit_nofile 65535;
```



### Events 块指令

```
events {
    # 每个工作进程的最大连接数
    worker_connections 1024;
    
    # 使用的事件模型（Linux 推荐 epoll）
    use epoll;
    
    # 是否同时接受多个连接
    multi_accept on;
    
    # 优化 keep-alive 连接
    accept_mutex_delay 100ms;
}
```



### HTTP 块常用指令

```
http {
    # MIME 类型
    include mime.types;
    default_type application/octet-stream;
    
    # 日志配置
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    
    # 文件传输优化
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # 连接超时设置
    keepalive_timeout 65;
    client_header_timeout 15;
    client_body_timeout 15;
    send_timeout 25;
    
    # 客户端限制
    client_max_body_size 100m;
    client_body_buffer_size 128k;
    
    # 代理相关
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
    proxy_buffer_size 4k;
    proxy_buffers 4 32k;
    proxy_busy_buffers_size 64k;
}
```



------

## 虚拟主机配置

### 基本 HTTP 服务器

```
server {
    listen 80;
    server_name example.com www.example.com;
    
    # 根目录和索引文件
    root /var/www/example.com;
    index index.html index.htm;
    
    # 访问日志
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;
    
    # 默认 location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # 静态文件缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # 禁止访问隐藏文件
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```



### 多站点配置模式

```
# 方式1：每个站点单独文件（推荐）
# /etc/nginx/sites-available/example.com
# /etc/nginx/sites-enabled/example.com（符号链接）

# 创建站点配置
sudo nano /etc/nginx/sites-available/example.com

# 启用站点（创建符号链接）
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/

# 方式2：在一个文件中配置多个 server 块
server {
    listen 80;
    server_name site1.com;
    root /var/www/site1;
    # ...
}

server {
    listen 80;
    server_name site2.com;
    root /var/www/site2;
    # ...
}
```



### Location 块匹配规则

```
# 精确匹配（最高优先级）
location = /exact-path {
    # 仅匹配 /exact-path
}

# 前缀匹配
location /prefix/ {
    # 匹配以 /prefix/ 开头的所有 URL
}

# 正则表达式匹配（区分大小写）
location ~ \.php$ {
    # 匹配以 .php 结尾的 URL
}

# 正则表达式匹配（不区分大小写）
location ~* \.(jpg|jpeg|png|gif)$ {
    # 匹配图片文件，不区分大小写
}

# 最长前缀匹配
location ^~ /static/ {
    # 优先于正则匹配，匹配以 /static/ 开头的 URL
}

# 通用匹配
location / {
    # 匹配所有未匹配的请求
}
```



### PHP-FPM 配置

```
server {
    listen 80;
    server_name example.com;
    root /var/www/example.com;
    index index.php index.html index.htm;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        # 安全设置：避免执行不存在的 PHP 文件
        try_files $uri =404;
        
        # 分割路径信息
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        
        # PHP-FPM 配置
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        
        # 包含默认的 FastCGI 参数
        include fastcgi_params;
        
        # 超时设置
        fastcgi_read_timeout 300;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        
        # 缓冲区设置
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }
    
    # 禁止访问敏感文件
    location ~ /\.(ht|git|svn) {
        deny all;
    }
}
```



------

## HTTPS配置

### 基础 SSL 配置

```
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # SSL 证书路径
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    
    # SSL 会话缓存
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
    
    # 安全头部
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # 根目录配置
    root /var/www/example.com;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```



### HTTP 重定向到 HTTPS

```
server {
    listen 80;
    server_name example.com www.example.com;
    
    # 301 永久重定向到 HTTPS
    return 301 https://$server_name$request_uri;
    
    # 或者使用 rewrite
    # rewrite ^ https://$server_name$request_uri permanent;
}
```



### 使用 Let's Encrypt 自动 SSL

```
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d example.com -d www.example.com

# 自动续期测试
sudo certbot renew --dry-run

# Certbot 生成的配置示例
server {
    listen 443 ssl;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
```



### SSL 性能优化

```
http {
    # SSL 优化配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # HSTS 预加载
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
    
    # SSL 会话重用
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    
    # 启用 TLS 1.3 0-RTT
    ssl_early_data on;
}
```



------

## 负载均衡

### 负载均衡算法

```
upstream backend_servers {
    # 轮询（默认）
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
    server 192.168.1.103:8080;
}

upstream weighted_backend {
    # 加权轮询
    server 192.168.1.101:8080 weight=3;
    server 192.168.1.102:8080 weight=2;
    server 192.168.1.103:8080 weight=1;
}

upstream ip_hash_backend {
    # IP 哈希（会话保持）
    ip_hash;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}

upstream least_conn_backend {
    # 最少连接数
    least_conn;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}
```



### 负载均衡配置示例

```
http {
    upstream myapp {
        # 健康检查
        server 192.168.1.101:8080 max_fails=3 fail_timeout=30s;
        server 192.168.1.102:8080 max_fails=3 fail_timeout=30s;
        server 192.168.1.103:8080 max_fails=3 fail_timeout=30s backup;
        
        # 会话保持
        sticky cookie srv_id expires=1h domain=.example.com path=/;
    }
    
    server {
        listen 80;
        server_name app.example.com;
        
        location / {
            proxy_pass http://myapp;
            
            # 代理头部
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # 超时设置
            proxy_connect_timeout 5s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # 缓冲区
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
            
            # 重试机制
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_next_upstream_tries 3;
        }
    }
}
```



### 健康检查配置

```
upstream backend {
    zone backend 64k;
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
    
    # 主动健康检查
    health_check interval=5s fails=3 passes=2 uri=/health;
}

# 或者使用第三方模块 ngx_http_upstream_hc_module
location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
}
```



### WebSocket 负载均衡

```
upstream websocket_backend {
    server 192.168.1.101:8080;
    server 192.168.1.102:8080;
}

server {
    listen 80;
    server_name ws.example.com;
    
    location / {
        proxy_pass http://websocket_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        
        # WebSocket 超时设置
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}
```



------

## 缓存配置

### 代理缓存

```
http {
    # 缓存路径和配置
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m 
                    inactive=60m use_temp_path=off max_size=1g;
    
    # 缓存清理 map
    map $request_method $purge_method {
        PURGE 1;
        default 0;
    }
    
    server {
        listen 80;
        server_name example.com;
        
        # 缓存清理端点
        location ~ /purge(/.*) {
            allow 127.0.0.1;
            allow 192.168.1.0/24;
            deny all;
            
            proxy_cache_purge my_cache "$scheme$request_method$host$1";
        }
        
        location / {
            proxy_pass http://backend;
            proxy_cache my_cache;
            
            # 缓存键
            proxy_cache_key "$scheme$request_method$host$request_uri";
            
            # 缓存条件
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_valid any 5m;
            
            # 缓存绕过条件
            proxy_cache_bypass $http_cache_control;
            proxy_no_cache $http_pragma $http_authorization;
            
            # 添加缓存状态头
            add_header X-Cache-Status $upstream_cache_status;
            
            # 锁定防止缓存击穿
            proxy_cache_lock on;
            proxy_cache_lock_age 5s;
            proxy_cache_lock_timeout 5s;
            
            # 缓存重新验证
            proxy_cache_revalidate on;
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        }
    }
}
```



### FastCGI 缓存（PHP）

```
http {
    fastcgi_cache_path /var/cache/nginx/fastcgi 
                      levels=1:2 
                      keys_zone=phpcache:100m 
                      inactive=60m 
                      max_size=1g;
    
    server {
        listen 80;
        server_name phpapp.example.com;
        root /var/www/phpapp;
        
        location ~ \.php$ {
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            
            # FastCGI 缓存配置
            fastcgi_cache phpcache;
            fastcgi_cache_key "$scheme$request_method$host$request_uri";
            fastcgi_cache_valid 200 302 10m;
            fastcgi_cache_valid 404 1m;
            
            # 缓存控制
            fastcgi_cache_bypass $no_cache;
            fastcgi_no_cache $no_cache;
            
            # 缓存状态头
            add_header X-FastCGI-Cache $upstream_cache_status;
            
            # 缓存锁定
            fastcgi_cache_lock on;
            fastcgi_cache_lock_timeout 5s;
        }
        
        # 绕过缓存的规则
        set $no_cache 0;
        
        # POST 请求不缓存
        if ($request_method = POST) {
            set $no_cache 1;
        }
        
        # 带查询参数的 URL 不缓存
        if ($query_string != "") {
            set $no_cache 1;
        }
    }
}
```



### 浏览器缓存控制

```
server {
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Pragma "public";
        
        # 启用 Etag
        etag on;
        
        # 文件变化时自动更新
        if_modified_since exact;
    }
    
    location ~* \.(html|htm)$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }
    
    # API 响应通常不缓存
    location /api/ {
        add_header Cache-Control "no-store, no-cache, must-revalidate";
        expires 0;
    }
}
```



------

## 安全配置

### 基础安全配置

```
http {
    # 隐藏 Nginx 版本号
    server_tokens off;
    
    # 禁用无效方法
    if ($request_method !~ ^(GET|HEAD|POST|PUT|PATCH|DELETE|OPTIONS)$ ) {
        return 405;
    }
    
    # 限制请求类型
    limit_except GET POST {
        deny all;
    }
}
```



### 防止常见攻击

```
server {
    # 防止点击劫持
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # 防止 MIME 类型嗅探
    add_header X-Content-Type-Options "nosniff" always;
    
    # 启用 XSS 保护
    add_header X-XSS-Protection "1; mode=block" always;
    
    # 内容安全策略
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.example.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;" always;
    
    # 引用策略
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # 权限策略
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
}
```



### 速率限制

```
http {
    # 限制区域定义
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;
    
    # 连接数限制
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    
    server {
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            limit_conn addr 10;
            
            proxy_pass http://backend;
        }
        
        location /auth/ {
            limit_req zone=auth burst=5 nodelay;
            
            proxy_pass http://auth_backend;
        }
        
        # 静态文件不限制
        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
            limit_req off;
            limit_conn off;
        }
    }
}
```



### 访问控制

```
server {
    # 基于 IP 的访问控制
    location /admin/ {
        allow 192.168.1.0/24;
        allow 10.0.0.1;
        deny all;
        
        # HTTP 基本认证
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
    
    # 防止目录遍历
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # 阻止特定用户代理
    if ($http_user_agent ~* (wget|curl|scanner|bot|crawl)) {
        return 403;
    }
    
    # 限制文件上传大小
    client_max_body_size 10m;
    
    # 防止缓冲区溢出攻击
    client_body_buffer_size 1k;
    client_header_buffer_size 1k;
    large_client_header_buffers 2 1k;
}
```



### SSL 安全配置

```
server {
    listen 443 ssl http2;
    
    # 仅支持安全协议
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # 现代加密套件
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
    
    # 禁用旧的不安全加密套件
    ssl_ciphers '!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4';
    
    # 启用 SSL 会话票证
    ssl_session_tickets off;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
    # 启用 OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
}
```



------

## 性能优化

### 连接优化

```
http {
    # TCP 优化
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # 连接保持
    keepalive_timeout 65;
    keepalive_requests 100;
    
    # 重置超时连接
    reset_timedout_connection on;
    
    # 启用套接字选项
    socket_keepalive on;
}
```



### 缓冲区优化

```
http {
    # 客户端缓冲区
    client_body_buffer_size 16k;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 4 8k;
    
    # 代理缓冲区
    proxy_buffers 8 16k;
    proxy_buffer_size 16k;
    proxy_busy_buffers_size 32k;
    
    # FastCGI 缓冲区
    fastcgi_buffers 8 16k;
    fastcgi_buffer_size 32k;
    
    # 输出缓冲区
    output_buffers 1 32k;
    postpone_output 1460;
}
```



### Gzip 压缩优化

```
http {
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 256;
    gzip_types
        application/atom+xml
        application/javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rss+xml
        application/vnd.geo+json
        application/vnd.ms-fontobject
        application/x-font-ttf
        application/x-web-app-manifest+json
        application/xhtml+xml
        application/xml
        font/opentype
        image/bmp
        image/svg+xml
        image/x-icon
        text/cache-manifest
        text/css
        text/plain
        text/vcard
        text/vnd.rim.location.xloc
        text/vtt
        text/x-component
        text/x-cross-domain-policy;
    
    # 禁用旧浏览器的压缩
    gzip_disable "msie6";
    
    # Brotli 压缩（如果可用）
    # brotli on;
    # brotli_comp_level 6;
    # brotli_types text/plain text/css application/json application/javascript text/xml;
}
```



### 静态文件服务优化

```
server {
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        # 启用 sendfile
        sendfile on;
        sendfile_max_chunk 1m;
        
        # 启用直接IO
        directio 4m;
        directio_alignment 512;
        
        # 启用异步文件IO
        aio on;
        aio_write on;
        
        # 启用文件缓存
        open_file_cache max=1000 inactive=30s;
        open_file_cache_valid 60s;
        open_file_cache_min_uses 2;
        open_file_cache_errors on;
        
        # 过期时间
        expires 1y;
        add_header Cache-Control "public, immutable";
        
        # 启用 Etag
        etag on;
    }
}
```



### 工作进程优化

```
# 根据 CPU 核心数设置工作进程
worker_processes auto;

# 设置 CPU 亲和性（Linux）
worker_cpu_affinity auto;

# 调整工作进程优先级
worker_priority -5;

# 限制核心转储大小
worker_rlimit_core 0;

events {
    # 使用高效的事件模型
    use epoll;
    
    # 工作进程连接数
    worker_connections 2048;
    
    # 多连接接受
    multi_accept on;
    
    # 接受互斥锁延迟
    accept_mutex_delay 100ms;
}
```



------

## 日志管理

### 日志格式定义

```
http {
    # 主日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    '$request_time $upstream_response_time';
    
    # JSON 格式日志
    log_format json_combined escape=json
                    '{'
                    '"time_local":"$time_local",'
                    '"remote_addr":"$remote_addr",'
                    '"remote_user":"$remote_user",'
                    '"request":"$request",'
                    '"status":$status,'
                    '"body_bytes_sent":$body_bytes_sent,'
                    '"request_time":$request_time,'
                    '"http_referer":"$http_referer",'
                    '"http_user_agent":"$http_user_agent",'
                    '"http_x_forwarded_for":"$http_x_forwarded_for"'
                    '}';
    
    # 访问日志
    access_log /var/log/nginx/access.log main;
    access_log /var/log/nginx/access.json json_combined;
    
    # 错误日志
    error_log /var/log/nginx/error.log warn;
    
    # 条件日志记录
    map $status $loggable {
        ~^[23]  0;  # 2xx 和 3xx 不记录
        default 1;  # 其他状态码记录
    }
}
```



### 日志轮转配置

```
# /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 nginx adm
    sharedscripts
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
```



### 日志分析示例

```
# 按虚拟主机分离日志
server {
    server_name app1.example.com;
    access_log /var/log/nginx/app1.access.log main;
    error_log /var/log/nginx/app1.error.log;
}

server {
    server_name app2.example.com;
    access_log /var/log/nginx/app2.access.log main;
    error_log /var/log/nginx/app2.error.log;
}

# 禁用特定位置的日志
location /health {
    access_log off;
    error_log off;
}

# 仅记录错误请求
location / {
    access_log /var/log/nginx/error_only.log main if=$loggable;
}
```



------

## 常见问题

### 1. 502 Bad Gateway 错误

```
# 可能原因和解决方案
# 1. 后端服务未运行
# 2. 代理设置错误
# 3. 超时设置太短

location / {
    proxy_pass http://backend;
    
    # 增加超时时间
    proxy_connect_timeout 30s;
    proxy_send_timeout 30s;
    proxy_read_timeout 30s;
    
    # 添加错误处理
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_next_upstream_tries 3;
}
```



### 2. 413 Request Entity Too Large

```
# 增加客户端最大 body 大小
http {
    client_max_body_size 100m;
    
    # 或者针对特定位置
    server {
        location /upload {
            client_max_body_size 500m;
        }
    }
}
```



### 3. 404 Not Found

```
# 检查 try_files 配置
location / {
    # 正确的顺序
    try_files $uri $uri/ /index.php?$query_string;
    
    # 或者
    try_files $uri $uri/ =404;
}
```



### 4. 性能问题排查

```
# 检查配置
nginx -t

# 检查错误日志
tail -f /var/log/nginx/error.log

# 监控连接状态
netstat -an | grep :80 | wc -l

# 查看工作进程
ps aux | grep nginx

# 实时监控
ngxtop
```



### 5. 常用调试命令

```
# 测试配置
sudo nginx -t

# 重新加载配置（不中断服务）
sudo nginx -s reload

# 重新打开日志文件
sudo nginx -s reopen

# 优雅停止
sudo nginx -s quit

# 强制停止
sudo nginx -s stop

# 查看编译参数
nginx -V
```



------

## 附录

### Nginx 内置变量

```
$args               # 请求中的参数
$binary_remote_addr # 二进制形式的客户端地址
$body_bytes_sent    # 发送给客户端的字节数
$content_length     # Content-Length 请求头字段
$content_type       # Content-Type 请求头字段
$document_root      # 当前请求的文档根目录
$document_uri       # 当前请求的 URI
$host               # 请求的主机名
$http_user_agent    # 用户代理字符串
$http_referer       # 引用页面
$remote_addr        # 客户端 IP 地址
$remote_port        # 客户端端口
$remote_user        # 基本认证的用户名
$request            # 完整的请求行
$request_body       # 请求体
$request_filename   # 请求的文件路径
$request_method     # 请求方法
$request_uri        # 完整的请求 URI
$scheme             # 请求方案（http/https）
$server_addr        # 服务器地址
$server_name        # 服务器名称
$server_port        # 服务器端口
$server_protocol    # 服务器协议
$status             # 响应状态码
$time_local         # 本地时间
```



### 常用状态码

```
200 OK                    # 成功
301 Moved Permanently     # 永久重定向
302 Found                # 临时重定向
304 Not Modified         # 未修改
400 Bad Request          # 错误请求
401 Unauthorized         # 未授权
403 Forbidden            # 禁止访问
404 Not Found            # 未找到
405 Method Not Allowed   # 方法不允许
408 Request Timeout      # 请求超时
413 Request Too Large    # 请求体太大
500 Internal Server Error # 服务器内部错误
502 Bad Gateway          # 错误的网关
503 Service Unavailable  # 服务不可用
504 Gateway Timeout      # 网关超时
```



### 配置文件检查清单

- 语法检查：`nginx -t`

- 文件权限检查

- 日志文件位置和权限

- SSL 证书路径和权限

- 防火墙端口开放

- SELinux/AppArmor 配置

- 系统资源限制（ulimit）

- 备份原始配置文件

  

### 监控和指标

```
# 启用状态模块
location /nginx_status {
    stub_status on;
    access_log off;
    allow 127.0.0.1;
    deny all;
}

# 输出示例
Active connections: 291
server accepts handled requests
 16630948 16630948 31070465
Reading: 6 Writing: 179 Waiting: 106
```



### 性能测试工具

```
# 使用 ab（Apache Benchmark）
ab -n 1000 -c 100 http://example.com/

# 使用 wrk
wrk -t12 -c400 -d30s http://example.com/

# 使用 siege
siege -c 100 -t 1m http://example.com/

# 使用 htop 监控资源
htop
```



### 推荐阅读

- [Nginx 官方文档](http://nginx.org/en/docs/)
- [Nginx 配置生成器](https://www.digitalocean.com/community/tools/nginx)
- [SSL Labs 测试](https://www.ssllabs.com/ssltest/)
- [Mozilla SSL 配置生成器](https://ssl-config.mozilla.org/)

------

## 总结

本文档涵盖了 Nginx 的主要配置和使用场景，包括：

1. **基础配置**：安装、配置文件结构、核心指令
2. **虚拟主机**：多站点配置、location 匹配规则
3. **安全配置**：SSL/TLS、访问控制、防护措施
4. **性能优化**：缓存、压缩、连接优化
5. **负载均衡**：多种算法、健康检查
6. **运维管理**：日志、监控、故障排查

Nginx 的配置灵活而强大，建议根据实际需求选择合适的配置，并始终遵循以下最佳实践：

- **测试配置**：修改前备份，修改后测试
- **最小权限**：遵循最小权限原则
- **安全更新**：定期更新 Nginx 和系统
- **监控告警**：设置监控和日志分析
- **文档记录**：记录配置变更和原因

根据具体应用场景，可能需要调整配置参数以达到最佳性能和安全效果。