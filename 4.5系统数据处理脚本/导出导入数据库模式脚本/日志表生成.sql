
-- ----------------------------
-- auth_center
-- ----------------------------DROP SEQUENCE IF EXISTS "auth_center"."javaauditlogs_id_seq";
CREATE SEQUENCE "auth_center"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "auth_center"."java_audit_logs";
CREATE TABLE "auth_center"."java_audit_logs" (
  "id" int8 NOT NULL DEFAULT nextval('"auth_center".javaauditlogs_id_seq'::regclass),
  "client_ip_address" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "execution_duration" int4 NOT NULL,
  "execution_time" timestamp(6) NOT NULL,
  "method_name" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenant_id" int4,
  "user_id" int8
)
;
COMMENT ON COLUMN "auth_center"."java_audit_logs"."client_ip_address" IS 'ip';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."exception" IS '异常';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."execution_duration" IS '请求耗时';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."execution_time" IS '请求时间';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."method_name" IS '请求地址';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."parameters" IS '请求参数';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."tenant_id" IS '平台id';
COMMENT ON COLUMN "auth_center"."java_audit_logs"."user_id" IS '用户id';




-- ----------------------------
-- camunda
-- ----------------------------
DROP SEQUENCE IF EXISTS "camunda"."java_log_id_seq";
CREATE SEQUENCE "camunda"."java_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

