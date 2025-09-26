# PM2 自动重启配置总结

## 配置过程概述

已成功配置 PM2 在服务器重启后自动重启 Node.js 服务。以下是完整的配置步骤和验证结果。

## 执行步骤

### 1. 启动应用

```shell
pm2 start ecosystem.config.js

[root@cd91 nodeService]# pm2 list
┌────┬─────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id │ name            │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├────┼─────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0  │ node-service    │ default     │ 1.0.0   │ cluster │ 52017    │ 91s    │ 0    │ online    │ 0%       │ 65.8mb   │ root     │ enabled  │
│ 1  │ node-service    │ default     │ 1.0.0   │ cluster │ 52024    │ 91s    │ 0    │ online    │ 0%       │ 81.0mb   │ root     │ enabled  │
│ 2  │ node-service    │ default     │ 1.0.0   │ cluster │ 52031    │ 91s    │ 0    │ online    │ 0%       │ 64.7mb   │ root     │ enabled  │
│ 3  │ node-service    │ default     │ 1.0.0   │ cluster │ 52038    │ 91s    │ 0    │ online    │ 0%       │ 80.8mb   │ root     │ enabled  │
│ 4  │ node-service    │ default     │ 1.0.0   │ cluster │ 52049    │ 91s    │ 0    │ online    │ 0%       │ 82.3mb   │ root     │ enabled  │
│ 5  │ node-service    │ default     │ 1.0.0   │ cluster │ 52081    │ 90s    │ 0    │ online    │ 0%       │ 79.5mb   │ root     │ enabled  │
│ 6  │ node-service    │ default     │ 1.0.0   │ cluster │ 52194    │ 90s    │ 0    │ online    │ 0%       │ 80.8mb   │ root     │ enabled  │
│ 7  │ node-service    │ default     │ 1.0.0   │ cluster │ 52250    │ 90s    │ 0    │ online    │ 0%       │ 80.5mb   │ root     │ enabled  │
│ 8  │ node-service    │ default     │ 1.0.0   │ cluster │ 52300    │ 90s    │ 0    │ online    │ 0%       │ 65.3mb   │ root     │ enabled  │
│ 9  │ node-service    │ default     │ 1.0.0   │ cluster │ 52362    │ 90s    │ 0    │ online    │ 0%       │ 80.8mb   │ root     │ enabled  │
│ 10 │ node-service    │ default     │ 1.0.0   │ cluster │ 52406    │ 90s    │ 0    │ online    │ 0%       │ 81.1mb   │ root     │ enabled  │
│ 11 │ node-service    │ default     │ 1.0.0   │ cluster │ 52446    │ 90s    │ 0    │ online    │ 0%       │ 81.0mb   │ root     │ enabled  │
└────┴─────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘

# 成功启动 12 个集群实例
# 应用名称：`node-service`
# 运行模式：cluster 模式
# 所有实例状态：online
```



### 2. 保存当前配置

```shell
[root@cd91 nodeService]# pm2 save
[PM2] Saving current process list...
[PM2] Successfully saved in /root/.pm2/dump.pm2

# 配置已保存至：`/root/.pm2/dump.pm2`
```



### 3. 设置开机自启动

```shell
[root@cd91 nodeService]# pm2 startup
[PM2] Init System found: systemd
Platform systemd
Template
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User=root
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PATH=/root/.nvm/versions/node/v16.20.2/bin:/root/.nvm/versions/node/v16.20.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
Environment=PM2_HOME=/root/.pm2
PIDFile=/root/.pm2/pm2.pid
Restart=on-failure

ExecStart=/root/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 resurrect
ExecReload=/root/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 reload all
ExecStop=/root/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 kill

[Install]
WantedBy=multi-user.target

Target path
/etc/systemd/system/pm2-root.service
Command list
[ 'systemctl enable pm2-root' ]
[PM2] Writing init configuration in /etc/systemd/system/pm2-root.service
[PM2] Making script booting at startup...
[PM2] [-] Executing: systemctl enable pm2-root...
Created symlink from /etc/systemd/system/multi-user.target.wants/pm2-root.service to /etc/systemd/system/pm2-root.service.
[PM2] [v] Command successfully executed.
+---------------------------------------+
[PM2] Freeze a process list on reboot via:
$ pm2 save

[PM2] Remove init script via:
$ pm2 unstartup systemd


# 检测到系统使用：systemd
# 生成服务文件：`/etc/systemd/system/pm2-root.service`
# 自动启用服务：`systemctl enable pm2-root`
```



