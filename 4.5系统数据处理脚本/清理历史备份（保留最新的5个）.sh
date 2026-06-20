#!/bin/bash

# ========== 配置区域 ==========

# 要处理的目录（直接在这里指定，避免命令行输入错误）
TARGET_DIRS=(
    "/home/yclProjectv4_5/zny"
)

# 保留最新的几个备份目录（默认：10）
KEEP_COUNT=5

# 需要清理的目录模式（支持通配符）
BACKUP_PATTERNS=(
    "dist*"           # dist开头的目录
    "public[0-9]*"    # public+数字
    "[0-9][0-9][0-9][0-9][0-9][0-9]"  # 6位纯数字（日期）
    "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"  # 8位纯数字（日期）
    "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"  # 14位纯数字（日期时间）
    "backup_*"        # backup_开头的目录
    "bak_*"           # bak_开头的目录
    "*_backup"        # 以_backup结尾的目录
    "*_bak"           # _bak结尾的目录
)

# 触发器目录（包含这些目录的父目录会被处理）
TRIGGER_PATTERNS=(
    "public"          # 标准public目录
)

# 安全选项
#DRY_RUN=true       # 试运行模式（先设为true测试，确认无误后改false）
DRY_RUN=false       # 试运行模式（先设为true测试，确认无误后改false）
SAFE_MODE=true      # 安全模式
LOG_ENABLED=true

# 日志文件路径 - 使用绝对路径或固定位置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 获取脚本所在目录
LOG_FILE="${SCRIPT_DIR}/cleanup_$(date +%Y%m%d_%H%M%S).log"  # 固定在脚本目录下

# ========== 函数定义 ==========

log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$LOG_ENABLED" = true ]; then
        # 使用绝对路径写入日志
        echo "[$timestamp] $message" | tee -a "$LOG_FILE"
    else
        echo "[$timestamp] $message"
    fi
}

