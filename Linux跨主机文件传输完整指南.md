# Linux跨主机文件传输完整指南

## 一、文档概述

本文档提供完整的Linux跨主机文件传输解决方案，包括：
- 三种核心传输命令的详细使用（scp、rsync、sftp）
- 结合tmux实现断网保活传输
- SSH密钥配置实现免密登录
- 工具安装与故障排查

---

## 二、环境准备

### 2.1 基础工具安装

#### Ubuntu/Debian系统
```bash
# 更新软件源
sudo apt update

# 安装基础传输工具
sudo apt install -y openssh-client rsync

# 安装tmux（用于保持会话）
sudo apt install -y tmux
```

#### CentOS/RHEL/Rocky Linux系统
```bash
# 安装EPEL源（CentOS 7需要）
sudo yum install -y epel-release

# 安装基础工具
sudo yum install -y openssh-clients rsync

# 安装tmux
sudo yum install -y tmux
```

#### 验证安装
```bash
# 检查版本
scp -V
rsync --version
tmux -V

# 检查SSH客户端
ssh -V
```

---

## 三、SSH免密登录配置

### 3.1 生成SSH密钥对

在**本地客户端**执行：

```bash
# 生成ED25519密钥（推荐，更安全更快速）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 或生成RSA密钥（兼容性更好）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**交互过程说明**：
```
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519): [直接回车使用默认路径]
Enter passphrase (empty for no passphrase): [可选：设置密钥密码，增加安全性]
Enter same passphrase again: [确认密码]
```

> **安全建议**：生产环境建议设置passphrase，并配合ssh-agent使用。

### 3.2 将公钥复制到远程服务器

#### 方法一：使用ssh-copy-id（推荐）
```bash
# 自动复制公钥到远程服务器
ssh-copy-id user@remote_server_ip

# 指定端口
ssh-copy-id -p 2222 user@remote_server_ip
```

#### 方法二：手动复制
```bash
# 查看本地公钥
cat ~/.ssh/id_ed25519.pub

# 登录远程服务器，将公钥内容添加到 authorized_keys
ssh user@remote_server_ip
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-ed25519 AAAAC3... 你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit
```

#### 方法三：一行命令完成
```bash
# 通过管道直接添加
cat ~/.ssh/id_ed25519.pub | ssh user@remote_server_ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### 3.3 测试免密登录
```bash
# 应该不需要输入密码直接登录
ssh user@remote_server_ip

# 退出远程连接
exit
```

### 3.4 SSH客户端配置（可选但推荐）

创建/编辑 `~/.ssh/config` 文件，简化连接：

```bash
# 编辑配置文件
vim ~/.ssh/config
```

添加以下内容：
```
# 远程服务器配置
Host myserver
    HostName 192.168.1.100
    User myusername
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host backup-server
    HostName backup.example.com
    User backupuser
    Port 2222
    Compression yes
```

简化后的使用：
```bash
# 原来需要：
ssh user@192.168.1.100 -p 22

# 现在只需要：
ssh myserver
scp file.txt myserver:/home/user/
rsync -avz /local/dir/ myserver:/remote/dir/
```

---

## 四、tmux会话管理（防止断网中断）

### 4.1 tmux基础使用

#### 启动新会话
```bash
# 创建新会话并命名
tmux new -s file-transfer

# 或不命名直接启动
tmux
```

#### 会话管理命令
```bash
# 列出所有会话
tmux ls

# 脱离（detach）当前会话（保持后台运行）
# 快捷键：Ctrl+b，然后按 d
# 或者执行命令：
tmux detach

# 重新连接会话
tmux attach -t file-transfer

# 杀死会话
tmux kill-session -t file-transfer

# 在会话内创建新窗口
# Ctrl+b，然后按 c

# 切换窗口
# Ctrl+b，然后按 0-9（窗口编号）
# 或 Ctrl+b，然后按 n（下一个）/ p（上一个）

# 垂直分屏
# Ctrl+b，然后按 %

# 水平分屏
# Ctrl+b，然后按 "

# 在分屏间切换
# Ctrl+b，然后按方向键
```

### 4.2 长时传输场景实战

