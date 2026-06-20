#### 1. 更新报错

```shell
root@02d11732ea88:/# apt-get update
Get:1 http://security.ubuntu.com/ubuntu focal-security InRelease [128 kB]
Hit:2 http://archive.ubuntu.com/ubuntu focal InRelease   
Err:2 http://archive.ubuntu.com/ubuntu focal InRelease   
  Couldn't create temporary file /tmp/apt.conf.fUUP0f for passing config to apt-key
Get:3 http://archive.ubuntu.com/ubuntu focal-updates InRelease [128 kB]
Err:1 http://security.ubuntu.com/ubuntu focal-security InRelease    
  Couldn't create temporary file /tmp/apt.conf.mSDZgl for passing config to apt-key
Err:3 http://archive.ubuntu.com/ubuntu focal-updates InRelease
  Couldn't create temporary file /tmp/apt.conf.oUnM3s for passing config to apt-key
Get:4 http://archive.ubuntu.com/ubuntu focal-backports InRelease [128 kB]
Err:4 http://archive.ubuntu.com/ubuntu focal-backports InRelease
  Couldn't create temporary file /tmp/apt.conf.nHEuNv for passing config to apt-key
Fetched 383 kB in 3s (142 kB/s)
Reading package lists... Done
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://archive.ubuntu.com/ubuntu focal InRelease: Couldn't create temporary file /tmp/apt.conf.fUUP0f for passing config to apt-key
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://security.ubuntu.com/ubuntu focal-security InRelease: Couldn't create temporary file /tmp/apt.conf.mSDZgl for passing config to apt-key
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://archive.ubuntu.com/ubuntu focal-updates InRelease: Couldn't create temporary file /tmp/apt.conf.oUnM3s for passing config to apt-key
W: An error occurred during the signature verification. The repository is not updated and the previous index files will be used. GPG error: http://archive.ubuntu.com/ubuntu focal-backports InRelease: Couldn't create temporary file /tmp/apt.conf.nHEuNv for passing config to apt-key
W: Failed to fetch http://archive.ubuntu.com/ubuntu/dists/focal/InRelease  Couldn't create temporary file /tmp/apt.conf.fUUP0f for passing config to apt-key
W: Failed to fetch http://archive.ubuntu.com/ubuntu/dists/focal-updates/InRelease  Couldn't create temporary file /tmp/apt.conf.oUnM3s for passing config to apt-key
W: Failed to fetch http://archive.ubuntu.com/ubuntu/dists/focal-backports/InRelease  Couldn't create temporary file /tmp/apt.conf.nHEuNv for passing config to apt-key
W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/focal-security/InRelease  Couldn't create temporary file /tmp/apt.conf.mSDZgl for passing config to apt-key
W: Some index files failed to download. They have been ignored, or old ones used instead.


可能是权限问题：Err:1 http://archive.ubuntu.com/ubuntu focal InRelease
  Couldn't create temporary file /tmp/apt.conf.VSUogA for passing config to apt-key
```



#### 2. 查看网络是否正常

```shell
[root@cd91 ~]# ping security.ubuntu.com
PING security.ubuntu.com (185.125.190.83) 56(84) bytes of data.
64 bytes from ubuntu-mirror-3.ps5.canonical.com (185.125.190.83): icmp_seq=1 ttl=52 time=372 ms
64 bytes from ubuntu-mirror-3.ps5.canonical.com (185.125.190.83): icmp_seq=2 ttl=52 time=422 ms
64 bytes from ubuntu-mirror-3.ps5.canonical.com (185.125.190.83): icmp_seq=3 ttl=52 time=411 ms
64 bytes from ubuntu-mirror-3.ps5.canonical.com (185.125.190.83): icmp_seq=4 ttl=52 time=268 ms
^C
--- security.ubuntu.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3424ms
rtt min/avg/max/mdev = 268.494/368.668/422.251/60.756 ms
```



#### 3. 网络正常情况下，应该是权限问题

```shell
root@02d11732ea88:/# chmod 1777 /tmp      修改权限，将 /tmp 目录设置为所有用户都可以读取、写入和执行，但只能删除自己创建的文件
```



#### 4. 再次执行更新，成功

```shell
root@02d11732ea88:/# apt-get update
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [128 kB]    
Get:3 http://security.ubuntu.com/ubuntu focal-security InRelease [128 kB]
Get:4 http://archive.ubuntu.com/ubuntu focal-backports InRelease [128 kB]
Get:5 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [1257 kB]
Get:6 http://archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [4073 kB]
Get:7 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [30.9 kB]
Get:8 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [3921 kB]
Get:9 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [3931 kB]                                                                                                                                           
Get:10 http://archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [1544 kB]                                                                                                                                        
Get:11 http://archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [33.5 kB]                                                                                                                                      
Get:12 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [4396 kB]                                                                                                                                            
Get:13 http://archive.ubuntu.com/ubuntu focal-backports/universe amd64 Packages [28.6 kB]                                                                                                                                      
Get:14 http://archive.ubuntu.com/ubuntu focal-backports/main amd64 Packages [55.2 kB]                                                                                                                                          
Fetched 19.7 MB in 12s (1606 kB/s)                                                                                                                                                                                             
Reading package lists... Done
```

