#!/bin/bash

##############################################################################
# PostgreSQL 批量导出脚本
# 功能：批量导出指定模式，支持排除表、后台执行、日志记录
##############################################################################

# ==================== 配置区域 ====================
# 数据库连接配置
export PGPASSWORD='Xinxibu1717...'          # 数据库密码（请修改为实际密码）
CONTAINER="postgres"                         # Docker 容器名
DB_USER="root"                               # 数据库用户
DB_NAME="root"                               # 数据库名

# 导出配置
EXPORT_DIR="./exports_$(date +%Y%m%d_%H%M%S)"  # 导出目录
LOG_DIR="./logs"                              # 日志目录
PARALLEL=1                                    # 并行导出数量（1=串行，>1=并行）
COMPRESS=false                                # 是否压缩导出文件

# 需要导出的模式列表
SCHEMAS=(
    "abpzjk"
    "ai_model_manager"
    "auth_center"
    "camunda"
    "ccgp"
    "communal"
    "ctpsp"
    "financial_center"
    "job_proxy"
    "margin_docking_consumer"
    "message_management_center"
    "notice"
    "oa_management_center"
    "onlyoffice_center"
    "pay"
    "platformcenterdb"
    "process_center"
    "redxun_docking"
    "selenium"
    "sqlitedata"
    "third_party_oa_docking"
    "third_party_platform"
    "tianyancha_info"
    "upload_center"
    "usercenter"
    "websocket"
)

# 排除表配置（格式：模式.表名）
# 注意：只会排除属于当前模式的表，不会跨模式排除
EXCLUDE_TABLES=(
    "auth_center.java_audit_logs"
    "camunda.java_log"
    "ctpsp.javaauditlogs"
    "job_proxy.java_audit_logs"
    "margin_docking_consumer.javaauditlogs"
    "message_management_center.java_log"
    "oa_management_center.java_audit_logs"
    "platformcenterdb.javaauditlogs"
    "third_party_oa_docking.java_audit_logs"
    "third_party_platform.sys_log"
    "upload_center.javaauditlogs"
    "usercenter.javaauditlogs"
)

# pg_dump 额外参数
PG_DUMP_OPTS="-O -x --no-tablespaces --inserts"

# ==================== 初始化 ====================
mkdir -p "$EXPORT_DIR" "$LOG_DIR"

# 日志文件
MAIN_LOG="${LOG_DIR}/batch_export_$(date +%Y%m%d_%H%M%S).log"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 日志函数（只写入文件，不输出到 stdout 避免干扰）
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$MAIN_LOG"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1" >> "$MAIN_LOG"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1" >> "$MAIN_LOG"
}

log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1" >> "$MAIN_LOG"
}

# 打印到屏幕并写入日志
print_info() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MAIN_LOG"
}

print_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✅ $1${NC}" | tee -a "$MAIN_LOG"
}

print_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}" | tee -a "$MAIN_LOG"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}" | tee -a "$MAIN_LOG"
}

# 构建排除表参数（只排除属于当前模式的表）
build_exclude_args() {
    local schema=$1
    local exclude_args=""
    
    for table in "${EXCLUDE_TABLES[@]}"; do
        local table_schema="${table%.*}"
        if [ "$table_schema" == "$schema" ]; then
            exclude_args="$exclude_args -T $table"
        fi
    done
    
    echo "$exclude_args"
}

# 导出单个模式
export_schema() {
    local schema=$1
    local output_file="${EXPORT_DIR}/${schema}.sql"
    local schema_log="${LOG_DIR}/${schema}.log"
    local exclude_args=$(build_exclude_args "$schema")
    local start_time=$(date +%s)
    
    print_info "========================================="
    print_info "开始导出模式: $schema"
    
    if [ -n "$exclude_args" ]; then
        print_info "  排除表: $exclude_args"
    fi
    
    # 清空日志文件
    > "$schema_log"
    
    # 执行导出（关键：确保命令正确执行）
    docker exec -e PGPASSWORD="$PGPASSWORD" "$CONTAINER" \
        pg_dump -U "$DB_USER" -d "$DB_NAME" -n "$schema" \
        $exclude_args $PG_DUMP_OPTS \
        > "$output_file" 2>> "$schema_log"
    
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ $exit_code -eq 0 ] && [ -s "$output_file" ]; then
        local file_size=$(ls -lh "$output_file" | awk '{print $5}')
        local row_count=$(grep -c "^INSERT INTO" "$output_file" 2>/dev/null || echo "0")
        print_success "导出成功: $schema"
        print_info "  文件大小: $file_size"
        print_info "  耗时: ${duration}秒"
        print_info "  INSERT数量: $row_count"
        
        if [ "$COMPRESS" = true ]; then
            gzip -c "$output_file" > "${output_file}.gz"
            local gz_size=$(ls -lh "${output_file}.gz" | awk '{print $5}')
            print_info "  压缩后大小: $gz_size"
        fi
        return 0
    else
        print_error "导出失败: $schema (退出码: $exit_code)"
        if [ -s "$schema_log" ]; then
            print_warning "错误信息:"
            head -10 "$schema_log" | while read line; do
                print_warning "  $line"
            done
        fi
        print_warning "查看详细日志: $schema_log"
        return 1
    fi
}

