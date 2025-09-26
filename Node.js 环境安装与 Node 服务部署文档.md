# Node.js 环境安装与 Node 服务部署文档

## 环境信息

- 操作系统：CentOS/Linux
- Node.js 版本：v16.20.2
- 架构：linux-arm64
- 进程管理工具：PM2 v6.0.10



## 1. 准备工作

### 1.1 下载 Node.js 安装包

```
# 下载 Node.js v16.20.2 Linux ARM64 版本
wget https://nodejs.org/dist/v16.20.2/node-v16.20.2-linux-arm64.tar.xz

# 或者直接使用下载好的安装包
# 安装包位置：/opt/yclData/tools/node/node-v16.20.2-linux-arm64.tar.xz
```



### 1.2 准备 PM2 安装包（可选方案）

如果需要从现有环境提取 PM2，可以使用以下方法：

#### 方案一：从现有 Node.js 环境提取 PM2

```
# 进入 Node.js 安装目录
cd /root/.nvm/versions/node/v16.20.2

# 创建排除列表文件
cat > exclude-list.txt << EOF
bin/node
bin/npm
bin/npx
*.node
EOF

# 打包 PM2 相关文件
tar -czf pm2-safe.tar.gz -X exclude-list.txt lib/node_modules/pm2/ bin/pm2*

# 验证打包内容
tar -tzf pm2-safe.tar.gz
```



#### 方案二：使用 npm 在线安装 PM2

```
# 使用 npm 全局安装 PM2
npm install -g pm2

# 或者使用特定版本
npm install -g pm2@6.0.10
```



### 1.3 检查现有目录结构

```
# 进入数据目录
cd /opt/yclData

# 查看目录结构
ll -a

# 整理安装文件（如需要）
mv node/ tools/
```



## 2. Node.js 环境安装

### 2.1 解压安装 Node.js

```
# 进入安装文件目录
cd /opt/yclData/tools/node

# 解压 Node.js 安装包到 /usr/local 目录
sudo tar -xJf node-v16.20.2-linux-arm64.tar.xz -C /usr/local/

# 重命名目录为 nodejs
sudo mv /usr/local/node-v16.20.2-linux-arm64 /usr/local/nodejs
```



### 2.2 配置环境变量

```
# 查看当前 bashrc 配置
cat ~/.bashrc

# 添加 Node.js 环境变量
echo 'export PATH=/usr/local/nodejs/bin:$PATH' >> ~/.bashrc

# 使环境变量生效
source ~/.bashrc

# 验证环境变量
echo $PATH
```



### 2.3 验证安装

```
# 检查 Node.js 版本
node -v
# 预期输出：v16.20.2

# 检查 npm 版本
npm -v
# 预期输出：8.19.4

# 检查 npx 版本
npx -v
# 预期输出：8.19.4
```



### 2.4 创建软链接（可选，推荐）

```
# 创建全局软链接，方便直接调用
sudo ln -sf /usr/local/nodejs/bin/node /usr/local/bin/node
sudo ln -sf /usr/local/nodejs/bin/npm /usr/local/bin/npm
sudo ln -sf /usr/local/nodejs/bin/npx /usr/local/bin/npx

# 验证软链接
ls -la /usr/local/bin/node
ls -la /usr/local/bin/npm
ls -la /usr/local/bin/npx
```



## 3. PM2 进程管理工具安装

### 3.1 安装 PM2（多种方案可选）

#### 方案一：使用打包的 PM2 文件（从其他服务器复制（如果已有环境））

```
# 从源服务器复制 PM2 相关文件
scp root@源服务器IP:/root/.nvm/versions/node/v16.20.2/pm2-safe.tar.gz /opt/yclData/tools/node/

# 进入 Node.js 安装文件目录
cd /opt/yclData/tools/node

# 解压 PM2 到 Node.js 目录
tar -xzf pm2-safe.tar.gz -C /usr/local/nodejs/

# 验证安装
ls -la /usr/local/nodejs/bin/pm2*
```



#### 方案二：使用 npm 安装

```
# 设置 npm 镜像（国内服务器推荐）
npm config set registry https://registry.npmmirror.com

# 全局安装 PM2
npm install -g pm2

# 安装特定版本
npm install -g pm2@6.0.10
```



### 3.2 创建 PM2 软链接

