# 最小化修复脚本
echo "=== 开始修复docker_gwbridge MTU ==="

# 1. 修改配置
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "iptables": true
}
EOF

# 2. 重启Docker（只重建docker_gwbridge）
sudo systemctl stop docker
sudo ip link delete docker_gwbridge 2>/dev/null
sudo systemctl start docker

# 3. 等待重建
sleep 20

# 4. 验证
echo "修复后docker_gwbridge MTU:"
ip link show docker_gwbridge | grep -o 'mtu [0-9]*'

echo "=== 性能测试 ==="
docker exec -it nacos sh -c "
curl -s -o /dev/null -w '第一次请求: %{time_total}s\n' \
http://platform-center-1:8102/actuator/health
"