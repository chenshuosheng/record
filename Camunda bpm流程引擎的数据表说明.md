Camunda bpm流程引擎的数据库由多个表组成，表名都以ACT开头，第二部分是说明表用途的两字符标识。笔者在工作中用的Camunda7.11版本共47张表。体验环境：http://www.yunchengxc.com

ACT_RE_*: 'RE’表示流程资源存储，这个前缀的表包含了流程定义和流程静态资源（图片，规则等），共5张表。
ACT_RU_*: 'RU’表示流程运行时。 这些运行时的表，包含流程实例，任务，变量，Job等运行中的数据。 Camunda只在流程实例执行过程中保存这些数据，在流程结束时就会删除这些记录， 这样运行时表的数据量最小，可以最快运行。共15张表。
ACT_ID_*: 'ID’表示组织用户信息，比如用户，组等，共6张表。
ACT_HI_*: 'HI’表示流程历史记录。 这些表包含历史数据，比如历史流程实例，变量，任务等，共18张表。
ACT_GE_*: ‘GE’表示流程通用数据， 用于不同场景下，共3张表。

一、数据表清单

| 分类 | 表名称 | 描述 |
| --- | --- | --- |
| 流程资源存储 | act_re_case_def | CMMN案例管理模型定义表 |
| 流程资源存储 | act_re_decision_def | DMN决策模型定义表 |
| 流程资源存储 | act_re_decision_req_def | 待确定 |
| 流程资源存储 | act_re_deployment | 流程部署表 |
| 流程资源存储 | act_re_procdef | BPMN流程模型定义表 |
| 流程运行时 | act_ru_authorization | 流程运行时收取表 |
| 流程运行时 | act_ru_batch | 流程执行批处理表 |
| 流程运行时 | act_ru_case_execution | CMMN案例运行执行表 |
| 流程运行时 | act_ru_case_sentry_part | 待确定 |
| 流程运行时 | act_ru_event_subscr | 流程事件订阅表 |
| 流程运行时 | act_ru_execution | BPMN流程运行时记录表 |
| 流程运行时 | act_ru_ext_task | 流程任务消息执行表 |
| 流程运行时 | act_ru_filter | 流程定义查询配置表 |
| 流程运行时 | act_ru_identitylink | 运行时流程人员表 |
| 流程运行时 | act_ru_incident | 运行时异常事件表 |
| 流程运行时 | act_ru_job | 流程运行时作业表 |
| 流程运行时 | act_ru_jobdef | 流程作业定义表 |
| 流程运行时 | act_ru_meter_log | 流程运行时度量日志表 |
| 流程运行时 | act_ru_task | 流程运行时任务表 |
| 流程运行时 | act_ru_variable | 流程运行时变量表 |
| 组织用户信息 | act_id_group | 群组信息表 |
| 组织用户信息 | act_id_info | 用户扩展信息表 |
| 组织用户信息 | act_id_membership | 用户群组关系表 |
| 组织用户信息 | act_id_tenant | 租户信息表 |
| 组织用户信息 | act_id_tenant_member | 用户租户关系表 |
| 组织用户信息 | act_id_user | 用户信息表 |
| 流程历史记录 | act_hi_actinst | 历史的活动实例表 |
| 流程历史记录 | act_hi_attachment | 历史的流程附件表 |
| 流程历史记录 | act_hi_batch | 历史的批处理记录表 |
| 流程历史记录 | act_hi_caseactinst | 历史的CMMN活动实例表 |
| 流程历史记录 | act_hi_caseinst | 历史的CMMN实例表 |
| 流程历史记录 | act_hi_comment | 历史的流程审批意见表 |
| 流程历史记录 | act_hi_dec_in | 历史的DMN变量输入表 |
| 流程历史记录 | act_hi_dec_out | 历史的DMN变量输出表 |
| 流程历史记录 | act_hi_decinst | 历史的DMN实例表 |
| 流程历史记录 | act_hi_detail | 历史的流程运行时变量详情记录表 |
| 流程历史记录 | act_hi_ext_task_log | 历史的流程任务消息执行表 |
| 流程历史记录 | act_hi_identitylink | 历史的流程运行过程中用户关系 |
| 流程历史记录 | act_hi_incident | 历史的流程异常事件记录表 |
| 流程历史记录 | act_hi_job_log | 历史的流程作业记录表 |
| 流程历史记录 | act_hi_op_log | 待确定 |
| 流程历史记录 | act_hi_procinst | 历史的流程实例 |
| 流程历史记录 | act_hi_taskinst | 历史的任务实例 |
| 流程历史记录 | act_hi_varinst | 历史的流程变量记录表 |
| 流程通用数据 | act_ge_bytearray | 流程引擎二进制数据表 |
| 流程通用数据 | act_ge_property | 流程引擎属性配置表 |
| 流程通用数据 | act_ge_schema_log | 数据库脚本执行日志表 |
流程引擎的最核心表是流程定义、流程执行、流程任务、流程变量和事件订阅表。它们之间的关系见下面的UML模型。




