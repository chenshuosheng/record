# Nginx 目录浏览配置指南

## 启用目录浏览功能

### 基础配置

```
server {
    listen 80;
    server_name files.example.com;
    root /var/www/files;
    
    # 开启自动索引（目录浏览）
    autoindex on;
    
    # 以本地时间显示文件时间
    autoindex_localtime on;
    
    # 显示文件大小（on=字节，off=K/M/G）
    autoindex_exact_size off;
    
    # 设置字符编码
    charset utf-8;
}
```



### 完整配置示例

```
server {
    listen 80;
    server_name files.example.com;
    root /var/www/files;
    
    # 目录浏览配置
    autoindex on;
    autoindex_localtime on;
    autoindex_exact_size off;
    
    # 字符编码
    charset utf-8;
    
    # 索引文件名（当请求目录时按顺序查找）
    index index.html index.htm;
    
    # 访问日志
    access_log /var/log/nginx/files-access.log;
    error_log /var/log/nginx/files-error.log;
    
    location / {
        # 允许所有HTTP方法
        limit_except GET HEAD {
            deny all;
        }
        
        # 尝试查找索引文件，如果没有则显示目录列表
        try_files $uri $uri/ =404;
    }
    
    # 禁止访问隐藏文件
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # 特定文件类型处理
    location ~* \.(txt|md|log)$ {
        # 文本文件直接显示内容
        default_type text/plain;
        charset utf-8;
    }
}
```



## 自定义目录列表样式

### 使用自定义 HTML 模板

```
server {
    listen 80;
    server_name files.example.com;
    root /var/www/files;
    
    # 启用目录浏览
    autoindex on;
    
    # 使用自定义的 HTML 头部和脚部
    autoindex_format html;
    
    # 添加自定义头部（可选）
    add_before_body /nginx-index-header.html;
    add_after_body /nginx-index-footer.html;
    
    location / {
        # 这里不需要额外的配置
    }
}
```



### 创建自定义模板文件

```
<!-- /var/www/files/nginx-index-header.html -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>文件目录 - {{目录名}}</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .header {
            background: #2c3e50;
            color: white;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .file-list {
            background: white;
            border-radius: 5px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .file-item {
            display: flex;
            padding: 12px 20px;
            border-bottom: 1px solid #eee;
            text-decoration: none;
            color: #333;
        }
        .file-item:hover {
            background: #f8f9fa;
        }
        .file-name {
            flex: 1;
            font-weight: 500;
        }
        .file-size {
            width: 120px;
            text-align: right;
            color: #666;
        }
        .file-date {
            width: 200px;
            text-align: right;
            color: #888;
        }
        .folder {
            color: #3498db;
        }
        .folder:before {
            content: "📁 ";
        }
        .file {
            color: #7f8c8d;
        }
        .file:before {
            content: "📄 ";
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>📂 {{目录路径}}</h1>
        <p>最后更新: {{当前时间}}</p>
    </div>
    <div class="file-list">
```



```
<!-- /var/www/files/nginx-index-footer.html -->
    </div>
    <div style="text-align: center; margin-top: 20px; color: #777;">
        <p>由 Nginx {{nginx版本}} 提供支持 | 总文件数: {{文件计数}}</p>
    </div>
</body>
</html>
```



## JSON/XML 格式输出

### JSON 格式目录列表

```
server {
    listen 80;
    server_name api.example.com;
    root /var/www/api/files;
    
    # 启用目录浏览，输出JSON格式
    autoindex on;
    autoindex_format json;
    
    # 设置Content-Type为application/json
    location / {
        default_type application/json;
        charset utf-8;
        
        # 添加CORS头（如果通过API访问）
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods GET;
        
        # 压缩JSON响应
        gzip on;
        gzip_types application/json;
    }
}
```



### XML 格式目录列表

```
server {
    listen 80;
    server_name xml.example.com;
    root /var/www/xml/files;
    
    # 启用目录浏览，输出XML格式
    autoindex on;
    autoindex_format xml;
    
    location / {
        default_type application/xml;
        charset utf-8;
        
        # 添加XML声明
        add_header Content-Type 'application/xml; charset=utf-8';
    }
}
```



## 安全限制配置

### 基本认证保护

