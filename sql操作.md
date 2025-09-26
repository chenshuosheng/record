1. 数据表备份并重置序列值

```sql
-- 1. 创建备份表（不包含默认值）
CREATE TABLE gateway.gateway_log_bak (
  "target_server" varchar(255),
  "request_path" varchar(255),
  "request_method" varchar(20),
  "schema" varchar(50),
  "request_header" text,
  "request_parameter" text,
  "request_body" text,
  "response_data" text,
  "ip" varchar(45),
  "request_moment" timestamp(6),
  "execute_time" int8,
  "id" int8 NOT NULL
);

-- 2. 添加主键
ALTER TABLE gateway.gateway_log_bak ADD PRIMARY KEY (id);

-- 3. 分批插入数据（避免大事务）
DO $$
DECLARE
    batch_size INTEGER := 50000; -- 每批5万条
    total_rows BIGINT;
    processed_rows BIGINT := 0;
    start_time TIMESTAMP;
BEGIN
    -- 获取总行数
    SELECT COUNT(*) INTO total_rows FROM gateway.gateway_log;
    RAISE NOTICE '总记录数: %', total_rows;
    
    start_time := clock_timestamp();
    
    -- 分批插入
    WHILE processed_rows < total_rows LOOP
        INSERT INTO gateway.gateway_log_bak 
        SELECT target_server, request_path, request_method, schema, 
               request_header, request_parameter, request_body, 
               response_data, ip, request_moment, execute_time, id
        FROM gateway.gateway_log 
        ORDER BY id
        LIMIT batch_size 
        OFFSET processed_rows;
        
        -- 提交当前批次，释放锁
        COMMIT;
        
        processed_rows := processed_rows + batch_size;
        
        -- 进度报告
        RAISE NOTICE '已处理 %/% 条记录 (%.2f%%)，耗时: %', 
            LEAST(processed_rows, total_rows),
            total_rows,
            (LEAST(processed_rows, total_rows) * 100.0 / total_rows),
            (clock_timestamp() - start_time);
        
        -- 短暂暂停
        PERFORM pg_sleep(0.05);
    END LOOP;
    
    RAISE NOTICE '数据备份完成，总耗时: %', (clock_timestamp() - start_time);
END $$;

-- 4. 创建索引（并发创建，不锁表）
CREATE INDEX CONCURRENTLY idx_gateway_log_bak_request_moment 
ON gateway.gateway_log_bak(request_moment);

CREATE INDEX CONCURRENTLY idx_gateway_log_bak_request_path 
ON gateway.gateway_log_bak(request_path);

-- 5. 验证数据一致性
SELECT 
    (SELECT COUNT(*) FROM gateway.gateway_log) as original_count,
    (SELECT COUNT(*) FROM gateway.gateway_log_bak) as backup_count;

-- 6. 清空原表并重置序列（在业务低峰期执行）
TRUNCATE TABLE gateway.gateway_log;
ALTER SEQUENCE gateway.gateway_log_id_seq RESTART WITH 1;
```



2. 统计表的磁盘占用空间

   ```sql
   SELECT 
       pg_size_pretty(pg_total_relation_size('gateway.gateway_log')) as total_size,
       pg_size_pretty(pg_relation_size('gateway.gateway_log')) as table_size,
       pg_size_pretty(pg_total_relation_size('gateway.gateway_log') - pg_relation_size('gateway.gateway_log')) as indexes_toast_size;
   ```

   

3. 序列操作

   ```
   SELECT * FROM pg_sequences WHERE sequencename = 'supervisor_extract_project_id_seq';
   
   CREATE SEQUENCE abpzjk.supervisor_extract_pool_id_seq
       START WITH 1
       INCREMENT BY 1
       MINVALUE 1
       MAXVALUE 9223372036854775807
       CACHE 1
       NO CYCLE;
   ```

   

4. 类型转化

   ```sql
   CREATE 
   	OR REPLACE FUNCTION "public"."boolean_to_smallint" ( "b" bool ) RETURNS "pg_catalog"."int2" AS $BODY$ BEGIN
   		RETURN ( b :: BOOLEAN ) :: bool :: INT;
   	
   END;
   $BODY$ LANGUAGE plpgsql VOLATILE COST 100 CREATE CAST ( bool AS int2 ) WITH FUNCTION PUBLIC.boolean_to_smallint ( bool ) AS IMPLICIT;
   ```

   