二、核心表介绍
  由于Camunda的表比较多，其中一部分是企业版功能需要的，比如批量操作功能、流程监控预警功能等，还有一部分是CMMN案例管理模型和DMN决策模型相关的表，本文仅介绍跟BPMN流程引擎相关的表。

1.	act_ge_bytearray（二进制数据表）
二进制数据表。存储通用的流程定义和流程资源，保存流程定义图片和xml、Serializable(序列化)的变量,即保存所有二进制数据。
| 字段名称           | 字段类型         | 可否为空   | 描述                         |
|--------------------|------------------|------------|------------------------------|
| ID_                | varchar(64)      | 否         | 主键                         |
| REV_               | int(11)          | 是         | 版本                         |
| NAME_              | varchar(255)     | 是         | 名称                         |
| DEPLOYMENT_ID_     | varchar(64)      | 是         | 部署ID                       |
| BYTES_             | longblob         | 是         | 字节内容                     |
| GENERATED_         | tinyint(4)       | 是         | 是否系统生成（0用户创建，null系统生成） |
| TENANT_ID_         | varchar(64)      | 是         | 租户ID                       |
| TYPE_              | int(11)          | 是         | 类型                         |
| CREATE_TIME_       | datetime         | 是         | 创建时间                     |
| ROOT_PROC_INST_ID_ | varchar(64)      | 是         | 流程实例根ID                 |
| REMOVAL_TIME_      | datetime         | 是         | 删除时间                     |



2.	act_ge_property（流程引擎配置表）
流程引擎属性配置表。

| 字段名称 | 字段类型     | 可否为空 | 描述   |
|----------|--------------|----------|--------|
| NAME_    | varchar(64)  | 否       | 名称   |
| VALUE_   | varchar(300) | 是       | 值     |
| REV_     | int(11)      | 是       | 版本   |



3.	act_ge_schema_log（数据库脚本执行日志表）
流程引擎属性配置表。

| 字段名称   | 字段类型         | 可否为空 | 描述     |
|------------|------------------|----------|----------|
| ID_        | varchar(64)      | 否       | 主键     |
| TIMESTAMP_ | datetime         | 是       | 时间戳   |
| VERSION_   | varchar(255)     | 是       | 版本     |



4.	act_hi_actinst（历史的活动实例表）
历史的活动实例表，记录流程流转过的所有节点。

| 字段名称                | 字段类型         | 可否为空   | 描述                           |
|-------------------------|------------------|------------|--------------------------------|
| ID_                     | varchar(64)      | 否         | 主键                           |
| PARENT_ACT_INST_ID_     | varchar(64)      | 是         | 父节点实例ID                   |
| PROC_DEF_KEY_           | varchar(255)     | 是         | 流程定义KEY                    |
| PROC_DEF_ID_            | varchar(64)      | 否         | 流程定义ID                     |
| ROOT_PROC_INST_ID_      | varchar(64)      | 是         | 流程实例根ID                   |
| PROC_INST_ID_           | varchar(64)      | 否         | 流程实例ID                     |
| EXECUTION_ID_           | varchar(64)      | 否         | 执行实例ID                     |
| ACT_ID_                 | varchar(255)     | 否         | 节点ID                         |
| TASK_ID_                | varchar(64)      | 是         | 任务ID                         |
| CALL_PROC_INST_ID_      | varchar(64)      | 是         | 调用外部的流程实例ID           |
| CALL_CASE_INST_ID_      | varchar(64)      | 是         | 调用外部的案例实例ID           |
| ACT_NAME_               | varchar(255)     | 是         | 节点名称                       |
| ACT_TYPE_               | varchar(255)     | 否         | 节点类型                       |
| ASSIGNEE_               | varchar(64)      | 是         | 办理人                         |
| START_TIME_             | datetime         | 否         | 开始时间                       |
| END_TIME_               | datetime         | 是         | 结束时间                       |
| DURATION_               | bigint(20)       | 是         | 耗时                           |
| ACT_INST_STATE_         | int(11)          | 是         | 活动实例状态                   |
| SEQUENCE_COUNTER_       | bigint(20)       | 是         | 序列计数器                     |
| TENANT_ID_              | varchar(64)      | 是         | 租户ID                         |
| REMOVAL_TIME_           | datetime         | 是         | 删除时间                       |



5.	act_hi_comment（历史流程审批意见表）
历史流程审批意见表，存放历史流程的审批意见。

