#!/bin/bash

# 文件定义
INPUT_FILE="directories.txt"
OUTPUT_FILE="need-cp-directories.txt"
LOG_FILE="process.log"
BACKUP_DIR_FILE="backup_dir.txt"


# 日志函数
log() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $msg" >> "$LOG_FILE"
}

# 清空或创建日志文件
> "$LOG_FILE"

# 清空之前的备份目录记录
> "$BACKUP_DIR_FILE"  

# Step 1: 收集所有名为 public 的目录
log "Step 1: 开始收集名为 'public' 的目录..."

> "$OUTPUT_FILE"  # 清空输出文件

if [ ! -f "$INPUT_FILE" ]; then
    log "错误：找不到输入文件 $INPUT_FILE"
    echo "错误：找不到输入文件 $INPUT_FILE"
    exit 1
fi

# 逐行读取文件内容，保留原始格式（包括空格和反斜杠），并且确保即使最后一行没有换行符也能被正确读取。
while IFS= read -r base_dir || [[ -n "$base_dir" ]]; do
    base_dir=$(echo "$base_dir" | xargs)
    if [ -z "$base_dir" ]; then
        log "警告：跳过空行"
        continue
    fi

    if [ ! -d "$base_dir" ]; then
        log "错误：无效目录 $base_dir"
        continue
    fi

    log "正在扫描目录树: $base_dir"

    # 查找所有名为 public 的目录
    find "$base_dir" -type d -name "public" | while IFS= read -r public_dir; do
        echo "$public_dir" >> "$OUTPUT_FILE"
        log "发现 public 目录：$public_dir"
    done

done < "$INPUT_FILE"

log "Step 1: public 目录收集完成，结果已写入 $OUTPUT_FILE"

# Step 2: 处理每个 public 目录
log "Step 2: 开始处理每个 public 目录..."

if [ ! -f "$OUTPUT_FILE" ]; then
    log "错误：未找到 $OUTPUT_FILE 文件"
    echo "错误：未找到 $OUTPUT_FILE 文件"
    exit 1
fi

while IFS= read -r public_dir || [[ -n "$public_dir" ]]; do
    public_dir=$(echo "$public_dir" | xargs)
    if [ -z "$public_dir" ]; then
        log "警告：跳过空行"
        continue
    fi

    if [ ! -d "$public_dir" ]; then
        log "错误：public 目录不存在：$public_dir"
        continue
    fi

    parent_dir=$(dirname "$public_dir")
    test_dir="$parent_dir/test"
    timestamp=$(date "+%Y%m%d%H%M%S")
    backup_dir="$parent_dir/test$timestamp"

    log "开始处理 public 目录：$public_dir"

    # 判断是否存在 test 目录
    if [ -d "$test_dir" ]; then
        log "发现 test 目录：$test_dir"

        # 备份 test 目录
        mv "$test_dir" "$backup_dir"
        log "备份 test 目录为：$backup_dir"

        # 记录备份目录到文件
        echo "$backup_dir" >> "$BACKUP_DIR_FILE"

        # 创建新的 test 目录
        cp -r "$public_dir" "$test_dir"
        log "将 public 目录拷贝到 test：$test_dir"
    else
        log "未找到 test 目录，直接复制 public 到 test"
        cp -r "$public_dir" "$test_dir"
        log "创建 test 目录并拷贝 public 内容：$test_dir"
    fi

    index_file="$test_dir/index.html"

    if [ -f "$index_file" ]; then
        log "替换 $index_file 中的 'public' 为 'test'"
        sed -i "s/public/test/g" "$index_file"
        log "替换完成：$index_file"
    else
        log "警告：未找到 index.html 文件：$index_file"
    fi

done < "$OUTPUT_FILE"

log "Step 2: 所有 public 目录处理完成"
echo "全部操作已完成，请查看日志文件：$LOG_FILE"