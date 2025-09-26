docker网络构建

1. 创建管理节点

   ```shell
   #!/bin/bash   
   #create-docker-network.sh 
   
   # 获取脚本所在目录
   SCRIPT_DIR=$(dirname $(readlink -f $0))
   
   # 读取配置文件
   source $SCRIPT_DIR/config.sh
   
   # 检查是否为管理节点
   IS_MANAGER=$(sudo docker info | grep -i "Swarm:" | awk '{print $2}')
   if [[ "$IS_MANAGER" == "inactive" ]]; then
       echo "Swarm is inactive. Initializing Swarm as a manager..."
       
       # 初始化 Swarm 管理节点
       sudo docker swarm init --advertise-addr $CURRENT_IP
       
       # 获取加入令牌
       echo "Join Token (for other nodes):"
       sudo docker swarm join-token worker
   else
       echo "This node is already part of a Swarm as a manager."
   fi
   
   # 创建网络
   echo "Creating network 'servicenet'..."
   sudo docker network create \
       --driver overlay \
       --opt encrypted \
       --subnet=172.16.0.0/16 \
       --ip-range=172.16.5.0/24 \
       --gateway=172.16.5.254 \
       --attachable \
       servicenet
   ```

   

2. 将其它节点加入

   ```shell
   # 初始化 Swarm 后，会输出一个加入令牌。可以使用以下命令获取加入令牌：
   sudo docker swarm join-token worker
   
   # 输出示例：
   To add a worker to this swarm, run the following command:
   
       docker swarm join --token SWMTKN-1-5q0e8640f0pf4wuuashcmvy7o88ggqhunplvqgecf2nukls083-9cfjftz99m0ote2ax0aghgr8f 管理节点ip:2377
       
   # 在工作节点worker运行下面命令加入
   sudo docker swarm join --token SWMTKN-1-5q0e8640f0pf4wuuashcmvy7o88ggqhunplvqgecf2nukls083-9cfjftz99m0ote2ax0aghgr8f  --advertise-addr worker节点ip 管理节点ip:2377
   
   # 在管理节点验证节点状态
   sudo docker node ls
   
   # 输出示例
   ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
   nvblpa3k73goae3v2qw3caex6     manager1            Ready               Active              Leader              20.10.7
   7g2yqz3yqz3yqz3yqz3yqz3yqz    worker1             Ready               Active                                  20.10.7
   
   
   ```

   

3. 大概率第2步会失败

   ```shell
   # 确保两个节点之间的网络配置允许它们互相通信。具体来说：
   
   #防火墙规则：确保防火墙允许必要的端口通信。Docker Swarm 默认使用以下端口：
   2377：用于集群管理通信。
   7946：用于控制平面通信。
   4789：用于 Overlay 网络通信。
   
   # 需要在 管理节点ip/当前节点ip 上开放这些端口：
   sudo firewall-cmd --permanent --add-port=2377/tcp
   sudo firewall-cmd --permanent --add-port=7946/tcp
   sudo firewall-cmd --permanent --add-port=7946/udp
   sudo firewall-cmd --permanent --add-port=4789/udp
   sudo firewall-cmd --reload
   ```

   

```shell
# 检查端口连通性,使用 telnet 或 nc（Netcat）工具检查端口连通性。

# 检查 2377 端口
telnet 192.168.218.217 2377

nc -zv 192.168.218.217 2377
```





！！！实际执行过程示例，记得先改config.sh的ip：

