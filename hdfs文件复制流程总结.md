拷贝hdfs文件流程

 

### 一.  拉取文件所在镜像

```shell
docker save -o 文件名 镜像名/id  #将镜像文件保存下来
```



### 二.  复制文件

使用docker inspect 容器名，查看挂载路径，如下：/mnt/docker192/hadoop2.7.7/home 就是资源所在相应宿主机的存储路径

```shell
 "Mounts": [
            {
                "Type": "bind",
                "Source": "/mnt/docker192/hadoop2.7.7/home",
                "Destination": "/home",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ]
```

如图，可将整个目录下载，但是可能会有些大，所以最好分多个下载（如果有虚拟机所在宿主机上有finalshell等远程连接工具，可直接将文件下载到宿主机，再上传到相应的新hdfs集群所在机器上）,文件分别放在如下目录：

```
/mnt/docker192/hadoop2/home     namenode
/mnt/docker192/hadoop2/home2	datanode
/mnt/docker192/hadoop2/home3	datanode
```

![image-20240613094258573](https://cdn.jsdelivr.net/gh/chenshuosheng/picture/hdfs/image-20240613094258573.png)



### 三.  使用拉去过来的镜像启动hadoop集群

1. ##### 导入3个镜像

   - ```
      docker load -i 文件名
      ```
   
      

2. ##### 如果原有相同的容器存在，需要停了，然后改名或删除

   - ```shell
     docker stop old_t1容器名			#停止容器
     docker rm old_t1容器名				#删除容器
     docker rename t1 old_t1			  #重命名			
     ```

3. ##### 启动hadoop集群

   - ```shell
     docker run -itd --name hadoop2(镜像名) --restart always -v /mnt/docker192/hadoop2/home2:/home --net servicenet hadoop2(容器名)
     
     docker run -itd --name hadoop1 --restart always -v /mnt/docker192/hadoop2/home:/home --net servicenet -p 50070:50070 -p 9088:8088 hadoop1.5             
     
     docker run -itd --name hadoop3 --restart always -v /mnt/docker192/hadoop2/home3:/home --net servicenet hadoop3
     ```

     

### 四.  查看文件复制是否成功

1. ##### 进入主节点

   - ```
     docker exec -it hadoop1 bash
     ```

2. ##### 查询文件

   - ```
     hdfs dfs -ls / 
     ```

3. ##### 可能会有以下两种情况：

   1. 报错：

      - ```shell
        [root@cd92 ~]# docker exec -it hadoop1 bash
        [root@bb445fed2408 /]# hdfs dfs -ls /
        ls: Call From bb445fed2408/172.16.0.4 to hadoop1:9000 failed on connection exception: java.net.ConnectException: Connection refused; For more details see:  http://wiki.apache.org/hadoop/ConnectionRefused
        ```

      - 报错了可以试试：

        - ```shell
          /usr/local/hadoop/sbin/stop-all.sh				#这一条可能不用执行，直接执行3
          /usr/local/hadoop/bin/hdfs namenode -format   	#这一条不用执行，除非没效果，这个会格式化数据
          /usr/local/hadoop/sbin/start-all.sh
          ```

   2. 正常：
   
      - ```shell
        [root@bb445fed2408 /]# hdfs dfs -ls /
        Found 3962 items
        -rw-r--r--   3 root supergroup   11050388 2024-06-06 09:00 /0000c55f-586f-475b-a40a-58230d479549.pdf
        -rw-r--r--   3 root supergroup     306415 2024-03-12 10:12 /00014a34-52f8-4020-87a9-884599e9a336.jpg
        -rw-r--r--   3 root supergroup       6156 2024-05-21 10:00 /000c1562-cac2-4d95-a242-f7915f5a0b79.json
        -rw-r--r--   3 root supergroup     239846 2024-03-12 06:47 /001dc281-dfc4-4792-acbe-bb21fd2eab6c.jpg
        -rw-r--r--   3 root supergroup    8817104 2024-03-21 08:57 /0040e77a-f0f3-47af-9498-75630cd2dd59.zip
        -rw-r--r--   3 root supergroup       6614 2024-03-07 07:41 /0040ec7a-1f6a-46bc-98b9-393af63431bd.xlsx
        ```
   
        
   
   3. ![image-20240613100305164](https://cdn.jsdelivr.net/gh/chenshuosheng/picture/hdfs/image-20240613100305164.png)
   
   

### **启动hadoop集群成功后需要重启使用了集群的服务**



启动容器

docker run -itd --name hadoop1 --restart always -v /mnt/docker192/hadoop2.7.7/home:/home --net servicenet -p 50070:50070 -p 9088:8088 hadoop1.5 

进入容器

docker exec -it hadoop1 bash

执行命令

/usr/local/hadoop/sbin/start-all.sh

