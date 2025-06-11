```shell
[root@manager /]# sudo fdisk /dev/vdb
欢迎使用 fdisk (util-linux 2.23.2)。

更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。

Device does not contain a recognized partition table
使用磁盘标识符 0x471ac8f1 创建新的 DOS 磁盘标签。

WARNING: The size of this disk is 2.2 TB (2199023255552 bytes).
DOS partition table format can not be used on drives for volumes
larger than (2199023255040 bytes) for 512-byte sectors. Use parted(1) and GUID 
partition table format (GPT).


命令(输入 m 获取帮助)：
##由于 /dev/vdb 的大小超过了 2TB，传统的 DOS 分区表（MBR）无法支持这么大的磁盘。在这种情况下，建议使用 parted 工具并采用 GPT（GUID Partition Table）格式来分区和管理这块磁盘。



#打开终端并以超级用户身份运行以下命令来启动 parted 并指定目标磁盘 /dev/vdb
[root@manager /]# sudo parted /dev/vdb
GNU Parted 3.1
使用 /dev/vdb
Welcome to GNU Parted! Type 'help' to view a list of commands.


#创建 GPT 分区表
(parted)  mklabel gpt 


#输入 print 命令查看当前磁盘的状态，确保 GPT 分区表已成功创建
(parted) print                                                            
Model: Virtio Block Device (virtblk)
Disk /dev/vdb: 2199GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start  End  Size  File system  Name  标志


#输入 mkpart 来开始创建一个新的分区
(parted) mkpart                                                           
分区名称？  []?                                                           
文件系统类型？  [ext2]? ext4
起始点？ 0%                                                               
结束点？ 100% 


#创建分区后，可以通过 print 命令查看分区表，确保分区已正确创建
(parted) print                                                            
Model: Virtio Block Device (virtblk)
Disk /dev/vdb: 2199GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
Number  Start   End     Size    File system  Name  标志
 1      1049kB  2199GB  2199GB


#完成所有操作后，输入 quit 退出 parted
(parted) quit                                                             
信息: You may need to update /etc/fstab.


#使用 mkfs.ext4 命令将分区格式化为 ext4 文件系统
[root@manager /]# sudo mkfs.ext4 /dev/vdb1                                
mke2fs 1.42.9 (28-Dec-2013)
文件系统标签=
OS type: Linux
块大小=4096 (log=2)
分块大小=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
134217728 inodes, 536870400 blocks
26843520 blocks (5.00%) reserved for the super user
第一个数据块=0
Maximum filesystem blocks=2684354560
16384 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
        102400000, 214990848, 512000000

Allocating group tables: 完成                            
正在写入inode表: 完成                            
Creating journal (32768 blocks): 完成
Writing superblocks and filesystem accounting information: 完成


[root@manager /]# sudo mount /dev/vdb1 /yclSystemData

#挂载 /dev/vdb1 到 /yclSystemData 目录，lost+found 是在格式化文件系统时自动创建的目录，用于文件系统的恢复操作
[root@manager /]# ls /yclSystemData/
lost+found

#为了确保系统重启后自动挂载该分区，你需要编辑 /etc/fstab 文件，添加相应的条目
[root@manager /]# sudo blkid /dev/vdb1
/dev/vdb1: UUID="e3540c06-9237-4a4f-be00-25f40960aa78" TYPE="ext4" PARTUUID="f17a5444-813b-4f5f-bc62-3da5f9840236" 


#打开 /etc/fstab 文件进行编辑
sudo vi /etc/fstab

#添加新的挂载条目
#在 vi 中的操作步骤：

#按 i 进入插入模式。
#移动光标到文件末尾，并添加以下行：
UUID=e3540c06-9237-4a4f-be00-25f40960aa78 /yclSystemData ext4 defaults 0 0
#按 Esc 键 退出插入模式。
#输入 :wq 并按回车键 保存并退出。


[root@manager /]# df -h | grep /yclSystemData
/dev/vdb1                2.0T   81M  1.9T    1% /yclSystemData
#/dev/vdb1 已经成功挂载到 /yclSystemData，并且通过 df -h 命令可以看到挂载点的信息。这表明你的 /etc/fstab 配置已经生效，并且分区在系统启动时会自动挂载


#使用 mount 命令来检查 /yclSystemData 的挂载选项是否与 /etc/fstab 中定义的一致
[root@manager /]# mount | grep /yclSystemData
/dev/vdb1 on /yclSystemData type ext4 (rw,relatime,seclabel,data=ordered)


#为了确保新格式化的文件系统是健康的，可以运行 fsck 工具进行检查：
sudo fsck /dev/vdb1
#如果文件系统没有问题，你会看到类似以下的输出：
#/dev/vdb1: clean, 11/134217728 files, 20643/536870400 blocks

实际情况：
[root@manager /]# sudo fsck /dev/vdb1
fsck，来自 util-linux 2.23.2
e2fsck 1.42.9 (28-Dec-2013)
/dev/vdb1 is mounted.
e2fsck: 无法继续, 中止.
#由于 /dev/vdb1 已经挂载，fsck 工具无法直接对其进行检查和修复。这是因为对已挂载的文件系统进行 fsck 操作可能会导致数据损坏或其他问题。通常情况下，文件系统的健康检查应该在文件系统未挂载的状态下进行。


解决方案：
#卸载分区
[root@manager /]# sudo umount /yclSystemData
#运行 fsck 检查文件系统
[root@manager /]# sudo fsck /dev/vdb1
fsck，来自 util-linux 2.23.2
e2fsck 1.42.9 (28-Dec-2013)
/dev/vdb1: clean, 11/134217728 files, 8479770/536870400 blocks
#fsck 已经成功检查了 /dev/vdb1 文件系统，并且报告显示文件系统是干净的 (clean)。这意味着没有发现任何错误，文件系统处于良好状态。
#重新挂载分区
[root@manager /]# sudo mount /dev/vdb1 /yclSystemData
[root@manager /]# 

```