#### 场景一：启动传输后下班离开
```bash
# 1. 创建tmux会话
tmux new -s transfer

# 2. 启动传输命令（在tmux会话内执行）
rsync -avzP --progress /data/bigfile.tar.gz user@remote:/backup/

# 3. 脱离会话（Ctrl+b, d）
# 4. 关闭终端，回家
# 5. 第二天查看：重新连接查看进度
tmux attach -t transfer
```

#### 场景二：使用脚本自动重连
创建传输脚本 `/home/user/bin/safe_transfer.sh`：
```bash
#!/bin/bash
# 安全的自动重连传输脚本

TMUX_SESSION="backup_transfer"
SOURCE_DIR="/data/to_backup/"
REMOTE="myserver:/backup/data/"

# 检查tmux会话是否已存在
if tmux has-session -t $TMUX_SESSION 2>/dev/null; then
    echo "会话 $TMUX_SESSION 已存在，正在连接..."
    tmux attach -t $TMUX_SESSION
else
    echo "创建新会话 $TMUX_SESSION 并开始传输..."
    # 创建新会话并执行传输命令
    tmux new -d -s $TMUX_SESSION
    
    # 在会话中执行传输命令（使用rsync的--partial保留已传输部分）
    tmux send-keys -t $TMUX_SESSION "rsync -avzP --partial --progress $SOURCE_DIR $REMOTE" C-m
    
    # 可选：创建分屏显示系统监控
    tmux split-window -h -t $TMUX_SESSION
    tmux send-keys -t $TMUX_SESSION "watch -n 2 'df -h /data'" C-m
    
    # 连接到会话
    tmux attach -t $TMUX_SESSION
fi
```

```bash
chmod +x /home/user/bin/safe_transfer.sh
```

---

## 五、详细命令参考

### 5.1 scp命令完全指南

#### 基础语法
```bash
scp [选项] [源] [目标]
```

#### 完整选项列表

| 选项 | 说明                         | 示例                                         |
| ---- | ---------------------------- | -------------------------------------------- |
| `-r` | 递归复制整个目录             | `scp -r /dir user@host:/path/`               |
| `-P` | 指定远程SSH端口（大写）      | `scp -P 2222 file user@host:/path/`          |
| `-p` | 保留文件属性（权限、时间戳） | `scp -p file user@host:/path/`               |
| `-C` | 压缩传输                     | `scp -C largefile user@host:/path/`          |
| `-l` | 限制带宽（Kbit/s）           | `scp -l 8192 file user@host:/path/`（1MB/s） |
| `-i` | 指定私钥文件                 | `scp -i ~/.ssh/custom_key file user@host:`   |
| `-v` | 详细输出（调试用）           | `scp -v file user@host:`                     |
| `-q` | 安静模式（不显示进度）       | `scp -q file user@host:`                     |
| `-o` | 传递SSH选项                  | `scp -o ConnectTimeout=10 file user@host:`   |

#### 实用示例

```bash
# 1. 上传多个文件
scp file1.txt file2.txt file3.txt user@remote:/target/dir/

# 2. 下载远程目录（带进度条）
scp -r user@remote:/var/log/ ./local_logs/

# 3. 限速传输（限制为512KB/s，即4096Kbit/s）
scp -l 4096 largefile.iso user@remote:/backup/

# 4. 使用不同端口并压缩
scp -P 2222 -C -r /data/backup/ user@remote:/backup/

# 5. 免密且跳过主机密钥检查（不推荐生产环境）
scp -o StrictHostKeyChecking=no file user@remote:/path/

# 6. 从远程复制到另一个远程（通过本地中转）
scp user1@host1:/file user2@host2:/path/
```

### 5.2 rsync命令完全指南

#### 基础语法
```bash
rsync [选项] 源 目标
```

#### 核心选项详解

