### 方案一：使用 chrony（推荐 CentOS/RHEL 7+）

#### 1. 安装 chrony

```
# CentOS/RHEL 系统
sudo yum install chrony -y

# Ubuntu/Debian 系统
sudo apt-get install chrony -y

# 验证安装
rpm -qa | grep chrony   # CentOS/RHEL
dpkg -l | grep chrony   # Ubuntu/Debian
```



**实际安装示例：**

```
[root@pms_db ~]# sudo yum install chrony -y
已加载插件：fastestmirror
正在解决依赖关系
--> 正在检查事务
---> 软件包 chrony.x86_64.0.3.4-1.el7 将被安装
--> 解决依赖关系完成

==================================================================
 Package   架构       版本              源           大小
==================================================================
安装:
 chrony   x86_64     3.4-1.el7         base        251 k

事务概要
==================================================================
安装  1 软件包

已安装:
  chrony.x86_64 0:3.4-1.el7
完毕！
```



#### 2. 配置 chrony

```
# 编辑配置文件
sudo vi /etc/chrony.conf

# 推荐配置（国内使用阿里云 NTP）
server ntp.aliyun.com iburst
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
rtcsync              # 自动同步硬件时钟
makestep 1.0 3       # 允许前3次更新步进时间
driftfile /var/lib/chrony/drift
logdir /var/log/chrony

# 内网环境配置（使用内网 NTP 服务器）
server 200.100.108.240 iburst
local stratum 10     # 当 NTP 服务器不可用时使用本地时钟
```



#### 3. 启动并验证服务

```
# 启动服务并设置开机自启
sudo systemctl start chronyd
sudo systemctl enable chronyd

# 检查服务状态
sudo systemctl status chronyd

# 查看时间源状态
chronyc sources -v

# 查看同步详情
chronyc tracking
```



**验证输出示例：**

```
[root@pms_db ~]# chronyc sources -v
210 Number of sources = 4

MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ 119.28.206.193                2   6    17     9   -797us[-2514us] +/- 36ms
^* 139.199.214.202               2   6    17     8   -274us[-1990us] +/- 30ms
^- tick.ntp.infomaniak.ch        1   6    17     7    -39ms[ -39ms] +/- 124ms
```



> **标志说明：**
>
> - `^*` : 当前正在使用的同步源
> - `^+` : 可用的备用同步源
> - `^-` : 不可用的同步源
> - `^?` : 连接失败或未响应

#### 4. 强制时间同步

```
# 立即同步时间（步进式）
sudo chronyc makestep
# 输出: 200 OK

# 等待同步完成
sleep 3

# 查看同步后状态
chronyc tracking
```



#### 5. 同步硬件时钟

```
# 将系统时间写入硬件时钟（UTC 模式）
sudo hwclock --systohc --utc

# 验证同步结果
date "+%Y-%m-%d %H:%M:%S" && sudo hwclock --show
```



------

### 方案二：使用 timedatectl（适用于 systemd 系统）

#### 1. 禁用自动同步

```
# 查看当前状态
timedatectl status

# 禁用 NTP 自动同步（允许手动设置）
sudo timedatectl set-ntp false
```



#### 2. 手动设置时间

```
# 设置系统时间
sudo timedatectl set-time "2026-06-10 16:55:40"
```



> ⚠️ **注意**：`timedatectl set-time` 会自动执行 `hwclock --systohc`，将系统时间写入硬件时钟。

#### 3. 重新启用自动同步

```
# 重新启用 NTP 自动同步
sudo timedatectl set-ntp true
```



------

### 方案三：使用传统命令（临时同步）

```
# 使用 date 命令设置（不会自动同步硬件时钟）
sudo date -s "2026-06-10 16:55:40"

# 需要手动同步硬件时钟
sudo hwclock --systohc

# 或从硬件时钟同步到系统
sudo hwclock --hctosys
```



------

### 方案四：配置内网 NTP 客户端