| 字段名称             | 字段类型          | 可否为空   | 描述                           |
|----------------------|-------------------|------------|--------------------------------|
| ID_                  | varchar(64)       | 否         | 主键                           |
| TYPE_                | varchar(255)      | 是         | 类型（event事件、comment意见） |
| TIME_                | datetime          | 否         | 时间                           |
| USER_ID_             | varchar(255)      | 是         | 处理人                         |
| TASK_ID_             | varchar(64)       | 是         | 任务ID                         |
| ROOT_PROC_INST_ID_   | varchar(64)       | 是         | 流程实例根ID                   |
| PROC_INST_ID_        | varchar(64)       | 是         | 流程实例ID                     |
| ACTION_              | varchar(255)      | 是         | 行为类型                       |
| MESSAGE_             | varchar(4000)     | 是         | 基本内容                       |
| FULL_MSG_            | longblob          | 是         | 全部内容                       |
| TENANT_ID_           | varchar(64)       | 是         | 租户ID                         |
| REMOVAL_TIME_        | datetime          | 是         | 移除时间                       |



6.	act_hi_detail（历史的流程运行详情表）
历史的流程运行变量详情记录表。流程中产生的变量详细，包括控制流程流转的变量，业务表单中填写的流程需要用到的变量等。

| 字段名称               | 字段类型          | 可否为空   | 描述                           |
|------------------------|-------------------|------------|--------------------------------|
| ID_                    | varchar(64)       | 否         | 主键                           |
| TYPE_                  | varchar(255)      | 否         | 类型                           |
| PROC_DEF_KEY_          | varchar(255)      | 是         | 流程定义KEY                    |
| PROC_DEF_ID_           | varchar(64)       | 是         | 流程定义ID                     |
| ROOT_PROC_INST_ID_     | varchar(64)       | 是         | 流程实例根ID                   |
| PROC_INST_ID_          | varchar(64)       | 是         | 流程实例ID                     |
| EXECUTION_ID_          | varchar(64)       | 是         | 流程执行ID                     |
| CASE_DEF_KEY_          | varchar(255)      | 是         | 案例定义KEY                    |
| CASE_DEF_ID_           | varchar(64)       | 是         | 案例定义ID                     |
| CASE_INST_ID_          | varchar(64)       | 是         | 案例实例ID                     |
| CASE_EXECUTION_ID_     | varchar(64)       | 是         | 案例执行ID                     |
| TASK_ID_               | varchar(64)       | 是         | 任务ID                         |
| ACT_INST_ID_           | varchar(64)       | 是         | 节点实例ID                     |
| VAR_INST_ID_           | varchar(64)       | 是         | 流程变量记录ID                 |
| NAME_                  | varchar(255)      | 否         | 名称                           |
| VAR_TYPE_              | varchar(255)      | 是         | 变量类型                       |
| REV_                   | int(11)           | 是         | 版本                           |
| TIME_                  | datetime          | 否         | 时间戳                         |
| BYTEARRAY_ID_          | varchar(64)       | 是         | 二进制数据对应ID               |
| DOUBLE_                | double            | 是         | double类型值                   |
| LONG_                  | bigint(20)        | 是         | long类型值                     |
| TEXT_                  | varchar(4000)     | 是         | 文本类型值                     |
| TEXT2_                 | varchar(4000)     | 是         | 文本类型值2                    |
| SEQUENCE_COUNTER_      | bigint(20)        | 是         | 序列计数器                     |
| TENANT_ID_             | varchar(64)       | 是         | 租户ID                         |
| OPERATION_ID_          | varchar(64)       | 是         |                                |
| REMOVAL_TIME_          | datetime          | 是         | 移除时间                       |



7.	act_hi_identitylink（历史的流程运行过程中用户表）
历史的流程运行过程中用户表，主要存储历史节点参与者的信息。

| 字段名称             | 字段类型          | 可否为空   | 描述                       |
|----------------------|-------------------|------------|----------------------------|
| ID_                  | varchar(64)       | 否         | 主键                       |
| TIMESTAMP_           | timestamp         | 否         | 时间戳                     |
| TYPE_                | varchar(255)      | 是         | 类型                       |
| USER_ID_             | varchar(255)      | 是         | 用户ID                     |
| GROUP_ID_            | varchar(255)      | 是         | 用户组ID                   |
| TASK_ID_             | varchar(64)       | 是         | 任务ID                     |
| ROOT_PROC_INST_ID_   | varchar(64)       | 是         | 流程实例根ID               |
| PROC_DEF_ID_         | varchar(64)       | 是         | 流程定义ID                 |
| OPERATION_TYPE_      | varchar(64)       | 是         | 操作类型                   |
| ASSIGNER_ID_         | varchar(64)       | 是         | 分配者ID                   |
| PROC_DEF_KEY_        | varchar(255)      | 是         | 流程定义KEY                |
| TENANT_ID_           | varchar(64)       | 是         | 租户ID                     |
| REMOVAL_TIME_        | datetime          | 是         | 移除时间                   |



