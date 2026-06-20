## FineBI 每周自动重启配置总结文档

### 一、概述

本文档描述了在 Linux 服务器上配置 FineBI 服务每周自动重启的完整过程。该配置通过 shell 脚本和 crontab 定时任务实现，确保服务定期重启以释放资源、清理缓存。

### 二、环境信息

| 项目            | 信息                                     |
| :-------------- | :--------------------------------------- |
| 操作系统        | CentOS 7 / RHEL 7                        |
| FineBI 安装路径 | `/home/FineBI6.1`                        |
| 脚本路径        | `/home/FineBI6.1/bin/restart_finebi.sh`  |
| 日志路径        | `/home/FineBI6.1/bin/restart_finebi.log` |
| 执行用户        | root                                     |

### 三、脚本内容

#### 文件：`/home/FineBI6.1/bin/restart_finebi.sh`

```
#!/bin/bash

# FineBI 每周重启脚本
# 功能：杀死进程、备份日志、重启服务

FINEBI_HOME="/home/FineBI6.1"
BIN_DIR="${FINEBI_HOME}/bin"

cd "$BIN_DIR"

# 日志函数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "========== FineBI 重启任务开始 =========="

# 1. 获取 FineBI 进程 PID
PID=$(ps -ef | grep "${FINEBI_HOME}/bin/finebi" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    log_message "未找到 FineBI 进程，直接启动服务..."
else
    log_message "找到 FineBI 进程 PID: $PID"
    
    # 2. 杀死进程（先优雅关闭）
    log_message "正在停止 FineBI 进程..."
    kill $PID
    
    # 等待进程结束（最多等待30秒）
    for i in {1..30}; do
        if ! ps -p $PID > /dev/null 2>&1; then
            log_message "进程 $PID 已成功停止"
            break
        fi
        sleep 1
    done
    
    # 如果进程还在，强制杀死
    if ps -p $PID > /dev/null 2>&1; then
        log_message "进程未响应，使用 kill -9 强制终止..."
        kill -9 $PID
        sleep 2
        log_message "进程已被强制终止"
    fi
fi

# 3. 确认进程已杀死
sleep 2
REMAIN_PID=$(ps -ef | grep "${FINEBI_HOME}/bin/finebi" | grep -v grep | awk '{print $2}')
if [ -z "$REMAIN_PID" ]; then
    log_message "确认：FineBI 进程已清理完毕"
else
    log_message "警告：仍有进程存在 PID: $REMAIN_PID"
    exit 1
fi

# 4. 备份日志文件（使用 mv 移动文件）
if [ -f "output.log" ]; then
    BACKUP_FILE="output.log_$(date '+%Y%m%d_%H%M%S')"
    log_message "正在备份日志文件: $BACKUP_FILE"
    mv output.log "$BACKUP_FILE"
    log_message "日志备份完成，原文件已重命名为: $BACKUP_FILE"
else
    log_message "警告：output.log 文件不存在"
fi

# 5. 启动 FineBI（启动时会自动生成新的 output.log）
log_message "正在启动 FineBI 服务..."
nohup ./finebi > output.log 2>&1 &

# 等待启动
sleep 5

# 6. 验证启动是否成功
NEW_PID=$(ps -ef | grep "${FINEBI_HOME}/bin/finebi" | grep -v grep | awk '{print $2}')
if [ -n "$NEW_PID" ]; then
    log_message "FineBI 启动成功！新进程 PID: $NEW_PID"
    log_message "新的 output.log 已自动生成"
else
    log_message "错误：FineBI 启动失败，请检查日志"
    exit 1
fi

log_message "========== FineBI 重启任务完成 =========="
```



### 四、脚本功能说明

| 步骤 | 操作         | 说明                                                      |
| :--- | :----------- | :-------------------------------------------------------- |
| 1    | 获取进程 PID | 通过进程路径精确匹配 FineBI 进程                          |
| 2    | 停止服务     | 先使用 `kill` 优雅停止，30秒超时后使用 `kill -9` 强制停止 |
| 3    | 确认停止     | 验证进程是否完全终止                                      |
| 4    | 备份日志     | 使用 `mv` 将 `output.log` 重命名为带时间戳的备份文件      |
| 5    | 启动服务     | 使用 `nohup` 后台启动，日志输出到新生成的 `output.log`    |
| 6    | 验证启动     | 检查新进程是否成功启动                                    |

### 五、定时任务配置

#### 查看当前定时任务

```
crontab -l
```



#### 定时任务内容

```
# 每周日凌晨 0:00 重启 FineBI
0 0 * * 0 /home/FineBI6.1/bin/restart_finebi.sh >> /home/FineBI6.1/bin/restart_finebi.log 2>&1
```



#### Crontab 时间格式说明

```
* * * * * 命令
│ │ │ │ │
│ │ │ │ └─── 星期几 (0-7, 0和7都代表周日)
│ │ │ └───── 月份 (1-12)
│ │ └─────── 日期 (1-31)
│ └───────── 小时 (0-23)
└─────────── 分钟 (0-59)
```