```
# 1. 安装 chrony
sudo yum install chrony -y

# 2. 配置内网 NTP 服务器
echo "server 200.100.108.240 iburst" | sudo tee -a /etc/chrony.conf
echo "rtcsync" | sudo tee -a /etc/chrony.conf

# 3. 启动服务
sudo systemctl enable --now chronyd

# 4. 验证
sudo chronyc sources -v

# 5. 如果遇到 "Could not add source" 错误
# 测试 NTP 服务器可用性
sudo yum install ntpdate -y
sudo ntpdate -q 200.100.108.240
```



------

## ✅ 最终验证结果

### 验证命令

```
# 完整验证脚本
echo "=== 时间同步验证 ==="
echo "系统时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "硬件时间: $(sudo hwclock --show | cut -d'.' -f1)"
echo ""
timedatectl status
echo ""
sudo chronyc sources -v 2>/dev/null || echo "chrony 未运行"
```



### 预期输出

```
=== 时间同步验证 ===
系统时间: 2026-06-10 17:00:00
硬件时间: 2026-06-10 17:00:00

               Local time: 三 2026-06-10 17:00:00 CST
           Universal time: 三 2026-06-10 09:00:00 UTC
                 RTC time: 三 2026-06-10 09:00:00
                Time zone: Asia/Shanghai (CST, +0800)
System clock synchronized: yes      # ✅ 已同步
              NTP service: active    # ✅ NTP 运行中
          RTC in local TZ: no        # ✅ 硬件时钟使用 UTC

MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* ntp.aliyun.com               2   6    377    10   -0.0002[ -0.0002] +/- 0.0010
```



------

## ⚙️ 配置详解

### 硬件时钟模式选择

| 模式             | 命令                            | 适用场景                              | 推荐度 |
| :--------------- | :------------------------------ | :------------------------------------ | :----- |
| **UTC 模式**     | `hwclock --systohc --utc`       | 双系统环境（Linux/Windows）、云服务器 | ⭐⭐⭐⭐⭐  |
| **本地时间模式** | `hwclock --systohc --localtime` | 单 Linux 系统                         | ⭐⭐     |

**东八区配置逻辑：**

```
硬件时钟(UTC): 03:45:55
    ↓ (+8小时时区)
系统时间(CST): 11:45:55
```



### timedatectl 关键命令汇总

| 命令                                         | 作用                   |
| :------------------------------------------- | :--------------------- |
| `timedatectl status`                         | 查看当前时间状态       |
| `timedatectl list-timezones`                 | 列出所有可用时区       |
| `timedatectl set-timezone Asia/Shanghai`     | 设置时区为东八区       |
| `timedatectl set-ntp true/false`             | 启用/禁用 NTP 自动同步 |
| `timedatectl set-time "YYYY-MM-DD HH:MM:SS"` | 手动设置时间           |

### 操作自动同步硬件时钟对比

| 操作                             | 是否自动同步硬件时钟               |
| :------------------------------- | :--------------------------------- |
| `timedatectl set-time`           | ✅ 是（自动执行 `--systohc`）       |
| `date -s "时间"`                 | ❌ 否（需手动 `hwclock --systohc`） |
| `hwclock --set`                  | 直接设置硬件时钟                   |
| `chronyd` 同步（配置 `rtcsync`） | ✅ 是                               |
| `ntpdate` 同步                   | ❌ 否（需手动同步）                 |

### chrony.conf 关键配置项

| 配置项          | 作用               | 示例                                |
| :-------------- | :----------------- | :---------------------------------- |
| `server`        | 指定 NTP 服务器    | `server ntp.aliyun.com iburst`      |
| `pool`          | 指定 NTP 服务器池  | `pool 2.centos.pool.ntp.org iburst` |
| `rtcsync`       | 自动同步硬件时钟   | `rtcsync`                           |
| `makestep`      | 允许步进式时间调整 | `makestep 1.0 3`                    |
| `local stratum` | 本地时钟作为备用   | `local stratum 10`                  |
| `driftfile`     | 记录时钟漂移率     | `driftfile /var/lib/chrony/drift`   |
| `allow`         | 允许其他客户端同步 | `allow 192.168.0.0/16`              |
| `cmdport`       | 命令端口（0=关闭） | `cmdport 0`                         |

