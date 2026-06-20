# Docker Swarm Overlay 网络完整部署与故障排查指南

## 一、核心问题：BPF 规则的产生与影响

### 1.1 问题现象

在 Docker Swarm 集群中，某些节点的 iptables 会出现 BPF 规则：

```
-A INPUT -p udp -m policy --dir in --pol none -m udp --dport 4789 -m bpf --bytecode "..." -j DROP
-A OUTPUT -p udp -m udp --dport 4789 -m bpf --bytecode "..." -j MARK --set-xmark 0xd0c4e3/0xffffffff
```



### 1.2 根本原因

**BPF 规则由 `--opt encrypted` 参数触发**，与 Docker 版本或节点角色无关。

| 网络配置             | BPF 规则 | VXLAN 加密 |
| :------------------- | :------- | :--------- |
| 有 `--opt encrypted` | ✅ 出现   | 启用       |
| 无 `--opt encrypted` | ❌ 不出现 | 禁用       |

**验证方法：**

```
docker network inspect servicenet | grep -i encrypted
# 有 "encrypted": "" → 会产生 BPF 规则
# 无此字段 → 不会产生 BPF 规则
```



### 1.3 解决方案

**删除 `--opt encrypted` 参数重建网络：**

```
# 删除现有网络
docker network rm servicenet

# 重建（不加密）
docker network create \
    --driver overlay \
    --subnet=10.0.0.0/16 \
    --ip-range=10.0.5.0/24 \
    --gateway=10.0.5.254 \
    --attachable \
    servicenet
```



------

## 二、Docker Swarm 集群部署

### 2.1 环境准备

#### 主机名配置（关键！）

**所有节点必须配置唯一主机名并互相解析：**

```
# 设置唯一主机名
sudo hostnamectl set-hostname node1   # 节点1执行
sudo hostnamectl set-hostname node2   # 节点2执行
sudo hostnamectl set-hostname node3   # 节点3执行

# 所有节点配置 hosts 解析（内容一致）
sudo tee -a /etc/hosts <<EOF
10.6.56.48 node1
10.6.56.49 node2
10.6.56.50 node3
EOF

# 重启 Docker 使主机名生效
sudo systemctl restart docker
```



#### 防火墙配置（所有节点）

```
# Docker Swarm 所需端口
sudo firewall-cmd --permanent --add-port=2377/tcp   # 集群管理
sudo firewall-cmd --permanent --add-port=7946/tcp   # 控制平面
sudo firewall-cmd --permanent --add-port=7946/udp   # 控制平面
sudo firewall-cmd --permanent --add-port=4789/udp   # VXLAN
sudo firewall-cmd --reload
```



### 2.2 初始化 Swarm 集群

```
# 在 Leader 节点执行
docker swarm init --advertise-addr 10.6.56.48

# 输出示例：
# Swarm initialized: current node is now a manager.
# To add a worker to this swarm, run:
# docker swarm join --token <TOKEN> 10.6.56.48:2377
```



### 2.3 加入工作节点

```
# 在工作节点执行（建议指定 --advertise-addr）
docker swarm join \
    --token <TOKEN> \
    --advertise-addr 10.6.56.49 \
    10.6.56.48:2377
```



### 2.4 提升为管理节点（可选）

```
# 在 Leader 节点执行
docker node ls                      # 查看节点 ID
docker node promote <NODE_ID>       # 提升为管理节点
```



------

## 三、Overlay 网络创建脚本

### 3.1 配置文件 `config.sh`

```
#!/bin/bash
# config.sh - 集群配置

# 节点 IP（根据实际修改）
NODE1_IP="10.6.56.48"
NODE2_IP="10.6.56.49"
NODE3_IP="10.6.56.50"

# 网络配置
OVERLAY_NETWORK_NAME="servicenet"
OVERLAY_SUBNET="10.0.0.0/16"
OVERLAY_IP_RANGE="10.0.5.0/24"
OVERLAY_GATEWAY="10.0.5.254"

# 是否启用加密（默认 false，避免 BPF 规则）
ENABLE_ENCRYPTION=false
```



### 3.2 网络创建脚本 `create-network.sh`

```
#!/bin/bash
# create-network.sh - 在管理节点执行

set -e

SCRIPT_DIR=$(dirname $(readlink -f $0))
source $SCRIPT_DIR/config.sh

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 检查 Swarm 状态
SWARM_STATUS=$(docker info 2>/dev/null | grep -i "Swarm:" | awk '{print $2}')
if [[ "$SWARM_STATUS" != "active" ]]; then
    print_warn "Swarm not active, initializing..."
    docker swarm init --advertise-addr $NODE1_IP
fi

# 检查是否为管理节点
NODE_ROLE=$(docker info 2>/dev/null | grep -i "Role:" | awk '{print $2}')
if [[ "$NODE_ROLE" != "manager" ]]; then
    print_warn "This node is not a manager, cannot create network"
    exit 1
fi

# 创建网络
print_info "Creating overlay network: $OVERLAY_NETWORK_NAME"

ENCRYPT_OPT=""
if [ "$ENABLE_ENCRYPTION" = true ]; then
    ENCRYPT_OPT="--opt encrypted"
    print_warn "Encryption enabled (BPF rules will be generated)"
else
    print_info "Encryption disabled (no BPF rules)"
fi

# 删除已存在的网络
if docker network inspect $OVERLAY_NETWORK_NAME &>/dev/null; then
    print_warn "Network already exists, removing..."
    docker network rm $OVERLAY_NETWORK_NAME
    sleep 2
fi

# 创建网络
docker network create \
    --driver overlay \
    $ENCRYPT_OPT \
    --subnet=$OVERLAY_SUBNET \
    --ip-range=$OVERLAY_IP_RANGE \
    --gateway=$OVERLAY_GATEWAY \
    --attachable \
    $OVERLAY_NETWORK_NAME

print_info "Network created successfully"
docker network inspect $OVERLAY_NETWORK_NAME --format='  Subnet: {{.IPAM.Config.0.Subnet}}'
docker network inspect $OVERLAY_NETWORK_NAME --format='  Encrypted: {{.Options.encrypted}}'

# 验证 BPF 规则
print_info "Checking BPF rules..."
if iptables-save 2>/dev/null | grep -q "bpf.*4789"; then
    print_warn "BPF rules detected (encryption is enabled)"
else
    print_info "No BPF rules found ✓"
fi
```