```
server {
    listen 80;
    server_name secure.example.com;
    root /var/www/secure;
    
    # 启用目录浏览
    autoindex on;
    
    # HTTP 基本认证
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    location / {
        # 允许的IP范围
        allow 192.168.1.0/24;
        allow 10.0.0.0/8;
        deny all;
        
        # 限制请求方法
        limit_except GET HEAD {
            deny all;
        }
    }
}
```



### 创建密码文件

```
# 安装htpasswd工具
sudo apt-get install apache2-utils  # Debian/Ubuntu
sudo yum install httpd-tools        # CentOS/RHEL

# 创建密码文件
sudo htpasswd -c /etc/nginx/.htpasswd username

# 添加更多用户（不使用-c参数）
sudo htpasswd /etc/nginx/.htpasswd anotheruser

# 查看用户列表
cat /etc/nginx/.htpasswd
```



### 基于令牌的访问控制

```
server {
    listen 80;
    server_name token.example.com;
    root /var/www/token;
    
    autoindex on;
    
    location / {
        # 检查访问令牌
        if ($arg_token != "my-secret-token-123") {
            return 403 "Access Denied";
        }
        
        # 或者使用自定义头部
        # if ($http_x_access_token != "secret-token") {
        #     return 403;
        # }
    }
}
```



## 高级功能配置

### 文件类型图标和描述

```
server {
    listen 80;
    server_name enhanced.example.com;
    root /var/www/enhanced;
    
    autoindex on;
    autoindex_localtime on;
    autoindex_exact_size off;
    
    # 自定义不同类型文件的显示
    location ~* \.(jpg|jpeg|png|gif|ico)$ {
        add_header X-File-Type "Image";
        add_header X-File-Icon "🖼️";
    }
    
    location ~* \.(pdf)$ {
        add_header X-File-Type "PDF Document";
        add_header X-File-Icon "📕";
    }
    
    location ~* \.(zip|tar|gz|rar)$ {
        add_header X-File-Type "Archive";
        add_header X-File-Icon "🗜️";
    }
    
    location ~* \.(mp4|avi|mov|mkv)$ {
        add_header X-File-Type "Video";
        add_header X-File-Icon "🎬";
    }
    
    location ~* \.(mp3|wav|flac)$ {
        add_header X-File-Type "Audio";
        add_header X-File-Icon "🎵";
    }
}
```



### 目录浏览与下载控制

```
server {
    listen 80;
    server_name download.example.com;
    root /var/www/downloads;
    
    autoindex on;
    
    # 允许预览的文件类型
    location ~* \.(txt|md|log|json|xml)$ {
        # 这些文件可以直接在浏览器中查看
        autoindex on;
        default_type text/plain;
    }
    
    # 强制下载的文件类型
    location ~* \.(exe|zip|tar|gz|deb|rpm|dmg)$ {
        autoindex off;
        add_header Content-Disposition 'attachment';
        add_header X-Content-Type-Options 'nosniff';
    }
    
    # 图片文件直接显示
    location ~* \.(jpg|jpeg|png|gif|svg|webp)$ {
        autoindex off;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```



### 搜索功能集成

```
server {
    listen 80;
    server_name search.example.com;
    root /var/www/search;
    
    autoindex on;
    
    location / {
        # 简单的搜索参数处理
        if ($arg_q) {
            # 这里可以集成外部搜索脚本
            # 例如使用 find 命令的结果
            # return 302 /search-results?q=$arg_q;
        }
    }
    
    # 搜索脚本端点
    location /search {
        # 调用外部脚本来处理搜索
        # fastcgi_pass unix:/var/run/search.sock;
        # 或 proxy_pass http://search-backend;
    }
}
```



## 性能优化配置

### 启用缓存和压缩

```
server {
    listen 80;
    server_name fast.example.com;
    root /var/www/fast;
    
    autoindex on;
    
    # 启用文件缓存
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    # 启用压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml;
    
    # 静态文件缓存
    location ~* \.(html|css|js)$ {
        expires 1h;
        add_header Cache-Control "public";
    }
    
    # 目录列表页面缓存
    location = / {
        expires 5m;
        add_header Cache-Control "public, must-revalidate";
    }
}
```



### 限制目录深度和大文件

