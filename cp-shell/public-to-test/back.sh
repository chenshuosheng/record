#!/bin/bash

# 文件定义
BACKUP_FILE="backup_dir.txt"
LOG_FILE="back.log"

# 日志函数
log() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $msg" >> "$LOG_FILE"
}

# 清空或创建日志文件
> "$LOG_FILE"

log "恢复脚本开始执行..."

if [ ! -f "$BACKUP_FILE" ]; then
    log "错误：找不到备份目录列表文件 $BACKUP_FILE"
    echo "错误：找不到备份目录列表文件 $BACKUP_FILE"
    exit 1
fi

# 逐行读取 backup_dir.txt
while IFS= read -r backup_dir || [[ -n "$backup_dir" ]]; do
    backup_dir=$(echo "$backup_dir" | xargs)  # 去除前后空格

    if [ -z "$backup_dir" ]; then
        log "警告：跳过空行"
        continue
    fi

    log "处理备份目录：$backup_dir"

    parent_dir=$(dirname "$backup_dir")
    test_dir="$parent_dir/test"

    # Step 1: 查看备份目录是否存在
    if [ ! -d "$backup_dir" ]; then
        log "错误：备份目录不存在，跳过：$backup_dir"
        continue
    fi

    # Step 2: 当前 test 目录是否存在
    if [ -d "$test_dir" ]; then
        timestamp=$(date "+%Y%m%d%H%M%S")
        backup_test_dir="$parent_dir/test_back_$timestamp"
        log "发现当前 test 目录，正在备份为：$backup_test_dir"
        mv "$test_dir" "$backup_test_dir"
        log "已备份当前 test 目录为：$backup_test_dir"
    else
        log "未找到当前 test 目录，无需备份"
    fi

    # Step 3: 将备份目录更名为 test
    mv "$backup_dir" "$test_dir"
    if [ $? -eq 0 ]; then
        log "成功将 $backup_dir 恢复为 $test_dir"
    else
        log "错误：无法将 $backup_dir 恢复为 $test_dir"
    fi

done < "$BACKUP_FILE"

log "恢复脚本执行完成。"
echo "恢复已完成，请查看日志文件：$LOG_FILE"