8.	act_hi_procinst（历史的流程实例表）
历史的流程实例表。

| 字段名称                  | 字段类型          | 可否为空   | 描述                         |
|---------------------------|-------------------|------------|------------------------------|
| ID_                       | varchar(64)       | 否         | 主键                         |
| PROC_INST_ID_             | varchar(64)       | 否         | 流程实例ID                   |
| BUSINESS_KEY_             | varchar(255)      | 是         | 业务KEY                      |
| PROC_DEF_KEY_             | varchar(255)      | 是         | 流程定义KEY                  |
| PROC_DEF_ID_              | varchar(64)       | 否         | 流程定义ID                   |
| START_TIME_               | datetime          | 否         | 开始时间                     |
| END_TIME_                 | datetime          | 是         | 结束时间                     |
| REMOVAL_TIME_             | datetime          | 是         | 移除时间                     |
| DURATION_                 | bigint(20)        | 是         | 耗时                         |
| START_USER_ID_            | varchar(255)      | 是         | 启动人ID                     |
| START_ACT_ID_             | varchar(255)      | 是         | 启动节点ID                   |
| END_ACT_ID_               | varchar(255)      | 是         | 结束节点ID                   |
| SUPER_PROCESS_INSTANCE_ID_| varchar(64)       | 是         | 父流程实例ID                 |
| ROOT_PROC_INST_ID_        | varchar(64)       | 是         | 流程实例根ID                 |
| SUPER_CASE_INSTANCE_ID_   | varchar(64)       | 是         | 父案例实例ID                 |
| CASE_INST_ID_             | varchar(64)       | 是         | 案例实例ID                   |
| DELETE_REASON_            | varchar(4000)     | 是         | 删除原因                     |
| TENANT_ID_                | varchar(64)       | 是         | 租户ID                       |
| STATE_                    | varchar(255)      | 是         | 状态                         |



9.	act_hi_taskinst（历史的任务实例表）
历史的任务实例表， 存放已经办理的任务。

| 字段名称               | 字段类型          | 可否为空   | 描述                           |
|------------------------|-------------------|------------|--------------------------------|
| ID_                    | varchar(64)       | 否         | 主键                           |
| TASK_DEF_KEY_          | varchar(255)      | 是         | 任务定义KEY                    |
| PROC_DEF_KEY_          | varchar(255)      | 是         | 流程定义KEY                    |
| PROC_DEF_ID_           | varchar(64)       | 是         | 流程定义ID                     |
| ROOT_PROC_INST_ID_     | varchar(64)       | 是         | 流程实例根ID                   |
| PROC_INST_ID_          | varchar(64)       | 是         | 流程实例ID                     |
| EXECUTION_ID_          | varchar(64)       | 是         | 流程执行ID                     |
| CASE_DEF_KEY_          | varchar(255)      | 是         | 案例定义KEY                    |
| CASE_DEF_ID_           | varchar(64)       | 是         | 案例定义ID                     |
| CASE_INST_ID_          | varchar(64)       | 是         | 案例实例ID                     |
| CASE_EXECUTION_ID_     | varchar(64)       | 是         | 案例执行ID                     |
| ACT_INST_ID_           | varchar(64)       | 是         | 节点实例ID                     |
| NAME_                  | varchar(255)      | 是         | 名称                           |
| PARENT_TASK_ID_        | varchar(64)       | 是         | 父任务ID                       |
| DESCRIPTION_           | varchar(4000)     | 是         | 描述                           |
| OWNER_                 | varchar(255)      | 是         | 委托人ID                       |
| ASSIGNEE_              | varchar(255)      | 是         | 办理人ID                       |
| START_TIME_            | datetime          | 否         | 开始时间                       |
| END_TIME_              | datetime          | 是         | 结束时间                       |
| DURATION_              | bigint(20)        | 是         | 耗时                           |
| DELETE_REASON_         | varchar(4000)     | 是         | 删除原因                       |
| PRIORITY_              | int(11)           | 是         | 优先级                         |
| DUE_DATE_              | datetime          | 是         | 超时时间                       |
| `FOLLOW_UP DATE`       | datetime          | 是         | 跟踪时间（注意字段名中的空格） |
| TENANT_ID_             | varchar(64)       | 是         | 租户ID                         |
| REMOVAL_TIME_          | datetime          | 是         | 移除时间                       |



10.	act_hi_varinst（历史的流程变量表）
历史的流程变量表。

