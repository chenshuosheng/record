# PostgreSQL 数据库完整迁移总结：从导出到导入

## 📋 目录

1. 环境信息
2. 第一阶段：导出数据
3. 第二阶段：传输文件
4. 第三阶段：导入数据
5. 第四阶段：验证
6. 常见问题与解决方案

------

## 🖥️ 环境信息

### 源数据库（本地容器）

| 项目     | 信息                                        |
| :------- | :------------------------------------------ |
| 容器名   | `postgres`                                  |
| 数据库   | `root`                                      |
| 用户     | `root`                                      |
| 密码     | `Xinxibu1717...`                            |
| 导出目录 | `/mnt/db193/database/pg_dump导出的sql/root` |

### 目标数据库（阿里云 RDS）

| 项目   | 信息                                         |
| :----- | :------------------------------------------- |
| 主机   | `pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com` |
| 端口   | `5432`                                       |
| 数据库 | `root`                                       |
| 用户   | `yuncailian`                                 |
| 密码   | `@Xinxibu1717`                               |

### 需要迁移的模式（30个）

```
abpzjk, ai_model_manager, ai_model_sysu, auth_center, camunda, ccgp, 
communal, ctpsp, financial_center,job_proxy, margin_docking_consumer, 
message_management_center, notice, oa_management_center, onlyoffice_center, 
pay, platformcenterdb, process_center, redxun_docking, selenium, sqlitedata, 
third_party_oa_docking, third_party_platform, tianyanchai_info, 
upload_center, usercenter, websocket

 gateway, nacos, sqliteolog可忽略
```



------

## 第一阶段：导出数据

### 1.1 单模式导出命令模板

```
docker exec -e PGPASSWORD='密码' 容器名 pg_dump -U 用户 -d 数据库 -n 模式名 -O -x --no-tablespaces --inserts > 模式名.sql 2>&1
```



### 1.2 批量导出脚本

创建 `export_all_schemas.sh`：

```
#!/bin/bash

# 配置
CONTAINER_NAME="postgres"
DB_NAME="root"
DB_USER="root"
DB_PASS="Xinxibu1717..."
EXPORT_DIR="./exports_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="export_all.log"

# 模式列表
SCHEMAS=(
    "abpzjk" "ai_model_manager" "ai_model_sysu" "auth_center"
    "camunda" "ccgp" "communal" "ctpsp" "financial_center"
    "gateway" "job_proxy" "margin_docking_consumer"
    "message_management_center" "nacos" "notice"
    "oa_management_center" "onlyoffice_center" "pay"
    "platformcenterdb" "process_center" "redxun_docking"
    "selenium" "sqlitedata" "sqliteolog"
    "third_party_oa_docking" "third_party_platform"
    "tianyanchai_info" "upload_center" "usercenter" "websocket"
)

mkdir -p "$EXPORT_DIR"

echo "开始批量导出: $(date)" | tee "$LOG_FILE"

for schema in "${SCHEMAS[@]}"; do
    echo "导出: $schema" | tee -a "$LOG_FILE"
    OUTPUT_FILE="$EXPORT_DIR/${schema}.sql"
    
    docker exec -e PGPASSWORD="$DB_PASS" "$CONTAINER_NAME" \
        pg_dump -U "$DB_USER" -d "$DB_NAME" -n "$schema" \
        -O -x --no-tablespaces --inserts > "$OUTPUT_FILE" 2>> "$LOG_FILE"
    
    if [ $? -eq 0 ] && [ -s "$OUTPUT_FILE" ]; then
        SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
        echo "  ✅ 成功 - 大小: $SIZE" | tee -a "$LOG_FILE"
    else
        echo "  ❌ 失败" | tee -a "$LOG_FILE"
    fi
done

echo "导出完成: $(date)" | tee -a "$LOG_FILE"
echo "文件位置: $(pwd)/$EXPORT_DIR" | tee -a "$LOG_FILE"
```



**执行：**

```
chmod +x export_all_schemas.sh
nohup ./export_all_schemas.sh > /dev/null 2>&1 &
```



### 1.3 导出参数说明

| 参数               | 作用                         |
| :----------------- | :--------------------------- |
| `-n schema`        | 只导出指定模式               |
| `-O`               | 不包含所有者信息             |
| `-x`               | 不导出权限                   |
| `--no-tablespaces` | 不指定表空间                 |
| `--inserts`        | 使用 INSERT 语句（兼容性好） |

------

## 第二阶段：传输文件

### 2.1 查看导出文件

```
cd /mnt/db193/database/pg_dump导出的sql/root
ls -lh
```



**文件大小参考：**