```
server {
    listen 80;
    server_name limited.example.com;
    root /var/www/limited;
    
    autoindex on;
    
    # 限制目录遍历深度
    location ~ "^/.*/.*/.*/.*/.*/" {
        return 403 "Directory depth limit exceeded";
    }
    
    # 限制大文件显示
    location / {
        # 通过 Lua 脚本或外部程序过滤大文件
        # 这里只是一个概念示例
    }
    
    # 设置最大显示文件数
    set $max_files 1000;
    
    # 或者在外部脚本中处理分页
    location /browse {
        # 分页参数
        # page=$arg_page&per_page=$arg_per_page
    }
}
```



## 虚拟目录和别名

### 使用别名映射不同目录

```
server {
    listen 80;
    server_name alias.example.com;
    root /var/www/main;
    
    autoindex on;
    
    # 将 /downloads 映射到另一个目录
    location /downloads {
        alias /mnt/external/downloads;
        autoindex on;
        autoindex_localtime on;
        
        # 注意：alias 末尾不要加斜杠
    }
    
    # 将 /logs 映射到系统日志目录（只读）
    location /logs {
        alias /var/log;
        autoindex on;
        
        # 只允许读取日志文件
        location ~* \.(log|txt)$ {
            # 可以读取
        }
        
        location ~* \.(gz|bz2)$ {
            # 压缩日志也可以读取
        }
        
        # 禁止访问其他文件
        location ~ /\. {
            deny all;
        }
    }
}
```



### 多目录合并浏览

```
server {
    listen 80;
    server_name merge.example.com;
    
    # 没有根目录，使用多个 location 合并
    
    location /project-a {
        alias /var/www/project-a;
        autoindex on;
    }
    
    location /project-b {
        alias /var/www/project-b;
        autoindex on;
    }
    
    location /shared {
        alias /mnt/shared;
        autoindex on;
    }
    
    # 根目录显示所有项目的链接
    location = / {
        return 200 '
        <html>
        <body>
            <h1>Projects</h1>
            <ul>
                <li><a href="/project-a">Project A</a></li>
                <li><a href="/project-b">Project B</a></li>
                <li><a href="/shared">Shared Resources</a></li>
            </ul>
        </body>
        </html>';
        default_type text/html;
    }
}
```



## 错误处理和美化

### 自定义错误页面

```
server {
    listen 80;
    server_name error.example.com;
    root /var/www/errors;
    
    autoindex on;
    
    # 自定义404页面（当目录不存在时）
    error_page 404 /404.html;
    location = /404.html {
        internal;
    }
    
    # 自定义403页面（当访问被拒绝时）
    error_page 403 /403.html;
    location = /403.html {
        internal;
    }
    
    # 禁止列出某些目录
    location /private {
        autoindex off;
        return 403;
    }
    
    # 优雅地处理不存在的方法
    if ($request_method !~ ^(GET|HEAD)$ ) {
        return 405;
    }
    
    error_page 405 /405.html;
    location = /405.html {
        internal;
    }
}
```



### 创建错误页面

```
<!-- /var/www/errors/404.html -->
<!DOCTYPE html>
<html>
<head>
    <title>404 - Directory Not Found</title>
    <style>
        body { font-family: sans-serif; text-align: center; padding: 50px; }
        h1 { color: #e74c3c; }
        .back-link { margin-top: 20px; }
    </style>
</head>
<body>
    <h1>📁 目录未找到</h1>
    <p>请求的目录不存在或已被移动。</p>
    <p><a href="/">返回首页</a></p>
</body>
</html>
```



## 监控和日志

### 详细的访问日志

```
server {
    listen 80;
    server_name logs.example.com;
    root /var/www/logs;
    
    autoindex on;
    
    # 详细的日志格式
    log_format dir_log '$remote_addr - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent" '
                      '"$request_filename" "$document_root"';
    
    access_log /var/log/nginx/directory-access.log dir_log;
    
    # 单独记录下载日志
    location ~* \.(zip|tar|gz|exe|dmg)$ {
        access_log /var/log/nginx/downloads.log dir_log;
    }
}
```



### 实时监控配置

