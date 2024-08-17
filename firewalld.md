### `firewalld` 是一个动态防火墙管理工具，它支持网络和端口转发、接口和区域绑定、以及富规则。

#### 基本操作

- **启动、停止和检查状态**：

  ```shell
  sudo systemctl start firewalld
  sudo systemctl stop firewalld
  sudo systemctl status firewalld
  ```

- **永久性启用/禁用服务**：

  ```shell
  sudo firewall-cmd --permanent --add-service=http
  sudo firewall-cmd --permanent --remove-service=http
  ```

- **临时性启用/禁用服务**：

  ```shell
  sudo firewall-cmd --add-service=http
  sudo firewall-cmd --remove-service=http
  ```

- **查看所有活动规则**：

  ```
  sudo firewall-cmd --list-all
  ```

- **添加/删除端口**：

  ```shell
  sudo firewall-cmd --permanent --add-port=80/tcp
  sudo firewall-cmd --permanent --remove-port=80/tcp
  ```

- **重载配置**：

  ```shell
  sudo firewall-cmd --reloads
  ```

- **查看所有已知区域**：

  ```shell
  sudo firewall-cmd --get-zones
  
  block：此区域是最严格的，所有传入的连接都被拒绝，并且不会回应任何请求。
  dmz：这是专为放置在非军事区（DMZ）内的服务器设计的，允许某些服务（如 HTTP 和 SSH）通过。
  docker：此区域为 Docker 容器提供了一个隔离环境，通常包含了一些基本的服务和端口。
  drop：类似于 block 区域，但不发送任何回应给发起请求的一方。
  external：此区域用于面向公众的接口，只允许特定的服务，如 SSH 和 HTTP。
  home：用于家庭网络，允许更多的服务和连接。
  internal：用于内部网络，允许更多的服务和连接。
  public：用于公共网络环境，允许最少的服务，如 SSH 和 HTTP。
  trusted：这是一个非常宽松的区域，通常用于受信任的网络环境，允许所有传入的连接。
  ```

- **更改接口所属的区域**：

  ```shell
  sudo firewall-cmd --zone=public --change-interface=enp0s3
  ```

- **查看区域信息**：

  ```shell
  sudo firewall-cmd --info-zone=public
  ```

- **查看所有规则**：

  ```shell
  sudo firewall-cmd --list-all-zones
  ```

