-- platformcenterdb

-- 1. 先创建转换函数
CREATE OR REPLACE FUNCTION boolean_to_smallint(b boolean)
RETURNS smallint AS $$
    SELECT CASE WHEN b THEN 1::smallint ELSE 0::smallint END;
$$ LANGUAGE sql IMMUTABLE;

-- 2. 创建隐式转换（关键！）
CREATE CAST (boolean AS smallint)
    WITH FUNCTION boolean_to_smallint(boolean)
    AS IMPLICIT;  -- 关键：IMPLICIT 让转换自动发生

-- 3. 验证转换是否生效
SELECT true::smallint;  -- 应该返回 1，不再报错