```
# 创建 PM2 全局软链接
sudo ln -sf /usr/local/nodejs/bin/pm2 /usr/local/bin/pm2
sudo ln -sf /usr/local/nodejs/bin/pm2-dev /usr/local/bin/pm2-dev
sudo ln -sf /usr/local/nodejs/bin/pm2-docker /usr/local/bin/pm2-docker
sudo ln -sf /usr/local/nodejs/bin/pm2-runtime /usr/local/bin/pm2-runtime

# 验证软链接
ls -la /usr/local/bin/pm2*
```



### 3.3 验证 PM2 安装

```
# 检查 PM2 版本
pm2 --version
# 预期输出：6.0.10

# 查看 PM2 进程列表（初始应为空）
pm2 list

# 查看 PM2 帮助信息
pm2 --help
```



## 4. Node 服务部署

### 4.1 准备服务目录

```
# 进入 Node 服务目录
cd /home/4.5/nodeService

# 查看服务文件结构
ll -a

# 检查关键文件是否存在
ls -la package.json
ls -la ecosystem.config.js
ls -la .env
```



### 4.2 安装项目依赖

```
# 进入项目目录
cd /home/4.5/nodeService

# 安装项目依赖（如果 node_modules 不存在）
npm install

# 或者使用 ci 命令安装（推荐用于生产环境）
npm ci
```



### 4.3 启动 Node 服务

```
# 使用 PM2 启动服务（基于 ecosystem.config.js 配置）
pm2 start ecosystem.config.js

# 查看服务状态
pm2 list

# 查看详细服务信息
pm2 show node-service
```



### 4.4 配置 PM2 开机自启

```
# 保存当前进程列表
pm2 save

# 设置 PM2 开机自启（systemd 系统）
pm2 startup

# 对于非 root 用户，可能需要指定用户
# pm2 startup systemd -u username --hp /home/username

# 确认服务配置
systemctl status pm2-root

# 启用系统服务
systemctl enable pm2-root
```



## 5. 服务管理命令

### 5.1 基本管理命令

```
# 查看服务状态
pm2 status
# 或
pm2 list

# 查看服务详细信息
pm2 describe node-service

# 监控服务资源使用情况
pm2 monit

# 重启服务
pm2 restart all
pm2 restart node-service
pm2 restart 0  # 按 ID 重启

# 停止服务
pm2 stop all
pm2 stop node-service

# 删除服务
pm2 delete all
pm2 delete node-service

# 重新加载服务（修改配置后）
pm2 reload node-service
```



### 5.2 日志管理命令

```
# 查看所有服务的实时日志
pm2 logs

# 查看特定服务的日志
pm2 logs node-service

# 查看最后 N 行日志
pm2 logs --lines 100

# 查看错误日志
pm2 logs --err

# 查看输出日志
pm2 logs --out

# 清空日志
pm2 flush
```



### 5.3 进程管理测试

```
# 测试进程恢复功能
pm2 kill          # 停止所有进程和 PM2 守护进程
pm2 list          # 确认进程已停止（会重新启动守护进程）
pm2 resurrect     # 恢复保存的进程
pm2 status        # 确认进程已恢复

# 测试开机自启
reboot            # 重启服务器
# 重启后检查服务状态
pm2 list
```



## 6. 服务监控与维护

### 6.1 健康检查配置

在 `ecosystem.config.js` 中添加健康检查：

```
module.exports = {
  apps: [{
    name: 'node-service',
    script: './bin/www',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'development',
    },
    env_production: {
      NODE_ENV: 'production',
    },
    // 健康检查配置
    health_check: {
      url: 'http://localhost:8109/health',
      interval: 30000,  // 30秒检查一次
      timeout: 5000     // 5秒超时
    }
  }]
}
```



### 6.2 性能监控

```
# 安装 PM2 监控模块
pm2 install pm2-logrotate    # 日志轮转
pm2 install pm2-server-monit # 服务器监控

# 配置日志轮转
pm2 set pm2-logrotate:max_size 10M    # 最大日志文件大小
pm2 set pm2-logrotate:retain 30       # 保留日志文件数
pm2 set pm2-logrotate:compress true   # 压缩旧日志
```



## 7. 配置文件说明

### 7.1 ecosystem.config.js 示例