------

## 🚀 长期维护建议

### 1. 启用硬件时钟自动同步

```
# 在 chrony 配置中启用 rtcsync
echo "rtcsync" | sudo tee -a /etc/chrony.conf
sudo systemctl restart chronyd
```



### 2. 监控命令速查表

| 需求               | 命令                        |
| :----------------- | :-------------------------- |
| 查看时间状态       | `timedatectl status`        |
| 查看 NTP 同步质量  | `chronyc tracking`          |
| 查看时间源         | `chronyc sources -v`        |
| 查看详细时间源信息 | `chronyc sources -v -n`     |
| 查看硬件时钟       | `sudo hwclock --show`       |
| 强制同步           | `sudo chronyc makestep`     |
| 格式化当前时间     | `date "+%Y-%m-%d %H:%M:%S"` |
| 查看 chrony 统计   | `chronyc statistics`        |
| 查看时间偏移       | `chronyc sourcestats -v`    |

### 3. 定期检查脚本

```
#!/bin/bash
# 文件名: check_time_sync.sh
# 添加到 crontab: 0 9 * * * /path/to/check_time_sync.sh

LOG_FILE="/var/log/time_sync_check.log"
THRESHOLD=5  # 阈值：5秒

# 获取系统时间和硬件时钟差值
SYS_TIME=$(date +%s)
HW_TIME=$(sudo hwclock --show | date +%s -f - 2>/dev/null)
DIFF=$((SYS_TIME - HW_TIME))
ABS_DIFF=${DIFF#-}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 时间差: ${ABS_DIFF}秒" >> $LOG_FILE

if [ $ABS_DIFF -gt $THRESHOLD ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 警告: 时间偏差过大，执行同步" >> $LOG_FILE
    sudo chronyc makestep
    sudo hwclock --systohc --utc
fi
```



### 4. 快速恢复脚本

```
#!/bin/bash
# 文件名: time_sync_fix.sh
# 时间同步快速恢复脚本

set -e

echo "=== 开始时间同步修复 ==="

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then 
    echo "请使用 root 权限运行"
    exit 1
fi

# 显示修复前时间
echo "修复前时间："
echo "  系统时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  硬件时间: $(hwclock --show | cut -d'.' -f1)"

# 停止时间服务
systemctl stop chronyd 2>/dev/null || true

# 使用 ntpdate 同步（如果可用）
if command -v ntpdate &> /dev/null; then
    echo "使用 ntpdate 同步..."
    ntpdate -u ntp.aliyun.com
else
    echo "ntpdate 不可用，使用 chrony 同步..."
    systemctl start chronyd
    sleep 2
    chronyc makestep
fi

# 同步硬件时钟
echo "同步硬件时钟..."
hwclock --systohc --utc

# 重启 chrony
systemctl restart chronyd
systemctl enable chronyd

# 显示修复后时间
echo ""
echo "=== 修复完成 ==="
echo "修复后时间："
echo "  系统时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  硬件时间: $(hwclock --show | cut -d'.' -f1)"
echo ""
timedatectl status | grep -E "synchronized|NTP service"

# 使用方式
# chmod +x time_sync_fix.sh
# sudo ./time_sync_fix.sh
```



------

## 🔧 故障排查

### 常见错误及解决方案

#### 错误 1：`Failed to set time: Automatic time synchronization is enabled`

**原因**：NTP 自动同步已启用，不允许手动设置时间。

**解决方案：**

```
# 方法一：临时禁用 NTP
sudo timedatectl set-ntp false
sudo timedatectl set-time "2026-06-10 17:00:00"
sudo timedatectl set-ntp true

# 方法二：使用 date 命令（无需禁用 NTP）
sudo date -s "2026-06-10 17:00:00"
sudo hwclock --systohc
```