```shell
# 创建docker网络，并作为主节点
[css@localhost init-data]$ ./create-docker-network.sh 
./03-create-docker-network.sh:行1: ﻿#!/bin/bash: 没有那个文件或目录
Swarm is inactive. Initializing Swarm as a manager...
Swarm initialized: current node (haj0oml22vs3p0t0kw49er54j) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4aobq9e1udawume3tsn2pq1nod4lgrds4fzunzrm98awvemxbl-0nyj7yuksht675pwa6svbfc8z 192.168.43.182:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

Join Token (for other nodes):
To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4aobq9e1udawume3tsn2pq1nod4lgrds4fzunzrm98awvemxbl-0nyj7yuksht675pwa6svbfc8z 192.168.43.182:2377

Creating network 'servicenet'...
cd27mqzbggq6cfn7x02gvvrze


# 查询docker网络节点情况
[css@localhost init-data]$ sudo docker node ls
ID                            HOSTNAME                STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
haj0oml22vs3p0t0kw49er54j *   localhost.localdomain   Ready     Active         Leader           26.1.4

# 查询docker网网络信息
[css@localhost init-data]$ sudo docker info
Client:
 Version:    26.1.4
 Context:    default
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 26.1.4
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
  Using metacopy: false
  Native Overlay Diff: true
  userxattr: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local splunk syslog
 Swarm: active
  NodeID: haj0oml22vs3p0t0kw49er54j
  Is Manager: true
  ClusterID: iodtqii4awnqt44wnqmrzocqw
  Managers: 1
  Nodes: 1
  Data Path Port: 4789
  Orchestration:
   Task History Retention Limit: 5
  Raft:
   Snapshot Interval: 10000
   Number of Old Snapshots to Retain: 0
   Heartbeat Tick: 1
   Election Tick: 10
  Dispatcher:
   Heartbeat Period: 5 seconds
  CA Configuration:
   Expiry Duration: 3 months
   Force Rotate: 0
  Autolock Managers: false
  Root Rotation In Progress: false
  Node Address: 192.168.43.182
  Manager Addresses:
   192.168.43.182:2377
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: ae71819c4f5e67bb4d5ae76a6b735f29cc25774e
 runc version: v1.1.12-0-g51d5e94
 init version: de40ad0
 Security Options:
  seccomp
   Profile: builtin
 Kernel Version: 3.10.0-1160.71.1.el7.x86_64
 Operating System: CentOS Linux 7 (Core)
 OSType: linux
 Architecture: x86_64
 CPUs: 4
 Total Memory: 3.84GiB
 Name: localhost.localdomain
 ID: dcee4dc5-74ee-40cf-8297-ec8338461d1d
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Live Restore Enabled: false
 Product License: Community Engine



# 在工作节点服务器执行
docker swarm join --token SWMTKN-1-4aobq9e1udawume3tsn2pq1nod4lgrds4fzunzrm98awvemxbl-0nyj7yuksht675pwa6svbfc8z worker节点ip 192.168.43.182:2377    # 不指定worker节点ip，可能导致不同节点的docker服务无法通信

返回：This node joined a swarm as a worker.说明加入网络成功

# 查看当前网络列表
[css@localhost init_data]$ sudo docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
16f5e13bfac8   bridge            bridge    local
9fe746ea8ec9   docker_gwbridge   bridge    local
8f9971f3b823   host              host      local
6ankpnpr1smg   ingress           overlay   swarm
3ee71b24300a   none              null      local

# 工作节点无法查看节点信息
[css@localhost init_data]$ sudo docker node ls
Error response from daemon: This node is not a swarm manager. Worker nodes can't be used to view or modify cluster state. Please run this command on a manager node or promote the current node to a manager.
[css@localhost init_data]$ 


# 在管理节点执行
# 查询节点信息，获取到工作节点id
[css@localhost init-data]$ sudo docker node ls
ID                            HOSTNAME                STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
haj0oml22vs3p0t0kw49er54j *   localhost.localdomain   Ready     Active         Leader           26.1.4
kkfyxm20tktnbx0xcefa1xtxs     localhost.localdomain   Ready     Active                          26.1.4

# 将工作节点升级为管理节点
[css@localhost init-data]$ sudo docker node promote kkfyxm20tktnbx0xcefa1xtxs
Node kkfyxm20tktnbx0xcefa1xtxs promoted to a manager in the swarm.


# 再次查看网络列表，两个服务器就都有servicenet了
[css@localhost init-data]$ sudo docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
ffd20b021178   bridge            bridge    local
4627702c2fd1   docker_gwbridge   bridge    local
77536f1d4190   host              host      local
6ankpnpr1smg   ingress           overlay   swarm
c89b1eb4d020   none              null      local
cd27mqzbggq6   servicenet        overlay   swarm




离开当前 Swarm 集群的命令
docker swarm leave 

在管理节点上操作，并且该节点是管理节点，则添加 --force 参数：
docker swarm leave --force


命令								用途
docker node ls					列出所有节点
docker node inspect <node_id>	查看节点详细信息
docker info						查看本机节点角色和集群信息
docker service ps <svc>			查看服务在哪些节点上运行
docker task ls					查看所有任务及其所在节点
```



如果发现定义网络时，IP指定错了，则按下面步骤进行修改

```shell
1. worker节点先离开集群
docker swarm leave

2. 管理节点强制离开集群
docker swarm leave --force

3. 重新初始化或加入 Swarm 集群（使用新 IP）
docker swarm init --advertise-addr 10.6.56.48

# 创建网络
echo "Creating network 'servicenet'..."
sudo docker network create \
    --driver overlay \
    --opt encrypted \
    --subnet=172.16.0.0/16 \
    --ip-range=172.16.5.0/24 \
    --gateway=172.16.5.254 \
    --attachable \
    servicenet

4. 在管理节点上获取加入命令（token）
docker swarm join-token worker
## 工作节点 10.6.56.48 上运行输出的 docker swarm join ... 命令，并加上 --advertise-addr 参数：

5. 在worker节点上执行
docker swarm join --token SWMTKN-1-xxx 10.6.56.48:2377 --advertise-addr 10.6.56.49

6. 升级工作节点为管理节点
[root@localhost home]# docker node ls
ID                            HOSTNAME    STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
0stnw6fnzy5mif4nkhe3zivc7     localhost   Ready     Active                          26.1.4
wte1iibeya81n8bl37jfoud74 *   localhost   Ready     Active         Leader           26.1.4
[root@localhost home]#  sudo docker node promote 0stnw6fnzy5mif4nkhe3zivc7
```