------

## 四、网络故障排查

### 4.1 诊断命令速查

```
# 1. 检查 Swarm 状态
docker info | grep -E "Swarm:|Role:|Node Address"

# 2. 检查网络
docker network ls | grep overlay
docker network inspect servicenet

# 3. 检查 VXLAN 端口规则
iptables -L INPUT -n -v --line-numbers | grep 4789

# 4. 测试跨节点容器通信
docker exec <容器名> bash -c "timeout 5 bash -c '</dev/tcp/<服务名>/<端口>' && echo OK || echo FAIL"

# 5. 检查防火墙
firewall-cmd --list-ports
```



### 4.2 关键判断：iptables 计数器

```
iptables -L INPUT -n -v --line-numbers | grep 4789
```



**解读：**

- `pkts` 和 `bytes` 非零 → 流量正常
- `pkts` 为 0 → VXLAN 流量未到达该节点

### 4.3 常见问题与解决

| 问题                   | 可能原因               | 解决方案                                    |
| :--------------------- | :--------------------- | :------------------------------------------ |
| 跨节点容器通信失败     | VXLAN 端口阻塞         | `firewall-cmd --add-port=4789/udp`          |
| 容器访问宿主机服务失败 | 网络隔离               | 使用 `host.docker.internal` 或 `172.17.0.1` |
| 节点无法加入集群       | 端口未开放或主机名问题 | 检查防火墙和 `/etc/hosts`                   |
| BPF 规则不期望出现     | 网络启用了加密         | 删除 `--opt encrypted` 重建                 |

### 4.4 完整网络重置

```
#!/bin/bash
# 在所有节点执行

# 1. 离开 Swarm
docker swarm leave --force

# 2. 清理 Docker 网络状态
sudo systemctl stop docker
sudo rm -rf /var/lib/docker/network/files/local-kv.db
sudo rm -rf /var/run/docker/netns/*

# 3. 清理 iptables（可选，谨慎使用）
sudo iptables -F
sudo iptables -t nat -F

# 4. 重启 Docker
sudo systemctl start docker

# 5. 重新初始化或加入集群
# 在 Leader 节点：docker swarm init --advertise-addr <IP>
# 在工作节点：docker swarm join --token <TOKEN> <LEADER_IP>:2377 --advertise-addr <本机IP>
```



------

## 五、节点管理命令

### 5.1 集群管理

```
# 查看所有节点
docker node ls

# 提升/降级节点
docker node promote <NODE_ID>
docker node demote <NODE_ID>

# 离开集群
docker swarm leave              # 工作节点
docker swarm leave --force      # 管理节点

# 删除离线节点
docker node rm <NODE_ID>
```



### 5.2 获取加入令牌

```
docker swarm join-token worker   # 工作节点令牌
docker swarm join-token manager  # 管理节点令牌
```



------

## 六、最佳实践

### 6.1 网络规划

| 配置项  | 推荐值        | 说明                              |
| :------ | :------------ | :-------------------------------- |
| 子网    | `10.0.0.0/16` | 避开 172.16.0.0/16（Docker 默认） |
| IP 范围 | `10.0.5.0/24` | 限制分配范围                      |
| 网关    | `10.0.5.254`  | 网络内的网关地址                  |
| 加密    | `false`       | 无加密需求时禁用，避免 BPF 规则   |

### 6.2 部署检查清单

- 所有节点主机名唯一且互相解析
- 防火墙开放 2377、7946、4789 端口
- 节点间时间同步（chrony）
- 使用 `--advertise-addr` 指定正确 IP
- Overlay 网络创建时确认加密选项

### 6.3 持久化防火墙规则

```
# 使用 firewalld 直接规则（重启后保留）
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p udp --dport 4789 -j ACCEPT
firewall-cmd --reload
```



------

## 七、命令速查表

| 操作              | 命令                                                         |
| :---------------- | :----------------------------------------------------------- |
| 初始化 Swarm      | `docker swarm init --advertise-addr <IP>`                    |
| 加入集群          | `docker swarm join --token <TOKEN> <IP>:2377 --advertise-addr <IP>` |
| 创建 Overlay 网络 | `docker network create --driver overlay --subnet=<CIDR> --attachable <名称>` |
| 查看网络          | `docker network ls`                                          |
| 查看网络详情      | `docker network inspect <名称>`                              |
| 查看节点          | `docker node ls`                                             |
| 测试容器连接      | `docker exec <容器> sh -c "timeout 5 nc -zv <目标> <端口>"`  |
| 检查 BPF 规则     | `iptables-save | grep "bpf.*4789"`                           |
| 离开集群          | `docker swarm leave --force`                                 |

------



## 八、总结

1. **BPF 规则由 `--opt encrypted` 触发**，无加密需求时不要使用该参数
2. **主机名配置是常见问题**，确保所有节点 `/etc/hosts` 内容一致
3. **加入集群时必须指定 `--advertise-addr`**，否则可能导致通信异常
4. **iptables 计数器是排查 VXLAN 问题的关键**，为 0 表示流量未到达
5. **Overlay 网络只需在一个管理节点创建**，其他节点自动同步