is_safe_to_delete() {
    local dir_path="$1"
    
    # 禁止删除的目录
    local protected_dirs=(
        "/" "/bin" "/boot" "/dev" "/etc" "/home" "/lib" "/lib64"
        "/opt" "/proc" "/root" "/sbin" "/sys" "/usr" "/var" "." ".."
    )
    
    for protected in "${protected_dirs[@]}"; do
        if [ "$dir_path" = "$protected" ]; then
            return 1
        fi
    done
    
    # 目录名至少3个字符
    if [ ${#dir_path} -le 2 ]; then
        return 1
    fi
    
    return 0
}

# 清理函数
clean_backup_dirs() {
    local target_dir="$1"
    local keep_count="${2:-$KEEP_COUNT}"
    
    # 检查目录是否存在
    if [ ! -d "$target_dir" ]; then
        log_message "错误：目录不存在 '$target_dir'"
        return 1
    fi
    
    # 获取绝对路径
    target_dir=$(cd "$target_dir" 2>/dev/null && pwd)
    if [ -z "$target_dir" ]; then
        log_message "错误：无法获取目录绝对路径 '$1'"
        return 1
    fi
    
    # 检查是否有触发器目录存在
    local has_trigger=false
    for pattern in "${TRIGGER_PATTERNS[@]}"; do
        # 使用 find 检查是否存在匹配的目录
        if find "$target_dir" -maxdepth 1 -type d -name "$pattern" 2>/dev/null | grep -q .; then
            has_trigger=true
            break
        fi
    done
    
    if [ "$has_trigger" = false ]; then
        log_message "跳过：目录 '$target_dir' 下没有触发器目录（如：public）"
        return 0
    fi
    
    log_message "========================================="
    log_message "处理目录：$target_dir"
    
    # 保存当前目录，以便切换后能回来
    local current_dir=$(pwd)
    
    # 切换到目标目录
    cd "$target_dir" || {
        log_message "错误：无法进入目录 '$target_dir'"
        return 1
    }
    
    # 收集所有匹配模式的备份目录
    local dirs=()
    for pattern in "${BACKUP_PATTERNS[@]}"; do
        # 使用 find 查找匹配的目录
        while IFS= read -r dir; do
            # 去掉路径前缀
            dir=$(basename "$dir")
            
            # 排除触发器目录本身
            local skip=false
            for trigger in "${TRIGGER_PATTERNS[@]}"; do
                if [[ "$dir" == "$trigger" ]]; then
                    skip=true
                    break
                fi
            done
            [ "$skip" = false ] && dirs+=("$dir")
        done < <(find "$target_dir" -maxdepth 1 -type d -name "$pattern" 2>/dev/null | sort)
    done
    
    # 去重
    if [ ${#dirs[@]} -gt 0 ]; then
        declare -A unique_dirs
        for dir in "${dirs[@]}"; do
            unique_dirs["$dir"]=1
        done
        dirs=("${!unique_dirs[@]}")
        
        # 按修改时间排序（最新的在前）
        local sorted_dirs=()
        while IFS= read -r dir; do
            if [ -d "$dir" ]; then
                sorted_dirs+=("$dir")
            fi
        done < <(for dir in "${dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo "$(stat -c %Y "$dir" 2>/dev/null):$dir"
            fi
        done | sort -rn | cut -d':' -f2)
        dirs=("${sorted_dirs[@]}")
    fi
    
    local total=${#dirs[@]}
    
    if [ $total -eq 0 ]; then
        log_message "  未找到需要清理的备份目录"
        log_message ""
        # 切换回原目录
        cd "$current_dir"
        return 0
    fi
    
    log_message "  找到 $total 个备份目录："
    for dir in "${dirs[@]}"; do
        log_message "    - $dir"
    done
    
    if [ $total -le $keep_count ]; then
        log_message "  备份目录数量 ($total) ≤ 保留数量 ($keep_count)，无需清理"
        log_message ""
        # 切换回原目录
        cd "$current_dir"
        return 0
    fi
    
    # 显示要保留的目录
    log_message "  保留最新的 $keep_count 个："
    for i in $(seq 0 $((keep_count-1))); do
        log_message "    [保留] ${dirs[$i]}"
    done
    
    # 删除多余的目录
    log_message "  删除以下目录："
    local deleted_count=0
    for i in $(seq $keep_count $((total-1))); do
        local dir_to_delete="${dirs[$i]}"
        
        # 安全检查
        if [ "$SAFE_MODE" = true ]; then
            if ! is_safe_to_delete "$dir_to_delete"; then
                log_message "    [跳过-不安全] $dir_to_delete"
                continue
            fi
        fi
        
        log_message "    [删除] $dir_to_delete"
        
        if [ "$DRY_RUN" = true ]; then
            log_message "      (试运行模式，实际未删除)"
            ((deleted_count++))
        else
            if [ -n "$dir_to_delete" ] && [ -d "$dir_to_delete" ]; then
                rm -rf "$target_dir/$dir_to_delete"
                if [ $? -eq 0 ]; then
                    log_message "      删除成功"
                    ((deleted_count++))
                else
                    log_message "      删除失败"
                fi
            fi
        fi
    done
    
    log_message "  完成：删除了 $deleted_count 个旧备份目录"
    log_message ""
    
    # 切换回原目录
    cd "$current_dir"
}

# 递归处理所有子目录
process_all_directories() {
    local base_dir="$1"
    local keep_count="${2:-$KEEP_COUNT}"
    
    log_message "开始扫描目录：$base_dir"
    
    # 查找所有包含 public 目录的父目录
    find "$base_dir" -type d -name "public" 2>/dev/null | while read public_path; do
        parent_dir=$(dirname "$public_path")
        
        # 避免重复处理
        if [ -n "$parent_dir" ] && [ -d "$parent_dir" ]; then
            clean_backup_dirs "$parent_dir" "$keep_count"
        fi
    done
}

show_config() {
    echo "========================================="
    echo "清理备份目录脚本"
    echo "脚本目录: $SCRIPT_DIR"
    echo "保留数量: $KEEP_COUNT"
    echo "试运行模式: $DRY_RUN"
    echo "安全模式: $SAFE_MODE"
    echo "日志文件: $LOG_FILE"
    echo "触发器: ${TRIGGER_PATTERNS[*]}"
    echo "备份模式: ${BACKUP_PATTERNS[*]}"
    echo "========================================="
}

main() {
    local dirs_to_process=()
    
    if [ ${#TARGET_DIRS[@]} -eq 0 ]; then
        dirs_to_process=(".")
        echo "未配置目标目录，将处理当前目录"
    else
        dirs_to_process=("${TARGET_DIRS[@]}")
    fi
    
    show_config
    
    for target_dir in "${dirs_to_process[@]}"; do
        if [ ! -d "$target_dir" ]; then
            log_message "错误：目录不存在 '$target_dir'"
            continue
        fi
        
        # 转换为绝对路径
        target_dir=$(cd "$target_dir" 2>/dev/null && pwd)
        log_message "开始处理: $target_dir"
        
        # 处理这个目录及其所有子目录
        process_all_directories "$target_dir" "$KEEP_COUNT"
    done
    
    log_message "========================================="
    log_message "所有处理完成！"
    log_message "日志已保存到: $LOG_FILE"
    if [ "$DRY_RUN" = true ]; then
        log_message "提示：当前为试运行模式，未实际删除任何文件"
        log_message "      确认无误后，请修改脚本中的 DRY_RUN=false 再运行"
    fi
}

# 命令行参数支持
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -k|--keep)
            KEEP_COUNT="$2"
            shift 2
            ;;
        --help)
            cat << EOF
用法: $0 [选项]

选项：
  -n, --dry-run    试运行模式（只显示不删除）
  -k, --keep NUM   保留最新的几个备份目录
  --help           显示此帮助信息

配置文件：
  直接编辑脚本开头的 TARGET_DIRS 数组
EOF
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

main