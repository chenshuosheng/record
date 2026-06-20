# PM2 配置文件重载命令对比

## 命令说明

| 命令                                              | 重启方式               | 服务影响         | 适用场景       |
| ------------------------------------------------- | ---------------------- | ---------------- | -------------- |
| `pm2 reload ecosystem.config.js`                  | 零停机重启，配置热更新 | 无服务中断       | 生产环境部署   |
| `pm2 restart ecosystem.config.js`                 | 硬重启                 | 服务短暂中断     | 开发环境       |
| `pm2 start ecosystem.config.js`                   | 启动新进程，不停止旧的 | 可能导致重复进程 | 不推荐直接使用 |
| `pm2 delete app && pm2 start ecosystem.config.js` | 完全重新启动           | 服务中断         | 配置重大变更时 |



## 详细说明

### 🔄 `pm2 reload ecosystem.config.js`
- **重启方式**: 零停机重启 (Graceful reload)
- **服务影响**: 无服务中断
- **执行流程**: 
  - 启动新进程 → 等待就绪 → 关闭旧进程
  - 如果新进程启动失败，自动回滚到旧进程
- **适用场景**: 生产环境部署、配置热更新

### ⚡ `pm2 restart ecosystem.config.js`
- **重启方式**: 硬重启
- **服务影响**: 服务短暂中断
- **执行流程**: 直接停止所有进程 → 启动新进程
- **适用场景**: 开发环境、非关键服务重启

### 🚫 `pm2 start ecosystem.config.js`
- **重启方式**: 启动新进程，不停止旧的
- **服务影响**: 可能导致端口冲突和重复进程
- **执行流程**: 直接启动新进程，原有进程继续运行
- **建议**: 一般不推荐直接使用此命令

### 🔄 `pm2 delete app && pm2 start ecosystem.config.js`
- **重启方式**: 完全重新启动
- **服务影响**: 服务完全中断
- **执行流程**: 删除所有相关进程 → 重新启动
- **适用场景**: 配置重大变更、彻底清理环境



## 使用建议

### 生产环境推荐
```bash
# 日常部署和配置更新
pm2 reload ecosystem.config.js

# 验证配置
pm2 list
pm2 logs app-name --lines 10
```

p-name && pm2 start ecosystem.config.js