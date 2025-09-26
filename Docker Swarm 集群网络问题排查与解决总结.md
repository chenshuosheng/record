# Docker Swarm 集群网络问题排查与解决总结

## 📋 问题概述

在构建 Docker Swarm 集群过程中，遇到了复杂的网络连通性问题，涉及 Overlay 网络、VXLAN 通信、容器间访问、跨节点通信等多个方面。

## 🔧 主要问题及解决方案

### 1. 初始网络环境清理

#### 问题描述

- 存在残留的 Docker 网络和 iptables 规则
- 可能影响新集群的网络通信

#### 解决方案

```
# 清理未使用的网络
docker network prune

# 检查并清理残留规则
docker network ls | grep -v "bridge\|host\|none" | awk 'NR>1 {print $1}' | xargs -r docker network rm
```



### 2. Swarm 集群初始化

#### 集群创建

```
# 在管理节点初始化
docker swarm init --advertise-addr <MANAGER_IP>

# 工作节点加入
docker swarm join --token <TOKEN> <MANAGER_IP>:2377
```



#### Overlay 网络创建

```
sudo docker network create     --driver overlay     --opt encrypted     --subnet=172.16.0.0/16     --ip-range=172.16.0.0/20     --gateway=172.16.0.1     --attachable     servicenet
```



### 3. VXLAN 网络通信问题

#### 问题现象

- 容器间跨节点通信失败
- `nc -zv` 测试显示 "No route to host"
- VXLAN 接口在主机网络命名空间不可见

#### 根本原因

- 复杂的 iptables u32 匹配规则阻塞了 VXLAN 端口 4789
- 节点间路由配置问题

#### 解决方案

```
# 清理干扰的 iptables 规则
sudo iptables -L -n --line-numbers | grep -E "4789.*u32" | awk '{print $1}' | tac | while read line; do
    sudo iptables -D INPUT $line 2>/dev/null
done

# 添加明确的允许规则
sudo iptables -I INPUT -p udp --dport 4789 -j ACCEPT
sudo iptables -I FORWARD -p udp --dport 4789 -j ACCEPT
sudo iptables -I INPUT -s 10.20.27.0/24 -j ACCEPT
sudo iptables -I FORWARD -s 10.20.27.0/24 -d 10.20.27.0/24 -j ACCEPT
```



### 4. 容器服务连通性测试

#### 测试矩阵及结果

| 测试场景            | 测试命令                 | 结果   | 解决方案        |
| :------------------ | :----------------------- | :----- | :-------------- |
| **同节点容器间**    | `docker exec A → B:端口` | ✅ 成功 | -               |
| **跨节点容器间**    | `docker exec A → B:端口` | ❌ 失败 | 修复 VXLAN 规则 |
| **容器→宿主机服务** | `容器 → 宿主机IP:端口`   | ❌ 失败 | 使用特殊主机名  |
| **宿主机→容器**     | `宿主机 → 容器IP:端口`   | ✅ 成功 | -               |

### 5. 容器访问宿主机服务问题

#### 问题现象

- 容器无法通过宿主机 IP 访问宿主机上的服务
- 错误信息："No route to host"

#### 解决方案

```
# 使用 Docker 特殊主机名
docker exec container bash -c "</dev/tcp/host.docker.internal/端口"

# 使用 Docker 网桥网关
docker exec container bash -c "</dev/tcp/172.17.0.1/端口"

# 获取实际网桥 IP
ip addr show docker0 | grep inet
```



### 6. PostgreSQL 容器端口映射问题

#### 问题现象

- Nacos 无法连接 PostgreSQL
- PostgreSQL 只映射了宿主机端口，未暴露给 Docker 网络

#### 解决方案

```
# 修改端口映射配置
ports:
  - "23456:5432"  # 宿主机访问
  - "5432:5432"   # Docker 网络内部访问
```



## 🛠️ 关键技术点总结

### 1. 网络诊断命令

```
# 检查网络状态
docker network inspect servicenet
ip link show | grep vxlan

# 检查网络命名空间
sudo ls /var/run/docker/netns/
sudo nsenter --net=/var/run/docker/netns/<ns> ip link show

# 连通性测试
docker exec container bash -c "timeout 5 bash -c '</dev/tcp/目标/端口'"
```



### 2. 防火墙规则管理

```
# 检查规则
iptables -L -n --line-numbers | grep 4789

# 保存规则持久化
iptables-save > /etc/sysconfig/iptables
```



### 3. 服务发现测试

```
# DNS 解析测试
docker exec container nslookup 服务名

# 服务发现
nslookup tasks.服务名
```



## 📊 问题解决流程

### 第一阶段：环境准备

1. ✅ 清理现有网络环境
2. ✅ 初始化 Swarm 集群
3. ✅ 创建 Overlay 网络

### 第二阶段：基础连通性

1. ✅ 同节点容器间通信
2. ❌ 跨节点容器间通信 → 修复 VXLAN
3. ✅ 数据库连接配置

### 第三阶段：高级连通性

1. ❌ 容器访问宿主机服务 → 使用特殊主机名
2. ✅ 服务发现和负载均衡
3. ✅ 应用层连通性验证

## 🎯 经验教训

### 1. 网络规划重要性

- 提前规划子网段，避免冲突
- 明确端口映射策略（内部 vs 外部）

### 2. 排查方法系统性

- 从简单到复杂逐步排查
- 建立完整的测试矩阵
- 使用分层诊断方法

### 3. 工具使用技巧

- 熟练掌握 `docker exec` 进行容器内测试
- 善用 `jq` 解析 JSON 输出
- 掌握网络命名空间操作

### 4. 预防措施

```
# 创建网络健康监控脚本
#!/bin/bash
# 定期检查 VXLAN 连通性
# 监控 iptables 规则变化
# 日志记录和告警
```



## ✅ 最终验证清单

- Swarm 集群状态正常
- Overlay 网络创建成功
- 跨节点容器通信正常
- 服务发现机制工作
- 应用层服务连通性
- 防火墙规则优化
- 网络配置持久化

## 🔧 预防性维护建议

1. **定期检查网络状态**
2. **监控 VXLAN 连通性**
3. **备份网络配置**
4. **建立快速恢复脚本**
5. **文档化网络架构**