| 选项                    | 说明                               | 使用建议                               |
| ----------------------- | ---------------------------------- | -------------------------------------- |
| `-a`                    | 归档模式（保留权限、时间、递归等） | **最常用**，相当于-rlptgoD             |
| `-v`                    | 详细输出                           | 查看传输过程                           |
| `-z`                    | 传输时压缩                         | 适合文本文件，已压缩文件慎用           |
| `-P`                    | 显示进度+保留部分传输的文件        | **长传必备**，等于--progress --partial |
| `-u`                    | 更新模式（跳过目标端更新的文件）   | 避免覆盖新文件                         |
| `--delete`              | 删除目标端源端不存在的文件         | **同步到完全一致**（谨慎使用）         |
| `--exclude`             | 排除文件或目录                     | `--exclude='*.tmp'`                    |
| `--include`             | 包含特定文件                       | 与exclude配合使用                      |
| `--bwlimit`             | 限制带宽（KB/s）                   | `--bwlimit=1024`（1MB/s）              |
| `--dry-run`             | 试运行（不实际传输）               | 测试命令效果                           |
| `-n`                    | 同--dry-run                        | 安全测试                               |
| `--remove-source-files` | 传输后删除源文件                   | 实现"移动"文件                         |
| `-h`                    | 人类可读的格式                     | 配合-v使用                             |

#### 高级示例

```bash
# 1. 基本同步（显示进度）
rsync -avzP /source/dir/ user@remote:/dest/dir/

# 2. 完全镜像同步（删除目标多余文件）
rsync -avzP --delete /source/ user@remote:/dest/

# 3. 排除特定文件和目录
rsync -avzP --exclude='*.log' --exclude='cache/' /data/ user@remote:/backup/

# 4. 限制带宽（500KB/s）并限时
rsync -avzP --bwlimit=500 /bigfile user@remote:/dest/

# 5. 先试运行，查看会做什么
rsync -avzP --dry-run /source/ user@remote:/dest/

# 6. 只同步新的和更改的文件（跳过已存在且大小相同的）
rsync -avzu /source/ user@remote:/dest/

# 7. 远程到远程同步（需在远程主机安装rsync）
rsync -avzP -e ssh user1@host1:/source/ user2@host2:/dest/

# 8. 使用自定义SSH端口
rsync -avzP -e "ssh -p 2222" /local/ user@remote:/dest/

# 9. 备份整个系统（排除特殊目录）
rsync -avzP --exclude='/proc/*' --exclude='/sys/*' --exclude='/dev/*' \
      --exclude='/tmp/*' --exclude='/var/tmp/*' --exclude='/run/*' \
      / /backup/system-backup/

# 10. 显示每个文件的传输速度
rsync -avzhP --stats /source/ user@remote:/dest/
```

#### rsync特殊符号说明

```bash
# 源路径结尾斜杠的差异
rsync -av /source/dir/ user@remote:/dest/     # 复制dir内部内容到dest
rsync -av /source/dir user@remote:/dest/      # 复制dir目录本身到dest/dir

# 实际效果演示
# 本地结构：/source/dir/file.txt
# 命令1后：/dest/file.txt
# 命令2后：/dest/dir/file.txt
```

### 5.3 sftp交互式命令

#### 连接与基础操作
```bash
# 连接服务器
sftp user@remote_server
sftp -P 2222 user@remote_server
sftp -oPort=2222 user@remote_server

# 使用配置文件中的主机名
sftp myserver
```

#### 交互命令完整列表

| 命令              | 说明              | 示例                   |
| ----------------- | ----------------- | ---------------------- |
| `ls [path]`       | 列出远程目录      | `ls -la /var/log`      |
| `cd [path]`       | 改变远程目录      | `cd /home/user/data`   |
| `pwd`             | 显示远程当前目录  | `pwd`                  |
| `lls [path]`      | 列出本地目录      | `lls ./downloads`      |
| `lcd [path]`      | 改变本地目录      | `lcd /tmp`             |
| `lpwd`            | 显示本地当前目录  | `lpwd`                 |
| `get [file]`      | 下载文件          | `get log.txt`          |
| `get -r [dir]`    | 递归下载目录      | `get -r /remote/logs/` |
| `put [file]`      | 上传文件          | `put backup.tar.gz`    |
| `put -r [dir]`    | 递归上传目录      | `put -r ./data/`       |
| `rm [file]`       | 删除远程文件      | `rm old.log`           |
| `rmdir [dir]`     | 删除远程空目录    | `rmdir emptydir`       |
| `mkdir [dir]`     | 创建远程目录      | `mkdir newfolder`      |
| `rename old new`  | 重命名远程文件    | `rename a.txt b.txt`   |
| `chmod mode file` | 修改远程文件权限  | `chmod 755 script.sh`  |
| `df -h`           | 查看远程磁盘空间  | `df -h`                |
| `!command`        | 执行本地shell命令 | `!ls -la`              |
| `help`            | 显示帮助          | `help`                 |
| `quit` 或 `exit`  | 退出sftp          | `quit`                 |