#### 错误 2：`506 Cannot talk to daemon`

**原因**：chronyd 服务未运行。

**解决方案：**

```
# 启动服务
sudo systemctl start chronyd
sudo systemctl enable chronyd

# 检查服务状态
sudo systemctl status chronyd

# 查看日志
sudo journalctl -u chronyd -n 50 --no-pager
```



#### 错误 3：`Could not add source`

**原因**：NTP 服务器不可达或未运行 NTP 服务。

**解决方案：**

```
# 1. 测试 NTP 服务器可用性
sudo yum install ntpdate -y
sudo ntpdate -q 200.100.108.240

# 2. 检查网络连通性
ping -c 3 200.100.108.240

# 3. 检查 UDP 123 端口
nc -vzu 200.100.108.240 123

# 4. 检查防火墙
sudo firewall-cmd --list-all
sudo iptables -L -n -v | grep 123

# 5. 测试其他 NTP 服务器
sudo ntpdate -q ntp.aliyun.com
```



#### 错误 4：`Selected source ...` 但未同步

**原因**：时间偏差过大，chrony 在逐步调整。

**解决方案：**

```
# 强制步进同步
sudo chronyc makestep

# 或重启 chrony 并强制同步
sudo systemctl restart chronyd
sudo chronyc -a makestep

# 等待几分钟让 chrony 自动调整
watch -n 5 'chronyc sources -v'
```



#### 错误 5：硬件时钟与系统时间相差 8 小时

**原因**：时区配置错误或硬件时钟使用了本地时间模式。

**解决方案：**

```
# 检查时区
timedatectl status

# 设置正确时区
sudo timedatectl set-timezone Asia/Shanghai

# 强制硬件时钟使用 UTC
sudo hwclock --systohc --utc

# 验证
date && sudo hwclock --show
```



------

## ⚠️ 注意事项

### 重要事项

1. **双系统用户**：必须使用 UTC 模式（`--utc`），避免 Windows/Linux 时间混乱

   - Windows 默认使用本地时间
   - Linux 默认使用 UTC 时间
   - 建议在 Windows 注册表中启用 UTC 或 Linux 使用 UTC 模式

2. **云服务器**：建议使用云平台提供的内网 NTP 服务器，延迟更低

   - 阿里云：`ntp.aliyun.com`
   - 腾讯云：`ntp.tencent.com`
   - 华为云：`ntp.huaweicloud.com`

3. **内网环境**：如果无法访问公网 NTP，需配置内网 NTP 服务器

   - 选择一台能访问外网的机器搭建 NTP 服务器
   - 其他机器指向内网 NTP 服务器

4. **容器环境**：容器通常继承宿主机时间，不建议在容器内运行 chronyd

   - 使用宿主机的 NTP 服务
   - 或使用 `--privileged` 权限（不推荐）

5. **定期检查**：建议通过监控系统每月检查一次时间同步状态

6. **时区确认**：确保 `/etc/localtime` 正确链接到对应时区文件

   ```
   ls -l /etc/localtime
   # 应该显示: /etc/localtime -> ../usr/share/zoneinfo/Asia/Shanghai
   ```

   

7. **NTP 端口**：确保 UDP 123 端口未被防火墙阻断

   - 出站规则需要允许 UDP 123
   - 入站规则（作为服务端）需要允许 UDP 123

### 最佳实践

```
# 1. 安装 chrony
sudo yum install chrony -y

# 2. 配置多个 NTP 服务器（提高可用性）
cat << EOF | sudo tee /etc/chrony.conf
server ntp.aliyun.com iburst
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
rtcsync
makestep 1.0 3
driftfile /var/lib/chrony/drift
logdir /var/log/chrony
EOF

# 3. 启动并验证
sudo systemctl enable --now chronyd
sudo chronyc sources -v

# 4. 验证硬件时钟同步
date && sudo hwclock --show
```



------

## 📚 命令速查表

### 时间查看命令