```
module.exports = {
  apps: [{
    name: 'node-service',
    script: './bin/www',              // 入口文件
    instances: 'max',                 // 使用最大实例数（根据 CPU 核心数）
    exec_mode: 'cluster',             // 集群模式
    watch: false,                     // 是否监听文件变化（生产环境建议 false）
    max_memory_restart: '1G',         // 内存超过 1G 自动重启
    env: {
      NODE_ENV: 'development',
      PORT: 8109
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 8109
    },
    error_file: './logs/err.log',     // 错误日志路径
    out_file: './logs/out.log',       // 输出日志路径
    log_file: './logs/combined.log',  // 合并日志路径
    time: true                        // 日志添加时间戳
  }]
}
```



### 7.2 环境变量文件 (.env) 示例

```
# 服务配置
PORT=8109
NODE_ENV=production

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=your_database
DB_USER=your_username
DB_PASS=your_password

# Redis 配置
REDIS_HOST=localhost
REDIS_PORT=6379

# 日志配置
LOG_LEVEL=info
LOG_FILE=/home/4.5/nodeService/logs/app.log
```



## 8. 故障排查与维护

### 8.1 常见问题解决

**问题：命令未找到**

```
# 重新加载环境变量
source ~/.bashrc

# 检查软链接
ls -la /usr/local/bin | grep node
ls -la /usr/local/bin | grep pm2

# 检查 PATH 环境变量
echo $PATH
```



**问题：端口冲突**

```
# 检查端口占用
netstat -tunlp | grep 8109
lsof -i :8109

# 修改服务端口
vi /home/4.5/nodeService/.env
# 修改 PORT 变量后重启服务
pm2 restart node-service
```



**问题：权限不足**

```
# 确保文件权限正确
chmod +x /usr/local/nodejs/bin/*

# 检查 PM2 进程权限
ps aux | grep pm2

# 检查服务目录权限
ls -la /home/4.5/nodeService/
```



**问题：依赖安装失败**

```
# 清理 npm 缓存
npm cache clean --force

# 删除 node_modules 重新安装
rm -rf node_modules
npm install

# 使用淘宝镜像
npm install --registry=https://registry.npmmirror.com
```



### 8.2 日志分析

```
# 查看 PM2 守护进程日志
tail -f /root/.pm2/pm2.log

# 查看应用错误日志
tail -f /root/.pm2/logs/node-service-error-0.log

# 查看应用输出日志
tail -f /root/.pm2/logs/node-service-out-0.log

# 使用 grep 过滤日志
grep "ERROR" /root/.pm2/logs/node-service-error-0.log
```



## 9. 备份与恢复

### 9.1 备份 PM2 配置

```
# 备份进程列表
pm2 save

# 备份 PM2 配置文件
cp /root/.pm2/dump.pm2 /opt/backup/pm2-backup-$(date +%Y%m%d).pm2

# 备份应用配置
tar -czf /opt/backup/node-service-backup-$(date +%Y%m%d).tar.gz /home/4.5/nodeService/
```



### 9.2 恢复配置

```
# 恢复 PM2 进程列表
pm2 resurrect

# 或者从备份文件恢复
cp /opt/backup/pm2-backup-$(date +%Y%m%d).pm2 /root/.pm2/dump.pm2
pm2 resurrect
```



## 10. 安全建议

### 10.1 系统安全

```
# 创建专用用户运行服务（推荐）
useradd -m -s /bin/bash nodeuser
passwd nodeuser

# 更改服务目录所有者
chown -R nodeuser:nodeuser /home/4.5/nodeService

# 使用非 root 用户运行 PM2
su - nodeuser
pm2 start ecosystem.config.js
```



### 10.2 防火墙配置

```
# 开放服务端口
firewall-cmd --permanent --add-port=8109/tcp
firewall-cmd --reload

# 或者使用 iptables
iptables -A INPUT -p tcp --dport 8109 -j ACCEPT
service iptables save
```



## 总结

至此，Node.js 环境已经成功安装并完成了 Node 服务的部署。服务运行在 8109 端口，使用 PM2 进行进程管理，并配置了开机自启功能。

### 最终验证步骤：

1. 检查进程状态：`pm2 list`
2. 查看服务日志：`pm2 logs`
3. 测试服务接口：`curl http://localhost:8109/health`
4. 验证开机自启：重启服务器后检查服务状态