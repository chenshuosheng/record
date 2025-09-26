# CentOS 7 部署 Node.js 项目完整指南

## 环境准备

### 1. Node.js 安装（使用 NVM）

```bash
# 安装编译工具
sudo yum install -y gcc-c++ make

# 安装 NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 加载 NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 安装 Node.js LTS 版本
nvm install 16.20.2
nvm use 16.20.2
nvm alias default 16.20.2
```



### 2. 永久环境配置

vi `~/.bashrc` 文件，添加以下内容：

```
# NVM 配置
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 设置默认 Node 版本
nvm use 16.20.2 > /dev/null 2>&1

# 添加全局路径
export PATH="$HOME/.nvm/versions/node/v16.20.2/bin:$PATH"
```



### **重新加载 Shell 配置**，使配置生效

```shell
source ~/.bashrc
```



## 项目部署

### 1. 项目初始化

```
# 克隆项目
git clone <your-repo-url>
cd your-project

# 安装依赖
npm install

# 配置环境变量
cp env.example .env
vi .env  # 编辑配置
```



### 2. 进程管理（PM2）

```
# 全局安装 PM2
npm install -g pm2

# 启动应用
pm2 start app.js --name "your-app"

# 常用命令
pm2 list              # 查看进程列表
pm2 logs your-app     # 查看实时日志
pm2 monit             # 监控面板
pm2 restart your-app  # 重启应用
pm2 stop 应用名称	   # 停止指定应用
pm2 delete 应用名称	   # 移除指定应用

# 设置开机自启
pm2 save
pm2 startup
```



## 网络配置

### 1. 服务器防火墙配置

```
# 启动防火墙
sudo systemctl start firewalld
sudo systemctl enable firewalld

# 开放端口
sudo firewall-cmd --zone=public --add-port=8109/tcp --permanent
sudo firewall-cmd --reload

# 验证端口开放
sudo firewall-cmd --list-ports
```



### 2. 云平台安全组配置（关键步骤）

#### 腾讯云安全组配置：

1. 登录腾讯云控制台 → 云服务器 → 安全组
2. 添加入站规则：
   - 类型：自定义
   - 来源：0.0.0.0/0（或指定IP）
   - 协议端口：TCP:8109
   - 策略：允许

#### 阿里云安全组配置：

1. 登录阿里云控制台 → ECS → 安全组
2. 添加入站规则：
   - 授权策略：允许
   - 协议类型：自定义TCP
   - 端口范围：8109/8109
   - 授权对象：0.0.0.0/0

## 应用配置

### 1. 确保正确绑定地址

在 Node.js 应用中：

javascript

复制下载

```
const PORT = process.env.PORT || 8109;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`服务器运行在端口 ${PORT}`);
});
```



### 2. 验证服务状态

bash

复制下载

```
# 检查端口监听
sudo netstat -tunlp | grep 8109

# 本地测试
curl http://localhost:8109

# 外部测试（替换为实际IP）
curl http://your-server-ip:8109
```



## 安全加固

### 1. 使用非 root 用户运行

bash

复制下载

```
# 创建专用用户
sudo useradd nodeuser
sudo chown -R nodeuser:nodeuser /path/to/your-project

# 以专用用户运行
sudo -u nodeuser pm2 start app.js --name "your-app"
```



### 2. 配置 Nginx 反向代理

nginx

复制下载

```
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8109;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```



## 故障排除

### 常见问题及解决方案

1. **命令未找到 (node/npm/pm2)**

   bash

   复制下载

   ```
   source ~/.bashrc  # 重新加载配置
   ```

   

2. **端口无法访问**

   - 检查云平台安全组规则
   - 验证服务器防火墙配置
   - 确认应用绑定到 `0.0.0.0`

3. **应用立即退出**

   bash

   复制下载

   ```
   # 手动运行查看错误
   node app.js
   
   # 检查依赖完整性
   rm -rf node_modules
   npm install
   ```

   

4. **权限问题**

   bash

   复制下载

   ```
   # 修复文件权限
   chmod 644 ~/.bashrc
   
   # 检查进程所有者
   ps aux | grep node
   ```

   

## 监控与维护

### 1. 日志管理

bash

复制下载

```
# 安装日志轮转
pm2 install pm2-logrotate
pm2 set pm2-logrotate:retain 30

# 查看日志
pm2 logs --lines 100
```



### 2. 性能监控

bash

复制下载

```
# 实时监控
pm2 monit

# 健康检查接口
curl http://localhost:8109/health
```



### 3. 定期维护

bash

复制下载

```
# 更新依赖
npm update

# 清理旧日志
pm2 flush

# 检查安全更新
npm audit
npm audit fix
```



## 附录：常用命令速查

| 命令                         | 描述              |
| :--------------------------- | :---------------- |
| `node -v`                    | 检查 Node.js 版本 |
| `npm -v`                     | 检查 npm 版本     |
| `pm2 list`                   | 查看运行中的进程  |
| `pm2 logs`                   | 查看应用日志      |
| `sudo netstat -tunlp`        | 查看端口监听状态  |
| `curl http://localhost:8109` | 测试本地访问      |
| `systemctl status firewalld` | 检查防火墙状态    |