| 字段名称               | 字段类型          | 可否为空   | 描述                           |
|------------------------|-------------------|------------|--------------------------------|
| ID_                    | varchar(64)       | 否         | 主键                           |
| PROC_DEF_KEY_          | varchar(255)      | 是         | 流程定义KEY                    |
| PROC_DEF_ID_           | varchar(64)       | 是         | 流程定义ID                     |
| ROOT_PROC_INST_ID_     | varchar(64)       | 是         | 流程实例根ID                   |
| PROC_INST_ID_          | varchar(64)       | 是         | 流程实例ID                     |
| EXECUTION_ID_          | varchar(64)       | 是         | 流程执行ID                     |
| ACT_INST_ID_           | varchar(64)       | 是         | 节点实例ID                     |
| CASE_DEF_KEY_          | varchar(255)      | 是         | 案例定义KEY                    |
| CASE_DEF_ID_           | varchar(64)       | 是         | 案例定义ID                     |
| CASE_INST_ID_          | varchar(64)       | 是         | 案例实例ID                     |
| CASE_EXECUTION_ID_     | varchar(64)       | 是         | 案例执行ID                     |
| TASK_ID_               | varchar(64)       | 是         | 任务ID                         |
| NAME_                  | varchar(255)      | 否         | 名称                           |
| VAR_TYPE_              | varchar(100)      | 是         | 变量类型                       |
| CREATE_TIME_           | datetime          | 是         | 创建时间                       |
| REV_                   | int(11)           | 是         | 版本                           |
| BYTEARRAY_ID_          | varchar(64)       | 是         | 二进制数据ID                   |
| DOUBLE_                | double            | 是         | double类型值                   |
| LONG_                  | bigint(20)        | 是         | long类型值                     |
| TEXT_                  | varchar(4000)     | 是         | 文本类型值                     |
| TEXT2_                 | varchar(4000)     | 是         | 文本类型值2                    |
| TENANT_ID_             | varchar(64)       | 是         | 租户ID                         |
| STATE_                 | varchar(20)       | 是         | 状态                           |
| REMOVAL_TIME_          | datetime          | 是         | 移除时间                       |



11.	act_id_user（用户表）

| 字段名称         | 字段类型        | 可否为空   | 描述             |
|------------------|-----------------|------------|------------------|
| ID_              | varchar(64)     | 否         | 主键             |
| REV_             | int(11)         | 是         | 版本             |
| FIRST_           | varchar(255)    | 是         | 姓               |
| LAST_            | varchar(255)    | 是         | 名               |
| EMAIL_           | varchar(255)    | 是         | 邮件             |
| PWD_             | varchar(255)    | 是         | 密码             |
| SALT_            | varchar(255)    | 是         | 盐值             |
| LOCK_EXP_TIME_   | datetime        | 是         | 锁定过期时间     |
| ATTEMPTS_        | int(11)         | 是         | 尝试次数         |
| PICTURE_ID_      | varchar(64)     | 是         | 图片ID           |



12.	act_id_group（群组表）

| 字段名称   | 字段类型        | 可否为空   | 描述                             |
|------------|-----------------|------------|----------------------------------|
| ID_        | varchar(64)     | 否         | 主键                             |
| REV_       | int(11)         | 是         | 版本                             |
| NAME_      | varchar(255)    | 是         | 组名称                           |
| TYPE_      | varchar(255)    | 是         | 组类型（SYSTEM系统、WORKFLOW业务）|



13.	act_id_membership（用户与群组关系表）

| 字段名称   | 字段类型      | 可否为空   | 描述     |
|------------|---------------|------------|----------|
| USER_ID_   | varchar(64)   | 否         | 用户ID   |
| GROUP_ID_  | varchar(64)   | 否         | 组ID     |



14.	act_re_deployment（流程部署表）

| 字段名称       | 字段类型        | 可否为空   | 描述         |
|----------------|-----------------|------------|--------------|
| ID_            | varchar(64)     | 否         | 主键         |
| NAME_          | varchar(255)    | 是         | 流程名称     |
| DEPLOY_TIME_   | datetime        | 是         | 部署时间     |
| SOURCE_        | varchar(255)    | 是         | 来源         |
| TENANT_ID_     | varchar(64)     | 是         | 租户ID       |



15.	act_re_procdef（流程定义表）
流程定义表，包含所有已部署的流程定义，诸如版本详细信息、资源名称或挂起状态等信息。