```
tianyanchai_info.sql    11.5 GB
camunda.sql             3.1 GB
sqlitedata.sql          2.4 GB
platformcenterdb.sql    1.6 GB
...其他文件
```



### 2.2 如果需要传输到其他服务器

```
# 打包所有 SQL 文件
tar -czf all_schemas.tar.gz *.sql

# 传输到阿里云服务器（如果需要）
scp all_schemas.tar.gz root@目标服务器:/path/

# 解压
tar -xzf all_schemas.tar.gz
```



------

## 第三阶段：导入数据

### 3.1 清理目标数据库（可选）

⚠️ **警告：删除前请确认已备份**

```
-- 删除所有自定义模式
DROP SCHEMA IF EXISTS abpzjk CASCADE;
DROP SCHEMA IF EXISTS ai_model_manager CASCADE;
DROP SCHEMA IF EXISTS ai_model_sysu CASCADE;
DROP SCHEMA IF EXISTS auth_center CASCADE;
DROP SCHEMA IF EXISTS camunda CASCADE;
DROP SCHEMA IF EXISTS ccgp CASCADE;
DROP SCHEMA IF EXISTS communal CASCADE;
DROP SCHEMA IF EXISTS ctpsp CASCADE;
DROP SCHEMA IF EXISTS financial_center CASCADE;
DROP SCHEMA IF EXISTS gateway CASCADE;
DROP SCHEMA IF EXISTS job_proxy CASCADE;
DROP SCHEMA IF EXISTS margin_docking_consumer CASCADE;
DROP SCHEMA IF EXISTS message_management_center CASCADE;
DROP SCHEMA IF EXISTS nacos CASCADE;
DROP SCHEMA IF EXISTS notice CASCADE;
DROP SCHEMA IF EXISTS oa_management_center CASCADE;
DROP SCHEMA IF EXISTS onlyoffice_center CASCADE;
DROP SCHEMA IF EXISTS pay CASCADE;
DROP SCHEMA IF EXISTS platformcenterdb CASCADE;
DROP SCHEMA IF EXISTS process_center CASCADE;
DROP SCHEMA IF EXISTS redxun_docking CASCADE;
DROP SCHEMA IF EXISTS selenium CASCADE;
DROP SCHEMA IF EXISTS sqlitedata CASCADE;
DROP SCHEMA IF EXISTS sqliteolog CASCADE;
DROP SCHEMA IF EXISTS third_party_oa_docking CASCADE;
DROP SCHEMA IF EXISTS third_party_platform CASCADE;
DROP SCHEMA IF EXISTS tianyanchai_info CASCADE;
DROP SCHEMA IF EXISTS upload_center CASCADE;
DROP SCHEMA IF EXISTS usercenter CASCADE;
DROP SCHEMA IF EXISTS websocket CASCADE;
```



执行删除：

```
export PGPASSWORD='@Xinxibu1717'
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -f drop_all_schemas.sql
```



### 3.2 批量导入脚本

创建 `batch_import_all.sh`：

```
#!/bin/bash

# 阿里云 RDS 连接信息
export PGPASSWORD='@Xinxibu1717'
RDS_HOST="pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com"
RDS_PORT="5432"
RDS_USER="yuncailian"
RDS_DB="root"

SQL_DIR="/mnt/db193/database/pg_dump导出的sql/root"
LOG_FILE="${SQL_DIR}/import_all_$(date +%Y%m%d_%H%M%S).log"

cd "$SQL_DIR"

# 按文件大小从小到大排序导入（小文件先导，大文件后导）
SQL_FILES=$(ls -S *.sql | tac)

echo "=========================================" | tee "$LOG_FILE"
echo "批量导入开始: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "目标: $RDS_HOST:$RDS_PORT/$RDS_DB" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

SUCCESS=0
FAIL=0
START_TOTAL=$(date +%s)

for sql_file in $SQL_FILES; do
    if [ ! -f "$sql_file" ]; then
        continue
    fi
    
    FILE_SIZE=$(ls -lh "$sql_file" | awk '{print $5}')
    echo ""
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始导入: $sql_file (大小: $FILE_SIZE)" | tee -a "$LOG_FILE"
    START_TIME=$(date +%s)
    
    psql -h "$RDS_HOST" -p "$RDS_PORT" -U "$RDS_USER" -d "$RDS_DB" \
        -f "$sql_file" >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        echo "✅ 导入成功: $sql_file (耗时: ${DURATION}秒)" | tee -a "$LOG_FILE"
        ((SUCCESS++))
    else
        echo "❌ 导入失败: $sql_file" | tee -a "$LOG_FILE"
        ((FAIL++))
    fi
done

END_TOTAL=$(date +%s)
TOTAL_DURATION=$((END_TOTAL - START_TOTAL))
TOTAL_MIN=$((TOTAL_DURATION / 60))
TOTAL_SEC=$((TOTAL_DURATION % 60))

echo ""
echo "=========================================" | tee -a "$LOG_FILE"
echo "导入完成: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "总耗时: ${TOTAL_MIN}分${TOTAL_SEC}秒" | tee -a "$LOG_FILE"
echo "成功: $SUCCESS, 失败: $FAIL" | tee -a "$LOG_FILE"
echo "日志: $LOG_FILE" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

unset PGPASSWORD
```