#### 常用时间配置示例

| 需求              | Crontab 配置  |
| :---------------- | :------------ |
| 每周日凌晨 0:00   | `0 0 * * 0`   |
| 每周六和周日 0:00 | `0 0 * * 6,0` |
| 每天凌晨 3:00     | `0 3 * * *`   |
| 每月1号凌晨 2:00  | `0 2 1 * *`   |

### 六、部署步骤

#### 1. 创建脚本文件

```
vi /home/FineBI6.1/bin/restart_finebi.sh
# 粘贴脚本内容
```



#### 2. 设置执行权限

```
chmod +x /home/FineBI6.1/bin/restart_finebi.sh
```



#### 3. 手动测试脚本

```
/home/FineBI6.1/bin/restart_finebi.sh
```



#### 4. 添加定时任务

```
crontab -e
# 添加定时任务配置
```



#### 5. 验证定时任务

```
crontab -l
systemctl status crond
```



### 七、常用管理命令

#### 脚本管理

```
# 手动执行重启
/home/FineBI6.1/bin/restart_finebi.sh

# 查看执行日志
tail -f /home/FineBI6.1/bin/restart_finebi.log

# 查看备份文件
ls -lh /home/FineBI6.1/bin/output.log_*
```



#### 定时任务管理

```
# 编辑定时任务
crontab -e

# 查看定时任务
crontab -l

# 删除所有定时任务（谨慎使用）
crontab -r
```



#### 进程管理

```
# 查看 FineBI 进程
ps -ef | grep finebi | grep -v grep

# 查看进程端口（如有需要）
netstat -tlnp | grep java

# 查看服务状态（如有 systemd 服务）
systemctl status finebi
```



#### Cron 服务管理

```
# 查看 cron 状态
systemctl status crond

# 重启 cron 服务
systemctl restart crond

# 查看 cron 日志
tail -f /var/log/cron
```



### 八、验证测试

测试任务配置（9:46 执行）：

```
46 9 * * * /home/FineBI6.1/bin/restart_finebi.sh >> /home/FineBI6.1/bin/restart_finebi.log 2>&1
```



测试结果：✅ 执行正常

### 九、注意事项

1. **首次执行时间**：配置完成后，将在本周日（2026年6月7日）凌晨 0:00 首次自动执行

2. **日志备份**：每次重启会生成带时间戳的备份文件，建议定期清理：

   ```
   # 删除30天前的备份文件
   find /home/FineBI6.1/bin/ -name "output.log_*" -mtime +30 -delete
   ```

   

3. **磁盘空间**：注意监控 `/home/FineBI6.1/bin` 目录的磁盘使用情况，避免备份文件过多

4. **业务影响**：重启期间服务将不可用（约1-2分钟），建议在业务低峰期执行

5. **脚本并发**：如果担心脚本执行时间过长，可考虑添加文件锁机制

6. **环境变量**：如果 FineBI 依赖特定环境变量，可在脚本开头添加 `source /etc/profile`

### 十、故障排查

| 问题           | 可能原因          | 解决方法                   |
| :------------- | :---------------- | :------------------------- |
| 定时任务未执行 | cron 服务未运行   | `systemctl start crond`    |
| 脚本无执行权限 | 权限未设置        | `chmod +x script.sh`       |
| 进程未杀死     | 进程僵死          | 使用 `kill -9` 强制终止    |
| 启动失败       | 端口占用/配置错误 | 检查 `output.log` 错误信息 |
| 日志未记录     | 路径错误          | 检查脚本中的路径配置       |

### 十一、文件清单

| 文件路径                                 | 说明            |
| :--------------------------------------- | :-------------- |
| `/home/FineBI6.1/bin/restart_finebi.sh`  | 重启脚本        |
| `/home/FineBI6.1/bin/restart_finebi.log` | 脚本执行日志    |
| `/home/FineBI6.1/bin/output.log`         | FineBI 运行日志 |
| `/home/FineBI6.1/bin/output.log_*`       | 历史备份日志    |

### 十二、附录

#### 脚本执行示例输出

```
[2026-06-07 00:00:01] ========== FineBI 重启任务开始 ==========
[2026-06-07 00:00:01] 找到 FineBI 进程 PID: 711036
[2026-06-07 00:00:01] 正在停止 FineBI 进程...
[2026-06-07 00:00:03] 进程 711036 已成功停止
[2026-06-07 00:00:05] 确认：FineBI 进程已清理完毕
[2026-06-07 00:00:05] 正在备份日志文件: output.log_20260607_000005
[2026-06-07 00:00:05] 日志备份完成，原文件已重命名为: output.log_20260607_000005
[2026-06-07 00:00:05] 正在启动 FineBI 服务...
[2026-06-07 00:00:10] FineBI 启动成功！新进程 PID: 712345
[2026-06-07 00:00:10] 新的 output.log 已自动生成
[2026-06-07 00:00:10] ========== FineBI 重启任务完成 ==========
```