DROP TABLE IF EXISTS "camunda"."java_log";
CREATE TABLE "camunda"."java_log" (
  "id" int4 NOT NULL DEFAULT nextval('"camunda".java_log_id_seq'::regclass),
  "clientipaddress" varchar(255) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "executionduration" int4,
  "executiontime" timestamp(6),
  "methodname" varchar(255) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "camunda"."java_log"."clientipaddress" IS 'ip';
COMMENT ON COLUMN "camunda"."java_log"."exception" IS '异常';
COMMENT ON COLUMN "camunda"."java_log"."executionduration" IS '请求耗时';
COMMENT ON COLUMN "camunda"."java_log"."executiontime" IS '请求时间';
COMMENT ON COLUMN "camunda"."java_log"."methodname" IS '请求地址';
COMMENT ON COLUMN "camunda"."java_log"."parameters" IS '请求参数';




-- ----------------------------
-- ctpsp
-- ----------------------------
DROP SEQUENCE IF EXISTS "ctpsp"."javaauditlogs_id_seq";
CREATE SEQUENCE "ctpsp"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

DROP TABLE IF EXISTS "ctpsp"."javaauditlogs";
CREATE TABLE "ctpsp"."javaauditlogs" (
  "id" int8 NOT NULL DEFAULT nextval('"ctpsp".javaauditlogs_id_seq'::regclass),
  "clientipaddress" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "executionduration" int4 NOT NULL,
  "executiontime" timestamp(6) NOT NULL,
  "methodname" varchar(1000) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenantid" int4,
  "userid" int8,
  "responsedata" varchar(503) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."clientipaddress" IS 'ip';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."exception" IS '异常';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."executionduration" IS '请求耗时';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."executiontime" IS '请求发起时间';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."methodname" IS '请求地址';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."parameters" IS '请求参数';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."tenantid" IS '平台id';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."userid" IS '用户id';
COMMENT ON COLUMN "ctpsp"."javaauditlogs"."responsedata" IS '响应数据（超过500截断）';
COMMENT ON TABLE "ctpsp"."javaauditlogs" IS '日志';




-- ----------------------------
-- job_proxy
-- ----------------------------
DROP SEQUENCE IF EXISTS "job_proxy"."javaauditlogs_id_seq";
CREATE SEQUENCE "job_proxy"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "job_proxy"."java_audit_logs";
CREATE TABLE "job_proxy"."java_audit_logs" (
  "id" int8 NOT NULL DEFAULT nextval('"job_proxy".javaauditlogs_id_seq'::regclass),
  "client_ip_address" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "execution_duration" int4 NOT NULL,
  "execution_time" timestamp(6) NOT NULL,
  "method_name" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenant_id" int4,
  "user_id" int8
)
;
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."client_ip_address" IS 'ip';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."exception" IS '异常';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."execution_duration" IS '请求耗时';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."execution_time" IS '请求时间';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."method_name" IS '请求地址';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."parameters" IS '请求参数';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."tenant_id" IS '平台id';
COMMENT ON COLUMN "job_proxy"."java_audit_logs"."user_id" IS '用户id';





-- ----------------------------
-- margin_docking_consumer
-- ----------------------------
DROP TABLE IF EXISTS "margin_docking_consumer"."javaauditlogs";
CREATE TABLE "margin_docking_consumer"."javaauditlogs" (
  "id" int8 NOT NULL GENERATED BY DEFAULT AS IDENTITY (
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1
),
  "clientipaddress" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "executionduration" int4 NOT NULL,
  "executiontime" timestamp(6) NOT NULL,
  "methodname" varchar(1000) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenantid" int4,
  "userid" int8
)
;
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."clientipaddress" IS 'ip';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."exception" IS '异常';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."executionduration" IS '请求耗时';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."executiontime" IS '请求发起时间';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."methodname" IS '请求地址';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."parameters" IS '请求参数';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."tenantid" IS '平台id';
COMMENT ON COLUMN "margin_docking_consumer"."javaauditlogs"."userid" IS '用户id';
COMMENT ON TABLE "margin_docking_consumer"."javaauditlogs" IS '日志';




-- ----------------------------
-- message_management_center
-- ----------------------------
DROP SEQUENCE IF EXISTS "message_management_center"."java_log_id_seq";
CREATE SEQUENCE "message_management_center"."java_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "message_management_center"."java_log";
CREATE TABLE "message_management_center"."java_log" (
  "id" int4 NOT NULL DEFAULT nextval('"message_management_center".java_log_id_seq'::regclass),
  "user_id" int8,
  "clientip_address" varchar(255) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "execution_duration" int4,
  "execution_time" timestamp(6),
  "method_name" varchar(255) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "message_management_center"."java_log"."user_id" IS '用户id';
COMMENT ON COLUMN "message_management_center"."java_log"."clientip_address" IS 'ip';
COMMENT ON COLUMN "message_management_center"."java_log"."exception" IS '异常';
COMMENT ON COLUMN "message_management_center"."java_log"."execution_duration" IS '请求耗时';
COMMENT ON COLUMN "message_management_center"."java_log"."execution_time" IS '请求时间';
COMMENT ON COLUMN "message_management_center"."java_log"."method_name" IS '请求地址';
COMMENT ON COLUMN "message_management_center"."java_log"."parameters" IS '请求参数';
COMMENT ON TABLE "message_management_center"."java_log" IS '日志表';





-- ----------------------------
-- oa_management_center
-- ----------------------------

DROP SEQUENCE IF EXISTS "oa_management_center"."javaauditlogs_id_seq";
CREATE SEQUENCE "oa_management_center"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;

DROP TABLE IF EXISTS "oa_management_center"."java_audit_logs";
CREATE TABLE "oa_management_center"."java_audit_logs" (
  "id" int8 NOT NULL DEFAULT nextval('"oa_management_center".javaauditlogs_id_seq'::regclass),
  "client_ip_address" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "execution_duration" int4 NOT NULL,
  "execution_time" timestamp(6) NOT NULL,
  "method_name" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenant_id" int4,
  "user_id" int8
)
;
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."client_ip_address" IS 'ip';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."exception" IS '异常';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."execution_duration" IS '请求耗时';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."execution_time" IS '请求时间';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."method_name" IS '请求地址';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."parameters" IS '请求参数';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."tenant_id" IS '平台id';
COMMENT ON COLUMN "oa_management_center"."java_audit_logs"."user_id" IS '用户id';
COMMENT ON TABLE "oa_management_center"."java_audit_logs" IS '日志';





-- ----------------------------
-- platformcenterdb
-- ----------------------------
DROP SEQUENCE IF EXISTS "platformcenterdb"."javaauditlogs_id_seq";
CREATE SEQUENCE "platformcenterdb"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "platformcenterdb"."javaauditlogs";
CREATE TABLE "platformcenterdb"."javaauditlogs" (
  "id" int8 NOT NULL DEFAULT nextval('"platformcenterdb".javaauditlogs_id_seq'::regclass),
  "clientipaddress" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "executionduration" int4,
  "executiontime" timestamp(6),
  "methodname" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenantid" int4,
  "userid" int8
)
;
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."clientipaddress" IS 'ip';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."exception" IS '异常';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."executionduration" IS '请求耗时';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."executiontime" IS '请求时间';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."methodname" IS '请求地址';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."parameters" IS '请求参数';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."tenantid" IS '平台id';
COMMENT ON COLUMN "platformcenterdb"."javaauditlogs"."userid" IS '用户id';
COMMENT ON TABLE "platformcenterdb"."javaauditlogs" IS '日志';





-- ----------------------------
-- third_party_oa_docking
-- ----------------------------
DROP SEQUENCE IF EXISTS "third_party_oa_docking"."javaauditlogs_id_seq";
CREATE SEQUENCE "third_party_oa_docking"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "third_party_oa_docking"."java_audit_logs";
CREATE TABLE "third_party_oa_docking"."java_audit_logs" (
  "id" int8 NOT NULL DEFAULT nextval('"third_party_oa_docking".javaauditlogs_id_seq'::regclass),
  "client_ip_address" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "execution_duration" int4 NOT NULL,
  "execution_time" timestamp(6) NOT NULL,
  "method_name" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenant_id" int4,
  "user_id" int8
)
;
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."client_ip_address" IS 'ip';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."exception" IS '异常';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."execution_duration" IS '请求耗时';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."execution_time" IS '请求时间';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."method_name" IS '请求地址';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."parameters" IS '请求参数';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."tenant_id" IS '平台id';
COMMENT ON COLUMN "third_party_oa_docking"."java_audit_logs"."user_id" IS '用户id';
COMMENT ON TABLE "third_party_oa_docking"."java_audit_logs" IS '日志';





-- ----------------------------
-- third_party_platform
-- ----------------------------
DROP SEQUENCE IF EXISTS "third_party_platform"."sys_log_id_seq";
CREATE SEQUENCE "third_party_platform"."sys_log_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "third_party_platform"."sys_log";
CREATE TABLE "third_party_platform"."sys_log" (
  "id" int4 NOT NULL DEFAULT nextval('"third_party_platform".sys_log_id_seq'::regclass),
  "url" varchar(255) COLLATE "pg_catalog"."default",
  "user_id" int4,
  "tenant_id" int4,
  "operation" varchar(255) COLLATE "pg_catalog"."default",
  "result" varchar(1024) COLLATE "pg_catalog"."default",
  "take_time" int4,
  "method" varchar(255) COLLATE "pg_catalog"."default",
  "params" text COLLATE "pg_catalog"."default",
  "ip" varchar(255) COLLATE "pg_catalog"."default",
  "access_time" timestamp(6)
)
;
COMMENT ON COLUMN "third_party_platform"."sys_log"."url" IS '请求路径';
COMMENT ON COLUMN "third_party_platform"."sys_log"."user_id" IS '用户id';
COMMENT ON COLUMN "third_party_platform"."sys_log"."tenant_id" IS '平台/租户id';
COMMENT ON COLUMN "third_party_platform"."sys_log"."operation" IS '操作';
COMMENT ON COLUMN "third_party_platform"."sys_log"."result" IS '请求结果';
COMMENT ON COLUMN "third_party_platform"."sys_log"."take_time" IS '耗时';
COMMENT ON COLUMN "third_party_platform"."sys_log"."method" IS '请求方法';
COMMENT ON COLUMN "third_party_platform"."sys_log"."params" IS '请求参数';
COMMENT ON COLUMN "third_party_platform"."sys_log"."ip" IS 'IP地址';
COMMENT ON COLUMN "third_party_platform"."sys_log"."access_time" IS '访问时间';
COMMENT ON TABLE "third_party_platform"."sys_log" IS '系统日志';





-- ----------------------------
-- upload_center
-- ----------------------------
DROP SEQUENCE IF EXISTS "upload_center"."javaauditlogs_id_seq";
CREATE SEQUENCE "upload_center"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "upload_center"."javaauditlogs";
CREATE TABLE "upload_center"."javaauditlogs" (
  "id" int8 NOT NULL DEFAULT nextval('"upload_center".javaauditlogs_id_seq'::regclass),
  "clientipaddress" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "executionduration" int4 NOT NULL DEFAULT '-1'::integer,
  "executiontime" timestamp(6) NOT NULL,
  "methodname" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenantid" int4,
  "userid" int8
)
;
COMMENT ON COLUMN "upload_center"."javaauditlogs"."clientipaddress" IS 'ip';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."exception" IS '异常';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."executionduration" IS '请求耗时';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."executiontime" IS '请求发起时间';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."methodname" IS '请求地址';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."parameters" IS '请求参数';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."tenantid" IS '平台id';
COMMENT ON COLUMN "upload_center"."javaauditlogs"."userid" IS '用户id';
COMMENT ON TABLE "upload_center"."javaauditlogs" IS '日志';





-- ----------------------------
-- usercenter
-- ----------------------------
DROP SEQUENCE IF EXISTS "usercenter"."javaauditlogs_id_seq";
CREATE SEQUENCE "usercenter"."javaauditlogs_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 9223372036854775807
START 1
CACHE 1;


DROP TABLE IF EXISTS "usercenter"."javaauditlogs";
CREATE TABLE "usercenter"."javaauditlogs" (
  "id" int8 NOT NULL DEFAULT nextval('"usercenter".javaauditlogs_id_seq'::regclass),
  "clientipaddress" varchar(64) COLLATE "pg_catalog"."default",
  "exception" text COLLATE "pg_catalog"."default",
  "executionduration" int4 NOT NULL,
  "executiontime" timestamp(6) NOT NULL,
  "methodname" varchar(256) COLLATE "pg_catalog"."default",
  "parameters" text COLLATE "pg_catalog"."default",
  "tenantid" int4,
  "userid" int8
)
;
COMMENT ON COLUMN "usercenter"."javaauditlogs"."clientipaddress" IS 'ip';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."exception" IS '异常';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."executionduration" IS '请求耗时';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."executiontime" IS '请求时间';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."methodname" IS '请求地址';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."parameters" IS '请求参数';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."tenantid" IS '平台id';
COMMENT ON COLUMN "usercenter"."javaauditlogs"."userid" IS '用户id';
COMMENT ON TABLE "usercenter"."javaauditlogs" IS '日志';