| 字段名称               | 字段类型           | 可否为空   | 描述                                 |
|------------------------|--------------------|------------|--------------------------------------|
| ID_                    | varchar(64)        | 否         | 主键                                 |
| REV_                   | int(11)            | 是         | 版本                                 |
| CATEGORY_              | varchar(255)       | 是         | 流程定义的Namespace分类             |
| NAME_                  | varchar(255)       | 是         | 流程定义名称                         |
| KEY_                   | varchar(255)       | 否         | 流程定义KEY                          |
| VERSION_               | int(11)            | 否         | 流程定义版本号                       |
| DEPLOYMENT_ID_         | varchar(64)        | 是         | 部署ID                               |
| RESOURCE_NAME_         | varchar(4000)      | 是         | 资源名称                             |
| DGRM_RESOURCE_NAME_    | varchar(4000)      | 是         | DGRM资源名称（流程图文件名等）       |
| HAS_START_FORM_KEY_    | tinyint(4)         | 是         | 是否有启动表单                       |
| SUSPENSION_STATE_      | int(11)            | 是         | 流程挂起状态                         |
| TENANT_ID_             | varchar(64)        | 是         | 租户ID                               |
| VERSION_TAG_           | varchar(64)        | 是         | 版本标签                             |
| HISTORY_TTL_           | int(11)            | 是         | 历史数据生存时间（TTL）              |
| STARTABLE_             | tinyint(1)         | 否         | 是否是可启动流程                     |



16.	act_ru_event_subscr（流程事件订阅表）
流程事件订阅表，包含所有当前存在的事件订阅，包括预期事件的类型、名称和配置，以及有关相应流程实例和执行的信息。

| 字段名称         | 字段类型          | 可否为空   | 描述               |
|------------------|-------------------|------------|--------------------|
| ID_              | varchar(64)       | 否         | 主键               |
| REV_             | int(11)           | 是         | 版本               |
| EVENT_TYPE_      | varchar(255)      | 否         | 事件类型           |
| EVENT_NAME_      | varchar(255)      | 是         | 事件名称           |
| EXECUTION_ID_    | varchar(64)       | 是         | 执行ID             |
| PROC_INST_ID_    | varchar(64)       | 是         | 流程实例ID         |
| ACTIVITY_ID_     | varchar(255)      | 是         | 节点ID             |
| CONFIGURATION_   | varchar(255)      | 是         | 配置信息           |
| CREATED_         | datetime          | 否         | 创建时间           |
| TENANT_ID_       | varchar(64)       | 是         | 租户ID             |



17.	act_ru_execution（流程运行时表）
BPMN流程运行时记录表。该表时整个流程引擎的核心表，它包括流程定义、父级执行、当前活动和有关执行状态的不同元数据等信息。

| 字段名称              | 字段类型           | 可否为空   | 描述                                   |
|-----------------------|--------------------|------------|----------------------------------------|
| ID_                   | varchar(64)        | 否         | 主键                                   |
| REV_                  | int(11)            | 是         | 版本                                   |
| ROOT_PROC_INST_ID_    | varchar(64)        | 是         | 流程实例根ID                           |
| PROC_INST_ID_         | varchar(64)        | 是         | 流程实例ID                             |
| BUSINESS_KEY_         | varchar(255)       | 是         | 业务KEY                                |
| PARENT_ID_            | varchar(64)        | 是         | 流程父实例ID                           |
| PROC_DEF_ID_          | varchar(64)        | 是         | 流程定义ID                             |
| SUPER_EXEC_           | varchar(64)        | 是         | 父流程实例对应的执行                   |
| SUPER_CASE_EXEC_      | varchar(64)        | 是         | 父案例实例对应的执行                   |
| CASE_INST_ID_         | varchar(64)        | 是         | 案例实例ID                             |
| ACT_ID_               | varchar(255)       | 是         | 节点ID                                 |
| ACT_INST_ID_          | varchar(64)        | 是         | 节点实例ID                             |
| IS_ACTIVE_            | tinyint(4)         | 是         | 是否激活                               |
| IS_CONCURRENT_        | tinyint(4)         | 是         | 是否并行                               |
| IS_SCOPE_             | tinyint(4)         | 是         | 是否多实例范围                         |
| IS_EVENT_SCOPE_       | tinyint(4)         | 是         | 是否事件多实例范围                     |
| SUSPENSION_STATE_     | int(11)            | 是         | 挂起状态                               |
| CACHED_ENT_STATE_     | int(11)            | 是         | 缓存状态                               |
| SEQUENCE_COUNTER_     | bigint(20)         | 是         | 序列计数器                             |
| TENANT_ID_            | varchar(64)        | 是         | 租户ID                                 |



18.	act_ru_identitylink（流程运行时表）
运行时流程人员表，主要存储当前节点参与者的信息.

| 字段名称       | 字段类型          | 可否为空   | 描述               |
|----------------|-------------------|------------|--------------------|
| ID_            | varchar(64)       | 否         | 主键               |
| REV_           | int(11)           | 是         | 版本               |
| GROUP_ID_      | varchar(255)      | 是         | 用户组ID           |
| TYPE_          | varchar(255)      | 是         | 类型               |
| USER_ID_       | varchar(255)      | 是         | 用户ID             |
| TASK_ID_       | varchar(64)       | 是         | 任务ID             |
| PROC_DEF_ID_   | varchar(64)       | 是         | 流程定义ID         |
| TENANT_ID_     | varchar(64)       | 是         | 租户ID             |