#### 高级使用技巧

```bash
# 1. 批量下载匹配模式的文件（使用通配符）
sftp> mget *.log

# 2. 批量上传
sftp> mput *.txt

# 3. 断点续传（需要支持）
sftp> reget largefile.iso

# 4. 非交互式使用（在shell脚本中）
echo "get /remote/file.txt" | sftp user@host
# 或使用批处理文件
sftp -b batchfile.txt user@host

# 5. 限制并发连接
sftp -R 3 user@host  # 限制3个请求
```

---

## 六、生产环境实战场景

### 6.1 场景一：网站备份（每天凌晨执行）

创建备份脚本 `/home/user/bin/website_backup.sh`：

```bash
#!/bin/bash
# 网站自动备份脚本

# 配置变量
BACKUP_DATE=$(date +%Y%m%d)
LOCAL_BACKUP_DIR="/backup/website"
REMOTE_USER="backupuser"
REMOTE_HOST="backup-server"
REMOTE_PATH="/backups/website/"
TMUX_SESSION="website_backup"
LOG_FILE="/var/log/backup.log"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# 创建本地备份目录
mkdir -p $LOCAL_BACKUP_DIR

# 检查是否在tmux会话中
if [ -z "$TMUX" ]; then
    log "在tmux会话中启动备份..."
    tmux new -d -s $TMUX_SESSION "$0"
    exit 0
fi

log "开始备份: $(date)"

# 步骤1：打包网站文件
log "打包网站文件..."
tar -czf $LOCAL_BACKUP_DIR/website-$BACKUP_DATE.tar.gz /var/www/html/

# 步骤2：导出数据库
log "导出数据库..."
mysqldump -u root -pPASSWORD mydatabase > $LOCAL_BACKUP_DIR/db-$BACKUP_DATE.sql

# 步骤3：同步到远程服务器
log "同步到远程服务器..."
rsync -avzP --progress $LOCAL_BACKUP_DIR/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/ >> $LOG_FILE 2>&1

# 步骤4：删除7天前的本地备份
log "清理本地旧备份..."
find $LOCAL_BACKUP_DIR -type f -mtime +7 -delete

# 步骤5：远程清理（如果有）
ssh $REMOTE_USER@$REMOTE_HOST "find $REMOTE_PATH -type f -mtime +30 -delete"

log "备份完成: $(date)"

# 完成，tmux会话保持5分钟后自动退出
sleep 300
tmux kill-session -t $TMUX_SESSION
```

添加到crontab：
```bash
# 编辑定时任务
crontab -e

# 每天凌晨2点执行
0 2 * * * /home/user/bin/website_backup.sh
```

### 6.2 场景二：大文件断点续传

```bash
# 方案1：使用rsync（支持断点续传）
rsync -avzP --partial --progress hugefile.iso user@remote:/backup/

# 如果中断，再次运行相同命令即可续传
rsync -avzP --partial --progress hugefile.iso user@remote:/backup/

# 方案2：使用dd配合ssh（高级用户）
# 发送端
dd if=hugefile.iso bs=1M | ssh user@remote "dd of=/backup/hugefile.iso bs=1M"

# 断点续传版本（记录偏移量）
# 在远程检查已传输大小
SIZE=$(ssh user@remote "stat -c%s /backup/hugefile.iso 2>/dev/null || echo 0")
# 从偏移量继续
dd if=hugefile.iso bs=1M skip=$((SIZE / 1024 / 1024)) | \
    ssh user@remote "dd of=/backup/hugefile.iso bs=1M seek=$((SIZE / 1024 / 1024)) oflag=append conv=notrunc"
```

### 6.3 场景三：多服务器并行分发文件

使用 `pssh`（parallel ssh）工具：