5. 统计字段值为空的字段

   ```sql
   DROP FUNCTION IF EXISTS find_null_columns(text);
   
   CREATE OR REPLACE FUNCTION find_null_columns(table_name text)
   RETURNS TABLE(column_name text, column_comment text) AS $$
   DECLARE
       r RECORD;
       is_all_null BOOLEAN;
       rec RECORD;
   BEGIN
       FOR r IN 
           SELECT 
               a.attname AS column_name,
               pg_catalog.col_description(a.attrelid, a.attnum) AS column_comment,
               t.typname AS data_type
           FROM 
               pg_class c
               JOIN pg_attribute a ON c.oid = a.attrelid
               JOIN pg_type t ON a.atttypid = t.oid
           WHERE 
               c.relname = $1
               AND a.attnum > 0
               AND NOT a.attisdropped
               AND c.relkind IN ('r', 'v', 'm', 'f', 'p') -- 常规表、视图等
       LOOP
           -- 判断字段类型，决定是否检查空字符串
           IF r.data_type IN ('text', 'varchar', 'char', 'json', 'jsonb') THEN
               EXECUTE format(
                   'SELECT NOT EXISTS (SELECT 1 FROM %I WHERE %I IS NOT NULL AND %I <> %L)',
                   table_name, r.column_name, r.column_name, ''
               ) INTO is_all_null;
           ELSE
               EXECUTE format(
                   'SELECT NOT EXISTS (SELECT 1 FROM %I WHERE %I IS NOT NULL)',
                   table_name, r.column_name
               ) INTO is_all_null;
           END IF;
   
           IF is_all_null THEN
               column_name := r.column_name;
               column_comment := r.column_comment;
               RETURN NEXT;
           END IF;
       END LOOP;
   
       RETURN;
   END;
   $$ LANGUAGE plpgsql;
   
   SELECT * FROM find_null_columns('project') ORDER BY column_name asc;
   
   SELECT * FROM find_null_columns('demandlist')ORDER BY column_name asc;
   ```

   

