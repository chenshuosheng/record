```shell
# 使用 logrotate 对 nginx 进行日志分割
# 下面文件配置在：/etc/logrotate.d/nginx

# 配置针对 /usr/nginx/log/ 目录下的所有 .log 文件进行日志轮转
/usr/nginx/log/*.log {
    # 每天（daily）检查一次日志文件是否需要轮转
    daily

    # 如果日志文件不存在，忽略错误，不报错（不会中断 logrotate 的执行）
    missingok

    # 只有当日志文件大小达到 10MB 或以上时才进行轮转
    minsize 10M

    # 即使日志文件为空，也进行轮转（如果不加这个选项，则空文件不会被轮转）
    notifempty

    # 使用日期格式作为归档文件的后缀，例如：access.log-20250710
    dateext

    # 启用压缩，轮转后的日志文件将被压缩（如：.gz 格式）
    compress

    # 延迟压缩，即本次轮转不立即压缩上一次的日志，而是在下一次轮转时再压缩
    # 这样可以确保日志处理脚本（如 postrotate）操作的是未压缩的日志文件
    delaycompress

    # 轮转后创建新的空日志文件（保持原始权限和属主）
    create

    # 在每次完成日志轮转后执行的脚本
    postrotate
        # 重新打开 Nginx 的日志文件，以便写入新的日志文件（旧文件已被重命名）
        # 通过 docker exec 执行 nginx 的 -s reopen 命令
        docker exec -it nginx /usr/sbin/nginx -s reopen > /dev/null 2>/dev/null || true
    endscript

    # 表示多个日志使用同一个 postrotate 脚本时，只执行一次该脚本（而不是每个日志都执行一遍）
    sharedscripts

    # 设置归档日志的最大保留时间（90天），超过此时间的旧日志将被自动删除
    maxage 90
}


# 通过下面命令可确定容器内nginx的可执行文件所在位置
[root@gtw log]# docker exec -it nginx bash
root@c7718891693f:/# which nginx
/usr/sbin/nginx
root@c7718891693f:/#

# 宿主机上执行下列命令可手动触发Nginx日志文件重新打开
docker exec -it nginx /usr/local/nginx/sbin/nginx -s reopen

# 执行了强制日志轮转
logrotate -f /etc/logrotate.d/nginx

# 调试模式（dry run），不会真正执行任何日志轮转操作，只是模拟并输出 logrotate 会做什么
logrotate -d /etc/logrotate.d/nginx
```