```bash
# 安装pssh
sudo apt install pssh  # Ubuntu/Debian
sudo yum install pssh  # CentOS

# 创建主机列表文件
cat > /etc/backup/hosts.txt << EOF
192.168.1.10
192.168.1.11
192.168.1.12
EOF

# 并行分发文件
prsync -h /etc/backup/hosts.txt -l user -avz /local/file.tar.gz /remote/dir/

# 并行执行远程命令
pssh -h /etc/backup/hosts.txt -l user -i "ls -la /remote/dir/"
```

### 6.4 场景四：监控传输进度

创建进度监控脚本 `/home/user/bin/monitor_transfer.sh`：

```bash
#!/bin/bash
# 监控rsync传输进度

REMOTE_HOST="myserver"
REMOTE_PATH="/backup/largefile.dat"
LOCAL_PATH="/data/largefile.dat"

while true; do
    clear
    echo "=== 文件传输进度监控 ==="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "==========================="
    
    # 获取本地文件大小
    if [ -f "$LOCAL_PATH" ]; then
        LOCAL_SIZE=$(stat -c%s "$LOCAL_PATH" 2>/dev/null || echo 0)
        LOCAL_SIZE_H=$(numfmt --to=iec $LOCAL_SIZE)
    else
        LOCAL_SIZE=0
        LOCAL_SIZE_H="0B"
    fi
    
    # 获取远程文件大小
    REMOTE_SIZE=$(ssh $REMOTE_HOST "stat -c%s \"$REMOTE_PATH\"" 2>/dev/null || echo 0)
    REMOTE_SIZE_H=$(numfmt --to=iec $REMOTE_SIZE)
    
    echo "本地大小:  $LOCAL_SIZE_H ($LOCAL_SIZE bytes)"
    echo "远程大小:  $REMOTE_SIZE_H ($REMOTE_SIZE bytes)"
    
    # 如果有原始文件大小，计算进度
    ORIGINAL_SIZE=10737418240  # 10GB示例
    if [ $ORIGINAL_SIZE -gt 0 ]; then
        PROGRESS=$((REMOTE_SIZE * 100 / ORIGINAL_SIZE))
        echo "完成进度: $PROGRESS%"
        
        # 显示进度条
        BAR_LEN=$((PROGRESS / 2))
        printf "["
        for i in $(seq 1 50); do
            if [ $i -le $BAR_LEN ]; then
                printf "="
            else
                printf " "
            fi
        done
        printf "] $PROGRESS%%\n"
    fi
    
    echo "==========================="
    echo "按 Ctrl+C 退出监控"
    sleep 5
done
```

---

## 七、故障排查与优化

### 7.1 常见问题及解决方案

#### 问题1：连接超时
```bash
# 解决方案：增加超时时间和重试
ssh -o ConnectTimeout=30 -o ServerAliveInterval=60 user@host

# 在rsync中使用
rsync -avzP -e "ssh -o ConnectTimeout=30 -o ServerAliveInterval=60" /local/ user@host:/remote/
```

#### 问题2：传输中断后无法续传
```bash
# 确保使用支持断点续传的参数
rsync -avzP --partial --progress /local/ user@host:/remote/

# 检查rsync版本（3.0.0以上支持更好）
rsync --version
```

#### 问题3：权限被拒绝（Permission denied）
```bash
# 检查远程目录权限
ssh user@host "ls -ld /remote/dir"

# 修复权限
ssh user@host "chown -R user:user /remote/dir && chmod 755 /remote/dir"

# 检查authorized_keys权限
ssh user@host "chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
```

#### 问题4：传输速度慢
```bash
# 解决方案1：压缩传输（适合文本）
rsync -avz /local/ user@host:/remote/

# 解决方案2：调整SSH加密算法（更快的加密）
rsync -avz -e "ssh -c arcfour256" /local/ user@host:/remote/

# 解决方案3：增加并行传输（使用split分割）
split -b 100M largefile.iso part_
for part in part_*; do
    scp $part user@host:/remote/ &
done
wait
# 在远程合并
ssh user@host "cat /remote/part_* > /remote/largefile.iso"
```

### 7.2 性能优化技巧

#### 优化TCP/IP参数
```bash
# 在/etc/sysctl.conf添加
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# 应用配置
sudo sysctl -p
```

#### 使用更快的传输工具替代方案

