#!/bin/bash

# 阿里云 RDS 连接信息
export PGPASSWORD='@Xinxibu1717'
RDS_HOST="pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com"
RDS_PORT="5432"
RDS_USER="yuncailian"
RDS_DB="root"

# 当前目录（存放所有 SQL 文件）
SQL_DIR="/mnt/db193/database/pg_dump导出的sql/root"

# 日志文件
LOG_FILE="${SQL_DIR}/import_all_$(date +%Y%m%d_%H%M%S).log"

# 切换到 SQL 文件目录
cd "$SQL_DIR"

# 定义导入顺序（按文件大小从小到大，避免大文件卡住）
# 你也可以根据需要调整顺序
SQL_FILES=(
        "abpzjk.sql"
        "ai_model_manager.sql"
        "auth_center.sql"
        "camunda.sql"
        "ccgp.sql"
        "communal.sql"
        "ctpsp.sql"
        "financial_center.sql"
        "job_proxy.sql"
        "margin_docking_consumer.sql"
        "message_management_center.sql"
        "notice.sql"
        "oa_management_center.sql"
        "onlyoffice_center.sql"
        "pay.sql"
        "platformcenterdb.sql"
        "process_center.sql"
        "redxun_docking.sql"
        "selenium.sql"
        "sqlitedata.sql"
        "third_party_oa_docking.sql"
        "third_party_platform.sql"
        "tianyancha_info.sql"
        "upload_center.sql"
        "usercenter.sql"
        "websocket.sql"
)

echo "=========================================" | tee "$LOG_FILE"
echo "批量导入开始: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "目标数据库: $RDS_HOST:$RDS_PORT/$RDS_DB" | tee -a "$LOG_FILE"
echo "SQL 文件目录: $SQL_DIR" | tee -a "$LOG_FILE"
echo "总文件数: ${#SQL_FILES[@]}" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

# 统计变量
SUCCESS=0
FAIL=0
FAILED_FILES=()
START_TOTAL=$(date +%s)

# 依次执行导入
for sql_file in "${SQL_FILES[@]}"; do
    if [ ! -f "$sql_file" ]; then
        echo "⚠️  文件不存在: $sql_file，跳过" | tee -a "$LOG_FILE"
        ((FAIL++))
        FAILED_FILES+=("$sql_file (文件不存在)")
        continue
    fi
    
    FILE_SIZE=$(ls -lh "$sql_file" | awk '{print $5}')
    echo ""
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始导入: $sql_file (大小: $FILE_SIZE)" | tee -a "$LOG_FILE"
    START_TIME=$(date +%s)
    
    # 导入 SQL 文件
    psql -h "$RDS_HOST" -p "$RDS_PORT" -U "$RDS_USER" -d "$RDS_DB" \
        -v ON_ERROR_STOP=0 \
        -f "$sql_file" >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo "✅ 导入成功: $sql_file (耗时: ${DURATION}秒, ${FILE_SIZE})" | tee -a "$LOG_FILE"
        ((SUCCESS++))
    else
        echo "❌ 导入失败: $sql_file (耗时: ${DURATION}秒)" | tee -a "$LOG_FILE"
        echo "   请检查日志文件中的错误信息" | tee -a "$LOG_FILE"
        ((FAIL++))
        FAILED_FILES+=("$sql_file")
    fi
done

# 计算总耗时
END_TOTAL=$(date +%s)
TOTAL_DURATION=$((END_TOTAL - START_TOTAL))
TOTAL_MIN=$((TOTAL_DURATION / 60))
TOTAL_SEC=$((TOTAL_DURATION % 60))

# 输出汇总报告
echo ""
echo "=========================================" | tee -a "$LOG_FILE"
echo "批量导入完成: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "总耗时: ${TOTAL_MIN}分${TOTAL_SEC}秒" | tee -a "$LOG_FILE"
echo "成功: $SUCCESS 个" | tee -a "$LOG_FILE"
echo "失败: $FAIL 个" | tee -a "$LOG_FILE"

if [ $FAIL -gt 0 ]; then
    echo "" | tee -a "$LOG_FILE"
    echo "失败的文件列表:" | tee -a "$LOG_FILE"
    for failed in "${FAILED_FILES[@]}"; do
        echo "  - $failed" | tee -a "$LOG_FILE"
    done
fi

echo "" | tee -a "$LOG_FILE"
echo "日志文件: $LOG_FILE" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

unset PGPASSWORD