6. 创建索引并比较效果

   ```sql
   -- 项目表
   CREATE INDEX idx_project_tenantid ON communal.project (tenantid);
   
   EXPLAIN ANALYZE SELECT * FROM communal.project WHERE tenantid = '10000';
   -- 创建索引后
   --Bitmap Heap Scan on project  (cost=17.80..589.15 rows=1228 width=2873) (actual time=0.121..0.750 rows=1215 loops=1)
   --  Recheck Cond: (tenantid = '10000'::text)
   --  Heap Blocks: exact=252
   --  ->  Bitmap Index Scan on idx_project_tenantid  (cost=0.00..17.49 rows=1228 width=0) (actual time=0.078..0.078 rows=1215 loops=1)
   --        Index Cond: (tenantid = '10000'::text)
   --Planning Time: 0.226 ms
   --Execution Time: 0.855 ms
   
   
   -- 采购需求表
   -----------------------------------------------------------------------------------------------------------------------------
   EXPLAIN ANALYZE SELECT * FROM communal.demandlist WHERE tenantid = '10000';
   -- 创建索引前
   -- Seq Scan on demandlist  (cost=0.00..86.88 rows=537 width=4407) (actual time=0.064..1.009 rows=538 loops=1)
   --  Filter: (tenantid = '10000'::text)
   --  Rows Removed by Filter: 742
   --Planning Time: 1.482 ms
   --Execution Time: 1.068 ms
   
   -- 创建索引后
   -- tenantid
   CREATE INDEX idx_demandlist_tenantid ON communal.demandlist (tenantid);
   -- Seq Scan on demandlist  (cost=0.00..87.00 rows=541 width=4407) (actual time=0.030..0.443 rows=538 loops=1)
   --  Filter: (tenantid = '10000'::text)
   --  Rows Removed by Filter: 742
   --Planning Time: 0.329 ms
   --Execution Time: 0.491 ms
   
   -- state + tenantid
   EXPLAIN ANALYZE SELECT * FROM communal.demandlist WHERE state = 14 and tenantid = '10000';
   -- 创建索引前
   -- Seq Scan on demandlist  (cost=0.00..90.20 rows=91 width=4407) (actual time=0.059..0.497 rows=154 loops=1)
   --  Filter: ((state = 14) AND (tenantid = '10000'::text))
   --  Rows Removed by Filter: 1126
   -- Planning Time: 0.161 ms
   -- Execution Time: 0.534 ms
   -- 创建索引后
   CREATE INDEX idx_demandlist_state_tenantid_complex ON communal.demandlist (state, tenantid);
   -- Bitmap Heap Scan on demandlist  (cost=5.21..81.37 rows=91 width=4407) (actual time=0.035..0.139 rows=154 loops=1)
   --  Recheck Cond: ((state = 14) AND (tenantid = '10000'::text))
   --  Heap Blocks: exact=51
   --  ->  Bitmap Index Scan on idx_demandlist_state_tenantid_complex  (cost=0.00..5.19 rows=91 width=0) (actual time=0.024..0.024 rows=154 loops=1)
   --        Index Cond: ((state = 14) AND (tenantid = '10000'::text))
   -- Planning Time: 0.215 ms
   -- Execution Time: 0.187 ms
   
   
   
   
   -- 数据字典表
   -----------------------------------------------------------------------------------------------------------------------------
   -- 创建索引前
   -- Gather  (cost=1000.00..5989.56 rows=1 width=217) (actual time=24.164..26.667 rows=0 loops=1)
   --  Workers Planned: 2
   --  Workers Launched: 2
   --  ->  Parallel Seq Scan on dictionary  (cost=0.00..4989.46 rows=1 width=217) (actual time=19.028..19.028 rows=0 loops=3)
   --        Filter: ((item_parent IS NOT NULL) AND ((item_parent)::text <> ''::text) AND ((item_type)::text = '列表查询'::text) AND (platform_id = 10000))
   --        Rows Removed by Filter: 45563
   -- Planning Time: 0.583 ms
   -- Execution Time: 26.725 ms
   
   -- 创建索引后
   CREATE INDEX idx_dictionary_complex ON dictionary (platform_id, item_type, item_parent);
   -- Index Scan using idx_dictionary_complex on dictionary  (cost=0.42..8.44 rows=1 width=217) (actual time=0.056..0.057 rows=0 loops=1)
   --  Index Cond: ((platform_id = 10000) AND ((item_type)::text = '列表查询'::text) AND (item_parent IS NOT NULL))
   --  Filter: ((item_parent)::text <> ''::text)
   -- Planning Time: 0.352 ms
   -- Execution Time: 0.078 ms
   
   EXPLAIN ANALYZE SELECT * FROM communal."dictionary" WHERE item_parent <> '' and item_parent is not null and item_type = '列表查询' and platform_id = 10000;
   
   
   -- 采购目录表
   -----------------------------------------------------------------------------------------------------------------------------
   -- 创建索引前
   -- Index Scan using index_type_parent_sort_copy2 on procurement_catalog  (cost=0.41..7.54 rows=1 width=3250) (actual time=0.020..0.021 rows=0 loops=1)
   --  Index Cond: ((item_type)::text = '省分公司品目'::text)
   --  Filter: (platform_id = 10005)
   -- Planning Time: 0.118 ms
   -- Execution Time: 0.044 ms
   
   -- 创建索引后
   CREATE INDEX idx_procurement_catalog_complex ON communal."procurement_catalog" (item_type, platform_id);
   -- Index Scan using idx_procurement_catalog_complex on procurement_catalog  (cost=0.28..7.41 rows=1 width=3250) (actual time=0.020..0.020 rows=0 loops=1)
   --  Index Cond: (((item_type)::text = '省分公司品目'::text) AND (platform_id = 10005))
   -- Planning Time: 0.117 ms
   -- Execution Time: 0.046 ms
   
   EXPLAIN ANALYZE SELECT * FROM communal."procurement_catalog" WHERE item_type = '省分公司品目' and platform_id = 10005;
   ```

   
   
7. 查询表内存占用

   ```sql
   -- 查询所有表的大小（正确处理大小写）
   SELECT 
       n.nspname as schemaname,
       c.relname as tablename,
       pg_size_pretty(pg_total_relation_size(c.oid)) as total_size,
       pg_size_pretty(pg_table_size(c.oid)) as table_size,
       pg_size_pretty(pg_indexes_size(c.oid)) as index_size
   FROM pg_class c
   JOIN pg_namespace n ON n.oid = c.relnamespace
   WHERE c.relkind = 'r'  -- 普通表
   AND n.nspname NOT IN ('information_schema', 'pg_catalog')
   AND n.nspname !~ '^pg_toast'
   ORDER BY pg_total_relation_size(c.oid) DESC
   LIMIT 20;
   ```

   