**选项1：使用nc（netcat）配合pv显示进度**
```bash
# 发送端
pv largefile.dat | nc -l -p 9999

# 接收端
nc remote_ip 9999 > largefile.dat
```

**选项2：使用bbcp（高性能）**
```bash
# 安装bbcp
git clone https://github.com/eeertekin/bbcp.git
cd bbcp && make

# 使用（自动并行）
./bbcp -r -P 4 /local/dir/ user@host:/remote/dir/
```

### 7.3 调试命令

```bash
# 详细输出模式
scp -vvv file user@host:/remote/  # 三级详细输出
rsync -avzP --progress --stats /local/ user@host:/remote/

# 测试SSH连接
ssh -vvv user@host
ssh -T user@host  # 测试免密登录

# 检查网络质量
mtr -r -c 100 remote_host
ping -c 100 remote_host

# 测试带宽
iperf3 -c remote_host  # 需两端安装iperf3
```

---

## 八、安全最佳实践

### 8.1 SSH安全加固

```bash
# 编辑SSH配置 /etc/ssh/sshd_config（远程服务器）
# 禁用root登录
PermitRootLogin no

# 禁用密码登录（仅密钥）
PasswordAuthentication no
ChallengeResponseAuthentication no

# 更改默认端口
Port 2222

# 限制用户
AllowUsers user1 user2

# 重启SSH服务
sudo systemctl restart sshd
```

### 8.2 使用跳板机（堡垒机）

```bash
# ~/.ssh/config配置
Host target-server
    HostName 192.168.1.100
    User appuser
    ProxyJump jumphost

Host jumphost
    HostName jump.example.com
    User jumpuser
    Port 22

# 直接传输（自动通过跳板机）
scp file target-server:/path/
rsync -avz /local/ target-server:/remote/
```

### 8.3 使用ssh-agent管理密钥

```bash
# 启动ssh-agent
eval $(ssh-agent)

# 添加私钥（输入passphrase）
ssh-add ~/.ssh/id_ed25519

# 查看已加载的密钥
ssh-add -l

# 在tmux会话中持久化
tmux new -s agent-session
eval $(ssh-agent) > /dev/null
ssh-add

# 现在可以安全地进行多窗口传输
```

---

## 九、快速参考卡片

### 最常用命令速查

```bash
# 上传单个文件
scp file.txt user@host:/path/

# 下载整个目录
scp -r user@host:/path/dir/ ./local/

# 增量同步（最常用）
rsync -avzP /local/dir/ user@host:/remote/dir/

# 完全镜像（删除多余文件）
rsync -avzP --delete /local/ user@host:/remote/

# 交互式传输
sftp user@host

# tmux保活传输
tmux new -s transfer
rsync -avzP /bigdata/ user@host:/backup/
# Ctrl+b, d 脱离会话
tmux attach -t transfer  # 重新连接

# 带宽限制（1MB/s）
rsync -avzP --bwlimit=1024 /file user@host:/path/
scp -l 8192 /file user@host:/path/  # 8192 Kbit = 1MB/s

# 排除文件
rsync -avzP --exclude='*.log' --exclude='temp/' /source/ user@host:/dest/
```

### 命令选择决策树

```
是否需要交互式浏览远程目录？
    ├─ 是 → 使用 sftp
    └─ 否 → 是否定期同步/增量传输/大文件？
        ├─ 是 → 使用 rsync
        └─ 否 → 使用 scp
```

---

## 十、参考资料

### 查看帮助文档
```bash
man scp
man rsync
man sftp
man tmux
man ssh
man ssh-keygen

# 查看版本信息
scp -V
rsync --version
ssh -V
```

### 常用参数组合记忆

- **scp三板斧**: `-r`（目录）、`-P`（端口）、`-C`（压缩）
- **rsync精髓**: `-avzP` = 归档+详细+压缩+进度
- **sftp三板斧**: `ls`（看）、`get`（下）、`put`（上）

---

**文档版本**: 1.0  
**最后更新**: 2026-06-14  
**适用系统**: Linux发行版（Ubuntu/CentOS/RHEL/Rocky等）

> 本文档涵盖了Linux跨主机文件传输的完整知识体系，建议将常用命令保存为别名或脚本，提高工作效率。