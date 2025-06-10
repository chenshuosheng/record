#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# 读取配置文件
source "$SCRIPT_DIR/config.sh"

# 检查 IMAGES_DIR 是否设置
if [ -z "$IMAGES_DIR" ]; then
  echo "错误：IMAGES_DIR 未在 config.sh 中定义"
  exit 1
fi

# 遍历所有 .tar 和 .docker 文件
for file in "$IMAGES_DIR"/*.tar "$IMAGES_DIR"/*.docker; do
  if [ ! -f "$file" ]; then
    continue
  fi

  echo "正在加载镜像文件: $file"

  # 提取不带路径和后缀的文件名
  filename=$(basename "$file")
  filename=${filename%.tar}
  filename=${filename%.docker}

  # 使用最后一个 '_' 分割镜像名和 tag
  repo=${filename%_*}
  tag=${filename##*_}

  # 如果没有下划线，使用默认标签
  if [[ "$repo" == "$filename" ]]; then
    repo="imported"
    tag=$(echo "$filename" | tr '.' '_')
  fi

  echo "尝试打标签: $repo:$tag"

  # 加载镜像并输出结果
  LOAD_OUTPUT=$(docker load -i "$file")
  LOAD_EXIT_CODE=$?

  if [ $LOAD_EXIT_CODE -ne 0 ]; then
    echo "加载失败: $file"
    echo "$LOAD_OUTPUT"
    continue
  fi

  echo "$LOAD_OUTPUT"

  # 尝试提取镜像 ID
  IMAGE_ID=$(echo "$LOAD_OUTPUT" | grep -o 'sha256:[0-9a-f]\{64\}')

  if [ -n "$IMAGE_ID" ]; then
    echo "为镜像 $IMAGE_ID 添加标签 $repo:$tag"
    docker tag "$IMAGE_ID" "$repo:$tag"
  else
    echo "无法提取镜像 ID，可能已有标签。跳过打标签步骤。"
  fi

done

echo " 所有 .tar/.docker 文件加载完成。"
