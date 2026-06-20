#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# 读取配置文件（如果有的话）
source "$SCRIPT_DIR"/config-yaml.env 2>/dev/null || echo "未找到 config-yaml.env，跳过加载配置。"

# 定义日志函数（带时间戳）
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# 启动微服务
log "启动所有微服务..."
log "正在查找并执行 $TARGET_DIR 子级目录下的 docker/*.sh 文件..."

# 查找所有目标目录下的 docker/*.sh 文件
mapfile -t FILES < <(find "$TARGET_DIR" -type d -name "docker" \
    -exec sh -c 'find "{}" -maxdepth 1 -type f -name "*.sh"' \;)

# 检查是否有文件找到
if [ ${#FILES[@]} -eq 0 ]; then
    log "没有找到任何符合条件的 .sh 文件。"
    exit 1
fi

# 遍历并执行每个脚本
for file in "${FILES[@]}"; do
    log "正在执行 $file..."

    # 获取脚本所在目录
    SCRIPT_PATH=$(dirname "$file")
    ORIGINAL_DIR=$(pwd)

    # 进入脚本目录
    cd "$SCRIPT_PATH" || { log "无法进入目录 $SCRIPT_PATH"; exit 1; }
    log "当前目录：$(pwd)"

    # 执行脚本，并传递当前 PATH 给 sudo
    if env "PATH=$PATH" sudo "./$(basename "$file")"; then
        log "$file 执行成功。"
    else
        log "$file 执行失败。"
        cd "$ORIGINAL_DIR" || exit 1
        exit 1
    fi

    # 返回原始目录
    cd "$ORIGINAL_DIR" || exit 1
done

log "所有 .sh 文件执行完毕。"