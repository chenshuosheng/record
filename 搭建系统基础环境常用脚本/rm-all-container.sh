#!/bin/bash

# 获取所有容器的 ID
CONTAINER_IDS=$(sudo docker ps -aq)

# 检查是否有容器 ID
if [ -z "$CONTAINER_IDS" ]; then
    echo "No containers found."
else
    # 逐个删除容器
    for CONTAINER_ID in $CONTAINER_IDS; do
        echo "Removing container $CONTAINER_ID..."
        sudo docker rm -f $CONTAINER_ID
        sleep 1 # 等待一秒，避免并发问题
    done
fi