19. act_ru_incident（ 运行时异常记录表）
运行时异常记录表
| 字段名称                  | 字段类型           | 可否为空   | 描述                                   |
|---------------------------|--------------------|------------|----------------------------------------|
| ID_                       | varchar(64)        | 否         | 主键，唯一标识每条事件记录             |
| REV_                      | int(11)            | 否         | 版本号，用于乐观锁控制                 |
| INCIDENT_TIMESTAMP_       | datetime           | 否         | 事件发生的时间戳                        |
| INCIDENT_MSG_             | varchar(4000)      | 是         | 事件描述或错误信息                      |
| INCIDENT_TYPE_            | varchar(255)       | 否         | 事件类型，如 `failedJob`, `execution` 等 |
| EXECUTION_ID_             | varchar(64)        | 是         | 关联的流程执行ID                        |
| ACTIVITY_ID_              | varchar(255)       | 是         | 当前事件发生的节点ID                    |
| PROC_INST_ID_             | varchar(64)        | 是         | 所属流程实例ID                          |
| PROC_DEF_ID_              | varchar(64)        | 是         | 流程定义ID                              |
| CAUSE_INCIDENT_ID_        | varchar(64)        | 是         | 引发此事件的上级事件ID（因果链）        |
| ROOT_CAUSE_INCIDENT_ID_   | varchar(64)        | 是         | 事件的根本原因ID                         |
| CONFIGURATION_            | varchar(255)       | 是         | 事件相关配置信息，如任务、作业参数等     |
| TENANT_ID_                | varchar(64)        | 是         | 租户ID，用于多租户环境下的数据隔离      |
| JOB_DEF_ID_               | varchar(64)        | 是         | 关联的JOB定义ID                         |



20. act_ru_job（ 流程运行时作业表）
流程运行时作业表
| 字段名称               | 字段类型          | 可否为空   | 描述                                       |
|------------------------|-------------------|------------|--------------------------------------------|
| ID_                    | varchar(64)       | 否         | 主键，唯一标识每条记录                     |
| REV_                   | int(11)           | 是         | 版本号，用于乐观锁控制                     |
| TYPE_                  | varchar(255)      | 否         | 作业类型（如 timer、message 等）            |
| LOCK_EXP_TIME_         | datetime          | 是         | 锁定过期时间，防止其他节点重复执行         |
| LOCK_OWNER_            | varchar(255)      | 是         | 当前锁定该作业的节点或用户                 |
| EXCLUSIVE_             | tinyint(1)        | 是         | 是否为独占作业（exclusive）                |
| EXECUTION_ID_          | varchar(64)       | 是         | 关联的流程执行ID                           |
| PROCESS_INSTANCE_ID_   | varchar(64)       | 是         | 流程实例ID                                 |
| PROCESS_DEF_ID_        | varchar(64)       | 是         | 流程定义ID                                 |
| PROCESS_DEF_KEY_       | varchar(255)      | 是         | 流程定义KEY                                |
| RETRIES_               | int(11)           | 是         | 剩余重试次数                               |
| EXCEPTION_STACK_ID_    | varchar(64)       | 是         | 异常堆栈ID，指向异常日志或堆栈信息         |
| EXCEPTION_MSG_         | varchar(4000)     | 是         | 异常信息，描述失败原因                     |
| DUEDATE_               | datetime          | 是         | 下一次执行时间                             |
| REPEAT_                | varchar(255)      | 是         | 重复表达式（如 cron 表达式或间隔）         |
| REPEAT_OFFSET_         | bigint(20)        | 是         | 重复偏移量（单位：毫秒）                   |
| HANDLER_TYPE_          | varchar(255)      | 是         | 处理器类型，决定如何处理该作业             |
| HANDLER_CFG_           | varchar(4000)     | 是         | 处理器配置信息（如消息名、外部任务ID等）   |
| DEPLOYMENT_ID_         | varchar(64)       | 是         | 部署ID，关联部署记录                       |
| SUSPENSION_STATE_      | int(11)           | 否         | 挂起状态（是否被暂停）                     |
| JOB_DEF_ID_            | varchar(64)       | 是         | 对应的作业定义ID                           |
| PRIORITY_              | bigint(20)        | 否         | 作业优先级，数字越大优先级越高             |
| SEQUENCE_COUNTER_      | bigint(20)        | 是         | 序列计数器，用于排序和并发控制             |
| TENANT_ID_             | varchar(64)       | 是         | 租户ID，用于多租户环境下的数据隔离         |
| CREATE_TIME_           | datetime          | 是         | 创建时间                                   |