**执行导入：**

```
chmod +x batch_import_all.sh
nohup ./batch_import_all.sh > /dev/null 2>&1 &

# 查看进程
ps aux | grep batch_import

# 实时查看日志
tail -f import_all_*.log
```



### 3.3 导入单个文件（如需重试）

```
export PGPASSWORD='@Xinxibu1717'
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -f platformcenterdb.sql
```



### 3.4 使用 screen 防止断连（推荐）

```
# 安装 screen
yum install screen -y

# 创建会话
screen -S import_db

# 在 screen 中执行
export PGPASSWORD='@Xinxibu1717'
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -f platformcenterdb.sql

# 脱离会话：Ctrl+A, 然后按 D
# 重新连接：screen -r import_db
```



------

## 第四阶段：验证

### 4.1 验证模式是否导入成功

```
export PGPASSWORD='@Xinxibu1717'

# 查看所有模式
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -c "\dn"

# 查看特定模式的表
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -c "\dt usercenter.*"

# 统计每个模式的表数量
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root << EOF
SELECT 
    schemaname, 
    count(*) as table_count 
FROM pg_tables 
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
GROUP BY schemaname 
ORDER BY schemaname;
EOF
```



### 4.2 验证数据行数

```
# 对比源和目标的数据量（抽样检查）
# 在源数据库执行
docker exec postgres psql -U root -d root -c "SELECT count(*) FROM usercenter.某个表;"

# 在目标数据库执行
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -c "SELECT count(*) FROM usercenter.某个表;"
```



### 4.3 查看导入日志中的错误

```
# 查看错误
grep -i "error\|fail\|ERROR" import_all_*.log

# 查看成功记录
grep "✅" import_all_*.log
```



------

## 常见问题与解决方案

### Q1: psql 版本警告

```
警告：psql 版本9.2， 服务器版本18.0
```



**解决：** 升级客户端

```
# 安装新版客户端
yum install postgresql15 -y
# 或使用新版路径
/usr/pgsql-15/bin/psql -h ...
```



### Q2: 大文件导入超时

**解决：** 设置超时参数

```
PGOPTIONS='-c statement_timeout=0 -c lock_timeout=0' psql -h ... -f large_file.sql
```



### Q3: 网络断开导致导入中断

**解决：** 使用 nohup 或 screen

```
# nohup 方式
nohup psql -h ... -f file.sql > import.log 2>&1 &

# screen 方式
screen -S import
psql -h ... -f file.sql
# Ctrl+A, D 脱离
```



### Q4: 内存不足错误

**解决：** 分批导入或调整参数

```
# 使用 --inserts 已经比 COPY 更省内存
# 或者分块导入
split -l 10000 large_file.sql chunk_
```



### Q5: 权限错误

```
ERROR: permission denied for schema
```



**解决：** 确保用户有相应权限

```
GRANT ALL ON SCHEMA schema_name TO yuncailian;
GRANT ALL ON ALL TABLES IN SCHEMA schema_name TO yuncailian;
```



------

## 📊 完整执行流程汇总

bash

复制下载

```
# 1. 导出数据（在源服务器）
cd /mnt/db193/database
./export_all_schemas.sh

# 2. 检查导出文件
cd pg_dump导出的sql/root
ls -lh

# 3. 清理目标数据库（可选）
export PGPASSWORD='@Xinxibu1717'
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -f drop_all_schemas.sql

# 4. 批量导入
nohup ./batch_import_all.sh > /dev/null 2>&1 &

# 5. 监控进度
tail -f import_all_*.log

# 6. 验证结果
psql -h pgm-wz9xb2914vsmy87k5o.pg.rds.aliyuncs.com -p 5432 -U yuncailian -d root -c "\dn"
```



------

## 📁 文件清单

| 文件                    | 用途               |
| :---------------------- | :----------------- |
| `export_all_schemas.sh` | 批量导出脚本       |
| `batch_import_all.sh`   | 批量导入脚本       |
| `drop_all_schemas.sql`  | 清理目标数据库脚本 |
| `import_all_*.log`      | 导入日志文件       |
| `export_all.log`        | 导出日志文件       |