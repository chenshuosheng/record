#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# 停止并移除旧的 postgres 容器
sudo docker stop postgres
sudo docker rm -f postgres

# 使用 docker-compose 启动新的 postgres 容器
sudo /usr/local/bin/docker-compose -f "$SCRIPT_DIR/pg.yaml" up -d

# 等待一段时间让 postgres 容器启动完成
sleep 10 # 这里假设 10 秒足够容器启动

# 检查容器是否已启动
if sudo docker container inspect -f '{{.State.Status}}' postgres | grep -q running; then
  echo "PostgreSQL 容器已启动，现在替换 postgresql.conf 文件..."
  
  # 拷贝 postgresql.conf 文件替换挂载目录下的对应文件
  sudo cp "$SCRIPT_DIR/postgresql.conf" /mnt/database/postgres/pgdata
  
  echo "文件替换完成。"

  echo "重启postgres容器。"
  sudo docker restart postgres
else
  echo "PostgreSQL 容器未启动，无法继续执行。"
fi