补充

```shell
将节点降级
docker node update --role worker wte1iibeya81n8bl37jfoud74

再在相应节点上执行
[root@localhost install-data]#  docker swarm leave
#Node left the swarm.

然后在管理节点删除down的节点
[root@localhost home]# docker node rm wte1iibeya81n8bl37jfoud74
wte1iibeya81n8bl37jfoud74
```



### **查看当前主机名**

#### 方法 1：使用 `hostname` 命令

```
hostname
```

直接显示当前主机名（如 `localhost.localdomain`）。

#### 方法 2：使用 `hostnamectl` 命令

```
hostnamectl
```

显示详细信息，包括静态主机名（`Static hostname`）、操作系统版本等。

#### 方法 3：查看 `/etc/hostname` 文件

```
cat /etc/hostname
```

此文件存储永久主机名配置。

------



### **永久修改主机名**

#### 步骤 1：使用 `hostnamectl` 修改（推荐）

```
sudo hostnamectl set-hostname <新主机名>
```

例如：

```
sudo hostnamectl set-hostname node3
```

#### 步骤 2：更新 `/etc/hosts` 文件

```
sudo vi /etc/hosts
```

将旧主机名替换为新主机名（通常在 `127.0.1.1` 行）：

```
- 127.0.1.1   localhost.localdomain
+ 127.0.1.1   node3
```

#### 步骤 3：重启系统或 Docker 服务

```
sudo systemctl restart docker  # 重启 Docker 使新主机名生效
```

或完全重启系统：

```
sudo reboot
```





### 完整修复步骤

#### 1. 在所有节点配置主机名解析

```
# 在 node1 (10.20.27.51) 上执行
sudo tee -a /etc/hosts <<EOF
10.20.27.51 node1
10.20.27.52 node2
10.20.27.53 node3
EOF

# 在 node2 (10.20.27.52) 上执行
sudo tee -a /etc/hosts <<EOF
10.20.27.51 node1
10.20.27.52 node2
10.20.27.53 node3
EOF

# 在 node3 (10.20.27.53) 上执行
sudo tee -a /etc/hosts <<EOF
10.20.27.51 node1
10.20.27.52 node2
10.20.27.53 node3
EOF
```

#### 2. 设置唯一主机名

```
# 在 node1 上执行
sudo hostnamectl set-hostname node1

# 在 node2 上执行
sudo hostnamectl set-hostname node2

# 在 node3 上执行
sudo hostnamectl set-hostname node3
```

#### 3. 重启 Docker 服务

```
# 在所有节点执行
sudo systemctl restart docker
```

#### 4. 重置 Swarm 集群

```
# 在 node1 上执行
docker swarm leave --force
sudo rm -rf /var/lib/docker/swarm/*
docker swarm init --advertise-addr 10.20.27.51

# 在 node2 上执行
docker swarm leave --force
sudo rm -rf /var/lib/docker/swarm/*

# 在 node3 上执行
docker swarm leave --force
sudo rm -rf /var/lib/docker/swarm/*
```

#### 5. 重新加入集群

```
# 在 node1 上获取加入令牌
docker swarm join-token worker

# 在 node2 和 node3 上执行加入命令
docker swarm join --token <TOKEN> node1:2377

docker swarm join --token SWMTKN-1-3144o9zpog2agp3xfgb0n1r0igmmvwu757n805v2hmbo1o498l-0ybged5pkmfa70cxti7yf18hm 10.20.27.51:2377 --advertise-addr 10.20.27.52
```

#### 6. 提升节点为管理节点

```
# 在 node1 上执行
docker node promote node2
docker node promote node3
```

### 验证步骤

#### 1. 检查主机名解析

```
# 在所有节点执行
ping node1 -c 3
ping node2 -c 3
ping node3 -c 3
```

#### 2. 检查集群状态

```
# 在 node1 上执行
docker node ls

# 预期输出：
ID                            HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
sefv... *      node1    Ready   Active        Leader
z9sz...        node2    Ready   Active        Reachable
hare...        node3    Ready   Active        Reachable
```

#### 3. 测试集群通信

```
# 创建测试服务
docker service create --name test --replicas 3 alpine ping docker.com

# 检查服务状态
docker service ps test
```

### 防火墙配置（所有节点）

```
sudo firewall-cmd --permanent --add-port=2377/tcp
sudo firewall-cmd --permanent --add-port=7946/tcp
sudo firewall-cmd --permanent --add-port=7946/udp
sudo firewall-cmd --permanent --add-port=4789/udp
sudo firewall-cmd --reload
```

### 重要注意事项

1. **配置一致性**：确保所有节点的 `/etc/hosts` 文件内容完全一致

2. **主机名唯一性**：每个节点必须有唯一主机名

3. **时间同步**：确保所有节点时间一致

   ```
   sudo yum install -y chrony
   sudo systemctl start chronyd
   sudo systemctl enable chronyd
   ```

4. **持久化配置**：修改 `/etc/hosts` 后不需要重启，但主机名修改需要重启 Docker



