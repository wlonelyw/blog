---
title: ArchLinux 安装笔记
date: 12/07/2025
updated:
tags: Arch Linux
categories: ArchLinux
keywords: ArchLinux Linux
description: ArchLinux 安装笔记
top_img: cover.jpeg
comments:
cover: cover.jpeg
toc:
toc_number:
toc_style_simple:
copyright:
copyright_author:
copyright_author_href:
copyright_url:
copyright_info:
mathjax:
katex:
aplayer:
highlight_shrink:
aside:
swiper_index: 1
top_group_index: 1
background: "#fff"
---

# 介绍

使用 **ext4(GPT)** 和 **zram** **grub**(尝试 systemd-boot)

内容部分来自

[Archlinux Wiki](https://wiki.archlinux.org/title/Installation_guide)

[ArchLinux 简明指南](https://arch.icekylin.online/)


# 准备

## 下载验证ISO

### 验证签名

从 [checksums](https://archlinux.org/download/#checksums) 下载ISO PGP 签名到 ISO 目录

```bash
pacman-key -v archlinux- version -x86_64.iso.sig
```

## 准备安装

### 将ISO刻录到U盘

### 调整电脑为UEFI启动

## 安装

### 验证启动模式

```bash
cat /sys/firmware/efi/fw_platform_size
```

如果命令返回64，则表示系统以 UEFI 模式启动，并具有 64 位 x64 UEFI。
如果命令返回32，则表示系统以 UEFI 模式启动，并具有 32 位 IA32 UEFI。虽然支持此功能，但它会将引导加载程序的选择限制为支持混合模式启动的加载程序。
如果返回No such file or directory，则系统可能以BIOS（或CSM）模式启动

或

```bash
ls /sys/firmware/efi/efivars
```

若输出了一堆东西(EFI变量)，则说明已在 UEFI 模式

### 连接网络

#### 无线连接

```bash
iwctl # 进入交互式命令行
device list # 列出无线网卡设备名，比如无线网卡看到叫 wlan0
station wlan0 scan # 扫描网络
station wlan0 get-networks # 列出所有 wifi 网络
station wlan0 connect wifi-name # 进行连接，注意这里无法输入中文。回车后输入密码即可
exit # 连接成功后退出
```


```bash
lspci -k | grep Network
```
查看网卡驱动

```bash
rfkill list
rfkill unblock wifi
```
列出无线设备(蓝牙和网卡)
解除禁用网卡

```bash
ip link set wlan0 up
```


#### 有线连接

一般不会有问题

#### 测试连接

```bash
ping 1.1.1.1
```

### 更新系统时钟

```bash
timedatectl set-ntp true
timedatectl status
```

将系统时间与网络时间进行同步

检查服务状态

## 更换pacman源

```bash
vim /etc/pacman/mirrorlist
```

```text
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch # 中国科学技术大学开源镜像站
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch # 清华大学开源软件镜像站
Server = https://repo.huaweicloud.com/archlinux/$repo/os/$arch # 华为开源镜像站
Server = http://mirror.lzu.edu.cn/archlinux/$repo/os/$arch # 兰州大学开源镜像站
```

## 分区

使用ext4 <small>(后面可能尝试btrfs和zfs)</small>

btrfs可以查看[ArchLinux 简明指南](https://arch.icekylin.online/guide/rookie/basic-install.html#_7-%E5%88%86%E5%8C%BA%E5%92%8C%E6%A0%BC%E5%BC%8F%E5%8C%96-%E4%BD%BF%E7%94%A8-btrfs-%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)

### 创建分区

查看分区
```bash
lsblk
```

```bash
fdisk -l
```

分区
```bash
fdisk /dev/要分区的磁盘
```

```bash
cfdisk # 有TUI
```

### 格式化分区

格式化 EFI 分区
```bash
mkfs.fat -F32 /dev/nvmexn1pn
```

格式化 ext4 分区
```bash
mkfs.ext4 /dev/nvmexn1pn
```

不使用swap

### 挂载分区

挂载根目录
```bash
mount /dev/nvmexn1pn /mnt
```

挂载EFI
```bash
mount --mkdir /dev/nvmexn1pn /mnt/boot
```

### 检查挂载情况

```bash
df -h
```

## 安装系统

### pacstrap安装软件

pacstrap
```bash
pacstrap -K /mnt base base-devel linux linux-firmware vim NetWorkManager (amd-ucode / intel-ucode)
```

### 生成fstab

生成fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
检查fstab
```bash
cat /mnt/etc/fstab
```

### 系统设置

#### chroot
chroot
```bash
arch-chroot /mnt
```

#### 设置主机名
设置主机名
```bash
vim /etc/hostname
```

#### 设置时间
设置时区
```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

系统时间同步到硬件时间
```bash
hwclock --systohc
```

#### locale.gen
locale.gen
```bash
vim /etc/locale.gen
```
去掉 en_US.UTF-8 UTF-8 和 zh_CN.UTF-8 UTF-8 前面的注释
```bash
locale-gen
```

#### locale.conf
locale.conf
```bash
vim /etc/locale.conf
```
写入LANG=en_US.UTF-8
或者直接一条命令
```bash
echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
```

#### 密码
设置密码
```bash
passwd
```

#### vconsole
这个是KEYMAP
vconsole.conf
```bash
vim /etc/vconsole.conf
```


#### Initramfs
更新 Initramfs
```bash
mkinitcpio -P
```

## 安装引导

### grub
安装需要的包
```bash
pacman -S grub efibootmgr
```
安装grub
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```
修改grub默认配置文件
```bash
vim /etc/default/grub
```
修改启动参数
GRUB_CMDLINE_LINUX_DEFAULT

修改日志等级为5
loglevel=5

生成配置文件
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

如果不行尝试添加`--removable`

完成安装
```bash
exit
```

```bash
umount -R /mnt
```

```bash
reboot
```

# 系统设置

## zram
安装zram-generator
```bash
pacman -S zram-generator
```
创建/etc/systemd/zram-generator.conf
写入
```text
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
```
关闭zswap
```bash
echo 0 > /sys/module/zswap/parameters/enabled
```

启动zram-generator
```bash
systemctl daemon-reload
```

```bash
systemctl start systemd-zram-setup@zram0.service
```

修改grub配置文件
```bash
vim /etc/default/grub
```
修改启动参数
```text
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5 zswap.enabled=0"
```

## swapfile
(用来支持休眠)
创建交换文件

```bash
mkswap -U clear --size 8G --file /swapfile
```

启用交换文件
```bash
swapon /swapfile
```

添加到 /etc/fstab 中
```text
/swapfile none swap defaults 0 0
```

删除交换文件
```bash
swapoff /swapfile
```

```bash
rm -f /swapfile
```
从 /etc/fstab 中移除相关条目

## plymouth
安装plymouth
```bash
pacman -S plymouth
```

查看默认主题
```bash
plymouth-set-default-theme
```

编辑mkinitcpio.conf
```bash
vim /etc/mkinitcpio.conf
```

修改HOOKS
```text
HOOKS=(... plymouth ...)
```

如果使用systemd，它必须位于plymouth之前

此外，如果你的系统使用 dm-crypt 加密，请确保在 encrypt 或 sd-encrypt 之前放置 plymouth

更新 Initramfs
```bash
mkinitcpio -P
```

修改grub配置文件
```bash
vim /etc/default/grub
```
修改启动参数
```text
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5 splash zswap.enabled=0"
```

## 配置pacman.conf
编辑pacman.conf
```bash
vim /etc/pacman.conf|
```

去掉 [multilib] 两行的注释

添加
```text
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch # 中国科学技术大学开源镜像站
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch # 清华大学开源软件镜像站
Server = https://mirrors.hit.edu.cn/archlinuxcn/$arch # 哈尔滨工业大学开源镜像站
Server = https://repo.huaweicloud.com/archlinuxcn/$arch # 华为开源镜像站
```

## 创建用户

创建用户
```bash
useradd -m -G wheel myusernam
```

设置密码
```bash
passwd myusername
```

安装sudo
```bash
pacman -S sudo
```

添加sudo权限
```
vim /etc/sudoers
```

## 其他的一些包
```text

```