# ==================== 主程序 ====================
main() {
    print_info "========================================="
    print_info "PostgreSQL 批量导出脚本启动"
    print_info "========================================="
    print_info "数据库: $DB_NAME"
    print_info "容器: $CONTAINER"
    print_info "导出目录: $(pwd)/$EXPORT_DIR"
    print_info "日志目录: $(pwd)/$LOG_DIR"
    print_info "模式总数: ${#SCHEMAS[@]}"
    print_info "排除表配置: ${#EXCLUDE_TABLES[@]} 个"
    for table in "${EXCLUDE_TABLES[@]}"; do
        print_info "  - $table"
    done
    print_info "并行数: $PARALLEL"
    print_info "压缩: $COMPRESS"
    print_info "pg_dump参数: $PG_DUMP_OPTS"
    print_info "========================================="
    
    local start_total=$(date +%s)
    local success=0
    local failed=0
    local failed_list=()
    
    # 串行导出
    if [ $PARALLEL -eq 1 ]; then
        for schema in "${SCHEMAS[@]}"; do
            if export_schema "$schema"; then
                ((success++))
            else
                ((failed++))
                failed_list+=("$schema")
            fi
        done
    else
        # 并行导出
        print_info "使用并行模式，并发数: $PARALLEL"
        local pids=()
        local schemas_running=()
        
        for schema in "${SCHEMAS[@]}"; do
            export_schema "$schema" &
            pids+=($!)
            schemas_running+=("$schema")
            
            if [ ${#pids[@]} -ge $PARALLEL ]; then
                wait -n
                # 检查完成的任务
                for i in "${!pids[@]}"; do
                    if ! kill -0 ${pids[$i]} 2>/dev/null; then
                        wait ${pids[$i]}
                        if [ $? -eq 0 ]; then
                            ((success++))
                        else
                            ((failed++))
                            failed_list+=("${schemas_running[$i]}")
                        fi
                        unset pids[$i]
                        unset schemas_running[$i]
                    fi
                done
                pids=("${pids[@]}")
                schemas_running=("${schemas_running[@]}")
            fi
        done
        
        # 等待剩余任务
        for i in "${!pids[@]}"; do
            wait ${pids[$i]}
            if [ $? -eq 0 ]; then
                ((success++))
            else
                ((failed++))
                failed_list+=("${schemas_running[$i]}")
            fi
        done
    fi
    
    local end_total=$(date +%s)
    local total_duration=$((end_total - start_total))
    local total_min=$((total_duration / 60))
    local total_sec=$((total_duration % 60))
    
    echo ""
    print_info "========================================="
    print_info "批量导出完成"
    print_info "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    print_info "总耗时: ${total_min}分${total_sec}秒"
    print_info "成功: $success 个"
    print_info "失败: $failed 个"
    
    if [ $failed -gt 0 ]; then
        print_warning "失败的模式列表:"
        for name in "${failed_list[@]}"; do
            print_warning "  - $name"
        done
    fi
    
    print_info "导出文件位置: $(pwd)/$EXPORT_DIR"
    print_info "主日志文件: $(pwd)/$MAIN_LOG"
    print_info "========================================="
    
    # 生成汇总报告
    cat > "${EXPORT_DIR}/README.txt" << EOF
========================================
PostgreSQL 导出报告
========================================
导出时间: $(date '+%Y-%m-%d %H:%M:%S')
数据库: $DB_NAME
容器: $CONTAINER
成功数量: $success
失败数量: $failed
总耗时: ${total_min}分${total_sec}秒

排除表配置 (${#EXCLUDE_TABLES[@]} 个):
$(printf '  - %s\n' "${EXCLUDE_TABLES[@]}")

导出文件列表:
$(ls -lh "$EXPORT_DIR" | grep -E "\.sql(\.gz)?$" | awk '{print "  " $9 " (" $5 ")"}')

日志文件: $(pwd)/$MAIN_LOG
========================================
EOF
    
    print_info "报告已生成: ${EXPORT_DIR}/README.txt"
    
    local total_size=$(du -sh "$EXPORT_DIR" | awk '{print $1}')
    print_info "导出总大小: $total_size"
}

# ==================== 执行 ====================
main