```
server {
    listen 80;
    server_name stats.example.com;
    root /var/www/stats;
    
    autoindex on;
    
    # Nginx 状态页面
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow 192.168.1.0/24;
        deny all;
    }
    
    # 实时文件系统监控（需要第三方模块或外部脚本）
    location /fs-stats {
        # 调用外部脚本获取文件系统统计信息
        # fastcgi_pass unix:/var/run/fs-stats.sock;
    }
}
```



## Docker 容器配置

### Dockerfile 示例

```
FROM nginx:alpine

# 创建目录结构
RUN mkdir -p /var/www/files && \
    mkdir -p /etc/nginx/snippets

# 复制配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY sites-enabled/ /etc/nginx/sites-enabled/

# 复制自定义模板
COPY index-header.html /var/www/files/nginx-index-header.html
COPY index-footer.html /var/www/files/nginx-index-footer.html

# 设置权限
RUN chown -R nginx:nginx /var/www/files && \
    chmod -R 755 /var/www/files

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
```



### docker-compose.yml 示例

```
version: '3.8'

services:
  nginx-files:
    image: nginx:alpine
    container_name: nginx-file-browser
    restart: unless-stopped
    ports:
      - "8080:80"
    volumes:
      # 配置文件
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./sites-enabled:/etc/nginx/sites-enabled:ro
      # 数据目录
      - /path/to/your/files:/var/www/files:ro
      # 日志目录
      - ./logs:/var/log/nginx
    environment:
      - TZ=Asia/Shanghai
    networks:
      - webnet

networks:
  webnet:
    driver: bridge
```



## 最佳实践总结

### 安全建议

1. **不要在生产环境启用目录浏览**，除非必要
2. **使用认证机制**保护敏感目录
3. **限制访问IP范围**
4. **禁用对系统目录的访问**
5. **定期审计访问日志**

### 性能建议

1. **启用缓存**减少重复生成目录列表
2. **使用压缩**减少传输数据量
3. **限制目录深度**避免性能问题
4. **考虑分页**处理大量文件

### 维护建议

1. **定期清理**不再需要的文件
2. **监控磁盘使用**情况
3. **备份重要配置**
4. **测试配置变更**在生产环境前

### 完整的生产配置示例

```
# /etc/nginx/sites-available/file-browser
server {
    listen 80;
    server_name files.company.com;
    
    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name files.company.com;
    
    # SSL配置
    ssl_certificate /etc/ssl/certs/company.com.crt;
    ssl_certificate_key /etc/ssl/private/company.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # 安全头部
    add_header Strict-Transport-Security "max-age=31536000" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    
    # 基础认证
    auth_basic "Company File Browser";
    auth_basic_user_file /etc/nginx/.htpasswd;
    
    # 允许的内部IP
    satisfy any;
    allow 10.0.0.0/8;
    allow 192.168.0.0/16;
    deny all;
    
    # 文件目录配置
    root /var/www/company/files;
    
    # 目录浏览配置
    autoindex on;
    autoindex_localtime on;
    autoindex_exact_size off;
    
    # 字符编码
    charset utf-8;
    
    # 默认索引文件
    index index.html index.htm README.md;
    
    # 日志配置
    access_log /var/log/nginx/file-browser-access.log json_combined;
    error_log /var/log/nginx/file-browser-error.log warn;
    
    location / {
        # 只允许GET和HEAD方法
        limit_except GET HEAD {
            deny all;
        }
        
        # 尝试索引文件，然后目录列表
        try_files $uri $uri/ =404;
        
        # 文件缓存
        open_file_cache max=1000 inactive=20s;
        open_file_cache_valid 30s;
    }
    
    # 隐藏文件保护
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    # 禁止访问上级目录
    location ~ "\.\." {
        deny all;
    }
    
    # 特定文件类型处理
    location ~* \.(txt|md|log)$ {
        default_type text/plain;
    }
    
    location ~* \.(zip|tar|gz)$ {
        add_header Content-Disposition 'attachment';
    }
    
    # 错误页面
    error_page 404 /404.html;
    error_page 403 /403.html;
    location = /404.html {
        internal;
    }
    location = /403.html {
        internal;
    }
}
```



通过以上配置，您可以建立一个安全、高效、可维护的 Nginx 目录浏览服务。根据实际需求调整配置参数，确保符合安全策略和性能要求。