21. act_ru_jobdef（ 流程作业定义表）
流程作业定义表
| 字段名称            | 字段类型         | 可否为空   | 描述             |
|---------------------|------------------|------------|------------------|
| ID_                 | varchar(64)      | 否         | 主键             |
| REV_                | int(11)          | 是         | 版本             |
| PROC_DEF_ID_        | varchar(64)      | 是         | 流程定义ID       |
| PROC_DEF_KEY_       | varchar(255)     | 是         | 流程定义KEY      |
| ACT_ID_             | varchar(255)     | 是         | 节点ID           |
| JOB_TYPE_           | varchar(255)     | 否         | JOB类型          |
| JOB_CONFIGURATION_  | varchar(255)     | 是         | JOB配置          |
| SUSPENSION_STATE_   | int(11)          | 是         | 挂起状态         |
| JOB_PRIORITY_       | bigint(20)       | 是         | 优先级           |
| TENANT_ID_          | varchar(64)      | 是         | 租户ID           |



22. act_ru_task（ 流程运行时任务表）
流程运行时任务表，包含所有正在运行的流程实例的所有打开的任务，包括诸如相应的流程实例、执行以及元数据（如创建时间、办理人或到期时间）等信息。
| 字段名称             | 字段类型          | 可否为空   | 描述               |
|----------------------|-------------------|------------|--------------------|
| ID_                  | varchar(64)       | 否         | 主键               |
| REV_                 | int(11)           | 是         | 版本               |
| EXECUTION_ID_        | varchar(64)       | 是         | 流程执行ID         |
| PROC_INST_ID_        | varchar(64)       | 是         | 流程实例ID         |
| PROC_DEF_ID_         | varchar(64)       | 是         | 流程定义ID         |
| CASE_EXECUTION_ID_   | varchar(64)       | 是         | 案例执行ID         |
| CASE_INST_ID_        | varchar(64)       | 是         | 案例实例ID         |
| CASE_DEF_ID_         | varchar(64)       | 是         | 案例定义ID         |
| NAME_                | varchar(255)      | 是         | 名称               |
| PARENT_TASK_ID_      | varchar(64)       | 是         | 父任务ID           |
| DESCRIPTION_         | varchar(4000)     | 是         | 描述               |
| TASK_DEF_KEY_        | varchar(255)      | 是         | 任务定义KEY        |
| OWNER_               | varchar(255)      | 是         | 委托人             |
| ASSIGNEE_            | varchar(255)      | 是         | 办理人             |
| DELEGATION_          | varchar(64)       | 是         | 委托状态           |
| PRIORITY_            | int(11)           | 是         | 优先级             |
| CREATE_TIME_         | datetime          | 是         | 创建时间           |
| DUE_DATE_            | datetime          | 是         | 截止时间           |
| FOLLOW_UP_DATE_      | datetime          | 是         | 跟踪时间           |
| SUSPENSION_STATE_    | int(11)           | 是         | 挂起状态           |
| TENANT_ID_           | varchar(64)       | 是         | 租户ID             |



23.act_ru_variable（ 流程运行时变量表）
流程运行时变量表，包含当前运行中所有流程或任务变量，包括变量的名称、类型和值以及有关相应流程实例或任务的信息。
| 字段名称                | 字段类型          | 可否为空   | 描述                   |
|-------------------------|-------------------|------------|------------------------|
| ID_                     | varchar(64)       | 否         | 主键                   |
| REV_                    | int(11)           | 是         | 版本                   |
| TYPE_                   | varchar(255)      | 否         | 变量类型               |
| NAME_                   | varchar(255)      | 否         | 变量名称               |
| EXECUTION_ID_           | varchar(64)       | 是         | 流程执行ID             |
| PROC_INST_ID_           | varchar(64)       | 是         | 流程实例ID             |
| CASE_EXECUTION_ID_      | varchar(64)       | 是         | 案例执行ID             |
| CASE_INST_ID_           | varchar(64)       | 是         | 案例实例ID             |
| TASK_ID_                | varchar(64)       | 是         | 任务ID                 |
| BYTEARRAY_ID_           | varchar(64)       | 是         | 二进制内容ID           |
| DOUBLE_                 | double            | 是         | DOUBLE类型值           |
| LONG_                   | bigint(20)        | 是         | LONG类型值             |
| TEXT_                   | varchar(4000)     | 是         | 文本值                 |
| TEXT2_                  | varchar(4000)     | 是         | 文本值2                |
| VAR_SCOPE_              | varchar(64)       | 否         | 变量范围               |
| SEQUENCE_COUNTER_       | bigint(20)        | 是         | 序列计数器             |
| IS_CONCURRENT_LOCAL_    | tinyint(4)        | 是         | 是否并发               |
| TENANT_ID_              | varchar(64)       | 是         | 租户ID                 |