### 4. 验证配置

```shell
# 停止所有 PM2 进程
[root@cd91 nodeService]# pm2 kill
[PM2] Applying action deleteProcessId on app [all](ids: [
   0,  1, 2, 3, 4,
   5,  6, 7, 8, 9,
  10, 11
])
[PM2] [node-service](3) ✓
[PM2] [node-service](2) ✓
[PM2] [node-service](1) ✓
[PM2] [node-service](0) ✓
[PM2] [node-service](5) ✓
[PM2] [node-service](4) ✓
[PM2] [node-service](6) ✓
[PM2] [node-service](7) ✓
[PM2] [node-service](9) ✓
[PM2] [node-service](8) ✓
[PM2] [node-service](10) ✓
[PM2] [node-service](11) ✓
[PM2] [v] All Applications Stopped
[PM2] [v] PM2 Daemon Stopped
[root@cd91 nodeService]# pm2 list
[PM2] Spawning PM2 daemon with pm2_home=/root/.pm2
[PM2] PM2 Successfully daemonized
┌────┬───────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id │ name      │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
└────┴───────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘

# 恢复保存的进程
[root@cd91 nodeService]# pm2 resurrect
[PM2] Resurrecting
[PM2] Restoring processes located in /root/.pm2/dump.pm2
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
[PM2] Process /home/nodeService/bin/www restored
┌────┬─────────────────┬─────────────┬─────────┬─────────┬──────────┬────────┬──────┬───────────┬──────────┬──────────┬──────────┬──────────┐
│ id │ name            │ namespace   │ version │ mode    │ pid      │ uptime │ ↺    │ status    │ cpu      │ mem      │ user     │ watching │
├────┼─────────────────┼─────────────┼─────────┼─────────┼──────────┼────────┼──────┼───────────┼──────────┼──────────┼──────────┼──────────┤
│ 0  │ node-service    │ default     │ 1.0.0   │ cluster │ 104372   │ 0s     │ 0    │ online    │ 0%       │ 61.0mb   │ root     │ enabled  │
│ 1  │ node-service    │ default     │ 1.0.0   │ cluster │ 104373   │ 0s     │ 0    │ online    │ 0%       │ 61.2mb   │ root     │ enabled  │
│ 2  │ node-service    │ default     │ 1.0.0   │ cluster │ 104386   │ 0s     │ 0    │ online    │ 0%       │ 53.1mb   │ root     │ enabled  │
│ 3  │ node-service    │ default     │ 1.0.0   │ cluster │ 104392   │ 0s     │ 0    │ online    │ 0%       │ 53.6mb   │ root     │ enabled  │
│ 4  │ node-service    │ default     │ 1.0.0   │ cluster │ 104400   │ 0s     │ 0    │ online    │ 0%       │ 50.3mb   │ root     │ enabled  │
│ 5  │ node-service    │ default     │ 1.0.0   │ cluster │ 104401   │ 0s     │ 0    │ online    │ 0%       │ 49.4mb   │ root     │ enabled  │
│ 6  │ node-service    │ default     │ 1.0.0   │ cluster │ 104422   │ 0s     │ 0    │ online    │ 0%       │ 44.7mb   │ root     │ enabled  │
│ 7  │ node-service    │ default     │ 1.0.0   │ cluster │ 104423   │ 0s     │ 0    │ online    │ 0%       │ 46.5mb   │ root     │ enabled  │
│ 8  │ node-service    │ default     │ 1.0.0   │ cluster │ 104444   │ 0s     │ 0    │ online    │ 0%       │ 42.6mb   │ root     │ enabled  │
│ 9  │ node-service    │ default     │ 1.0.0   │ cluster │ 104445   │ 0s     │ 0    │ online    │ 0%       │ 43.9mb   │ root     │ enabled  │
│ 10 │ node-service    │ default     │ 1.0.0   │ cluster │ 104474   │ 0s     │ 0    │ online    │ 0%       │ 34.8mb   │ root     │ enabled  │
│ 11 │ node-service    │ default     │ 1.0.0   │ cluster │ 104486   │ 0s     │ 0    │ online    │ 0%       │ 35.0mb   │ root     │ enabled  │
└────┴─────────────────┴─────────────┴─────────┴─────────┴──────────┴────────┴──────┴───────────┴──────────┴──────────┴──────────┴──────────┘
[root@cd91 nodeService]# 

# 成功从 `/root/.pm2/dump.pm2` 恢复 12 个实例
# 所有服务正常启动，状态为 online
```



