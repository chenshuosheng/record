#!/bin/bash

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