| 操作场景                 | 命令                                  |
| :----------------------- | :------------------------------------ |
| 格式化获取当前系统时间   | `date "+%Y-%m-%d %H:%M:%S"`           |
| 获取硬件时钟时间         | `sudo hwclock --show`                 |
| 获取硬件时钟时间（简洁） | `sudo hwclock --show | cut -d'.' -f1` |
| 查看系统时间戳           | `date +%s`                            |

### 时间同步命令

| 操作场景                   | 命令                             |
| :------------------------- | :------------------------------- |
| 硬件时钟 → 系统时间        | `sudo hwclock --hctosys`         |
| 系统时间 → 硬件时钟        | `sudo hwclock --systohc`         |
| 系统时间 → 硬件时钟（UTC） | `sudo hwclock --systohc --utc`   |
| 启用 NTP 自动同步          | `sudo timedatectl set-ntp true`  |
| 禁用 NTP 自动同步          | `sudo timedatectl set-ntp false` |
| chrony 强制同步            | `sudo chronyc makestep`          |
| ntpdate 手动同步           | `sudo ntpdate ntp.aliyun.com`    |

### 服务管理命令

| 操作场景             | 命令                                          |
| :------------------- | :-------------------------------------------- |
| 查看时区             | `timedatectl status | grep "Time zone"`       |
| 设置时区             | `sudo timedatectl set-timezone Asia/Shanghai` |
| 重启 chrony          | `sudo systemctl restart chronyd`              |
| 查看 chrony 状态     | `sudo systemctl status chronyd`               |
| 查看 chrony 日志     | `sudo journalctl -u chronyd -f`               |
| 查看 chrony 最近日志 | `sudo journalctl -u chronyd -n 50 --no-pager` |

### chrony 专用命令

| 操作场景              | 命令                     |
| :-------------------- | :----------------------- |
| 查看时间源            | `chronyc sources -v`     |
| 查看时间源（IP 显示） | `chronyc sources -v -n`  |
| 查看同步详情          | `chronyc tracking`       |
| 查看时间源统计        | `chronyc sourcestats -v` |
| 查看 chrony 活动      | `chronyc activity`       |
| 立即同步              | `chronyc makestep`       |
| 查看服务器列表        | `chronyc sources`        |

### NTP 测试命令

| 操作场景              | 命令                             |
| :-------------------- | :------------------------------- |
| 测试 NTP 服务器       | `ntpdate -q ntp.aliyun.com`      |
| 详细测试 NTP          | `ntpdate -d ntp.aliyun.com`      |
| 测试 UDP 端口         | `nc -vzu ntp.aliyun.com 123`     |
| 测试 UDP 端口（nmap） | `nmap -sU -p 123 ntp.aliyun.com` |

------

## 🐳 Docker 容器时间同步

### 方法一：挂载宿主机时间（推荐）

```
docker run -d \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  your-image
```



### 方法二：使用 --privileged 运行 chronyd

```
docker run -d --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  your-image \
  /usr/sbin/chronyd
```



### 方法三：docker-compose 配置

```
version: '3'
services:
  app:
    image: your-image
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
```



------

## 📝 文档版本历史

| 版本 | 日期       | 修改内容                                  | 作者         |
| :--- | :--------- | :---------------------------------------- | :----------- |
| v1.0 | 2026-01-30 | 初始版本                                  | System Admin |
| v1.1 | 2026-02-15 | 增加 chrony 配置详解                      | System Admin |
| v1.2 | 2026-03-20 | 增加故障排查章节                          | System Admin |
| v2.0 | 2026-06-10 | 完善文档结构、增加命令速查表、Docker 配置 | System Admin |

------

## 📧 参考资料

- [Chrony 官方文档](https://chrony-project.org/documentation.html)
- [Red Hat Chrony 配置指南](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-configuring_ntp_using_the_chrony_suite)
- [阿里云 NTP 服务](https://help.aliyun.com/document_detail/51873.html)
- [timedatectl 手册](https://www.freedesktop.org/software/systemd/man/latest/timedatectl.html)