## 系统服务配置详情

### PM2 系统服务文件

**位置：** `/etc/systemd/system/pm2-root.service`

**配置内容：**

```
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User=root
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PATH=/root/.nvm/versions/node/v16.20.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
Environment=PM2_HOME=/root/.pm2
PIDFile=/root/.pm2/pm2.pid
Restart=on-failure

ExecStart=/root/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 resurrect
ExecReload=/root/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 reload all
ExecStop=/root/.nvm/versions/node/v16.20.2/lib/node_modules/pm2/bin/pm2 kill

[Install]
WantedBy=multi-user.target
```



## 当前运行状态

### 应用信息

- **应用名称：** node-service

- **版本：** 1.0.0

- **运行模式：** cluster 模式

- **实例数量：** 12 个

- **内存使用：** 34-61MB/实例

- **CPU 使用：** 0%

- **运行状态：** 所有实例正常在线

  

### 监控命令

```
# 查看应用列表
pm2 list

# 查看应用状态
pm2 status

# 查看实时日志
pm2 logs

# 查看特定应用信息
pm2 show node-service
```



## 重启测试

服务器重启后，PM2 将自动执行：

1. 系统启动时自动运行 `pm2-root` 服务

2. 服务执行 `pm2 resurrect` 命令

3. 从 `/root/.pm2/dump.pm2` 恢复所有保存的应用

4. 12 个 node-service 实例将自动启动

   

## 故障排除

如果重启后服务未自动启动，可手动检查：

```
# 检查 PM2 服务状态
systemctl status pm2-root

# 手动恢复进程
pm2 resurrect

# 重新保存配置
pm2 save

# 重新设置开机启动
pm2 unstartup systemd
pm2 startup
```



停止并移除pm2服务，并关闭开机自启

```shell
#!/bin/bash
# cleanup-node-service.sh

echo "开始清理 Node.js 服务..."

# 停止并删除 PM2 服务
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pm2 kill 2>/dev/null

# 移除开机自启
pm2 unstartup 2>/dev/null
systemctl disable pm2-root 2>/dev/null
rm -f /etc/systemd/system/pm2-root.service 2>/dev/null
systemctl daemon-reload

# 杀死所有 Node 进程
pkill -f node 2>/dev/null

# 删除文件和目录
rm -rf /root/.pm2
rm -rf /home/4.5/nodeService
rm -rf /usr/local/nodejs
rm -f /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npm
rm -f /usr/local/bin/pm2*

# 清理环境变量
sed -i '/\/usr\/local\/nodejs\/bin/d' ~/.bashrc
source ~/.bashrc

echo "清理完成！"
```



## 总结

✅ **配置成功** - PM2 已正确设置为在服务器重启后自动恢复所有 Node.js 服务实例。系统使用 systemd 来管理 PM2 守护进程，确保服务的高可用性。