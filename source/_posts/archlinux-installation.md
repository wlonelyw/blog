---
title: ArchLinux 安装笔记
date: 12/07/2025
updated: 12/29/2025
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
background: "#ffffff"
---

  {% p center logo large, Arch %}
  {% p center small, I-use-arch-btw %}

# 介绍

**还在完善**

`UEFI` `EXT4` `BTRFS` `ZRAM` `SWAP` `ZSWAP` `GRUB` `SYSTEMD-BOOT`

内容大部分部分来自

[Archlinux Wiki](https://wiki.archlinux.org/)

[ArchLinux 简明指南](https://arch.icekylin.online/)


# 准备

## 下载验证ISO

### 下载ISO

```text
https://archlinux.org/releng/releases/

https://mirrors.aliyun.com/archlinux/iso/
https://mirrors.bfsu.edu.cn/archlinux/iso/
https://mirrors.cqu.edu.cn/archlinux/iso/
https://mirrors.hust.edu.cn/archlinux/iso/
https://mirrors.jcut.edu.cn/archlinux/iso/
https://mirrors.jlu.edu.cn/archlinux/iso/
https://mirrors.jxust.edu.cn/archlinux/iso/
https://mirrors.neusoft.edu.cn/archlinux/iso/
https://mirrors.nju.edu.cn/archlinux/iso/
https://mirror.nyist.edu.cn/archlinux/iso/
https://mirrors.qlu.edu.cn/archlinux/iso/
https://mirrors.shanghaitech.edu.cn/archlinux/iso/
https://mirrors.sjtug.sjtu.edu.cn/archlinux/iso/
https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/
https://mirrors.ustc.edu.cn/archlinux/iso/
https://mirrors.wsyu.edu.cn/archlinux/iso/
https://mirrors.xjtu.edu.cn/archlinux/iso/
```

### 验证签名

从 [checksums](https://archlinux.org/download/#checksums) 下载`ISO` `PGP` 签名到 `ISO` 目录

```bash
# pacman-key -v archlinux- version -x86_64.iso.sig
```

## 准备安装

### 将ISO刻录到U盘

`Ventoy` `Rufus` `BalenaEtcher`

### 调整电脑为UEFI启动

### 从U盘启动

## 安装

### 验证启动模式

```bash
# cat /sys/firmware/efi/fw_platform_size
```

如果命令返回`64`，则表示系统以 UEFI 模式启动，并具有 64 位 `x64 UEFI`。
如果命令返回`32`，则表示系统以 UEFI 模式启动，并具有 32 位 `x32 UEFI`。虽然支持此功能，但它会将引导加载程序的选择限制为支持混合模式启动的加载程序。
如果返回No such file or directory(没有efi这个文件夹)，则系统可能以BIOS（或CSM）模式启动

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
# lspci -k | grep Network
```
查看网卡驱动

列出无线设备(蓝牙和网卡)
解除禁用网卡
```bash
# rfkill list
# rfkill unblock wifi
```

```bash
# ip link set wlan0 up
```

#### 有线连接

一般不会有问题

#### 测试连接

```bash
# ping 1.1.1.1
```

### 更新系统时钟

将系统时间与网络时间进行同步
```bash
# timedatectl set-ntp true
# timedatectl set-timezone Asia/Shanghai
# timedatectl status
```

检查服务状态
```bash
# timedatectl
```

## 更换PACMAN源

```bash
# vim /etc/pacman/mirrorlist
```

```text
# 中国科学技术大学开源镜像站
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
# 清华大学开源软件镜像站
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
# 华为开源镜像站
Server = https://repo.huaweicloud.com/archlinux/$repo/os/$arch
# 兰州大学开源镜像站
Server = http://mirror.lzu.edu.cn/archlinux/$repo/os/$arch
```

## 分区

### 创建分区

查看分区

{% tabs lsdisk %}
<!-- tab lsblk -->
```bash
# lsblk
```
<!-- endtab -->
<!-- tab fdisk -l -->
```bash
# fdisk -l
```
<!-- endtab -->
{% endtabs %}

分区

{% tabs cfdisk %}
<!-- tab fdisk -->
```bash
# fdisk /dev/nvmexn1pn
```
<!-- endtab -->
<!-- tab cfdisk -->
```bash
# cfdisk /dev/nvmexn1pn
```
<!-- endtab -->
{% endtabs %}

如果你是一整个磁盘装可以先
```bash
# mkfs /dev/nvmexn1pn
```

#### 格式化分区

{% tabs mkfs %}
<!-- tab ext4 -->
格式化 EFI 分区
```bash
# mkfs.fat -F32 /dev/nvmexn1pn
```
格式化 EXT4 分区
```bash
# mkfs.ext4 /dev/nvmexn1pn
```
<!-- endtab -->
<!-- tab btrfs -->
格式化 EFI 分区
```bash
# mkfs.fat -F32 /dev/nvmexn1pn
```
格式化 BTRFS 分区
```bash
# mkfs.btrfs -L 自定义卷标 /dev/nvmexn1pn
```
<!-- endtab -->
{% endtabs %}

#### 挂载分区

{% tabs mount %}
<!-- tab ext4 -->
挂载根目录
```bash
# mount /dev/nvmexn1pn /mnt
```
挂载EFI
```bash
# mount --mkdir /dev/nvmexn1pn /mnt/boot
```
<!-- endtab -->
<!-- tab btrfs -->
先挂载到/mnt
```bash
# mount -t btrfs -o compress=zstd /dev/nvmexn1pn /mnt
```
创建子卷
```bash
# btrfs subvolume create /mnt/@
# btrfs subvolume create /mnt/@home
```
查看所有子卷
```bash
# btrfs subvolume list -p /mnt
```
取消挂载
```bash
# umount /mnt
```
重新挂载
```
# mount -t btrfs -o subvol=/@,noatime,compress=zstd /dev/nvmexn1pn /mnt
# mount --mkdir -t btrfs -o subvol=/@home,noatime,compress=zstd /dev/nvmexn1pn /mnt/home
# mount --mkdir /dev/nvmexn1pn /mnt/boot
```
<!-- endtab -->
{% endtabs %}

### 检查挂载情况

```bash
# df -h
```

## 安装系统

### PACSTRAP

```bash
# pacstrap -K /mnt base base-devel linux linux-firmware vim networkmanager (amd-ucode / intel-ucode) (btrfs-progs)
```
(amd-ucode / intel-ucode) 根据你的CPU选择
如果使用btrfs需要安装btrfs-progs

### FSTAB

```bash
# genfstab -U /mnt > /mnt/etc/fstab
```
检查fstab
```bash
# cat /mnt/etc/fstab
```

### 系统设置

#### CHROOT

```bash
# arch-chroot /mnt
```

#### 设置主机名

设置主机名
```bash
# vim /etc/hostname
```

#### 设置时间

设置本地时间时区
```bash
# ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

系统时间同步到硬件时间
```bash
# hwclock --systohc
```

#### LOCALE

##### locale.gen

```bash
# vim /etc/locale.gen
```
去掉 `en_US.UTF-8 UTF-8` 和 `zh_CN.UTF-8 UTF-8` 前面的注释

也可以进系统再执行
```bash
# locale-gen
```

##### locale.conf

```bash
# vim /etc/locale.conf
```
写入`LANG=en_US.UTF-8`

或者直接一条命令
```bash
# echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
```

#### 密码

设置root密码

```bash
# passwd
```

#### VCONSOLE

编辑`/etc/vconsole.conf`
写入
```text
KEYMAP=us
```

#### INITRAMFS

更新 `initramfs`

```bash
# mkinitcpio -P
```

## 安装引导

### GRUB

安装需要的包

```bash
# pacman -S grub efibootmgr (os-prober)
```
(os-prober) 如果你没有其他系统可以不安装

安装grub

```bash
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```
(如果这样不能启动尝试添加`--removable`)

修改grub默认配置文件`/etc/default/grub`
修改启动参数
`GRUB_CMDLINE_LINUX_DEFAULT`
修改日志等级为5
`loglevel=5`

生成配置文件
```bash
# grub-mkconfig -o /boot/grub/grub.cfg
```

### SYSTEMD-BOOT

```bash
# bootctl install
```

{% note warning no-icon %}出现 <font color='red' >Mount point '/boot' which backs the random seed file is world accessible, which is a security hole! </font>
是 `/boot` 分区的权限问题
修改`/etc/fstab` `/boot` 挂载权限 `fmask=0137,dmask=0027`
来自 [Silly Cat's Blog](https://mkv.moe/post/Arch-Linux-installation-notes-for-my-own-use/)
{% endnote %}

修改`/boot/loader/loader.conf`
```text
default arch.conf
# timeout为0时按住Space进入选择菜单
timeout 0
console-mode max
editor no
```

{% tabs systemd-boot %}
<!-- tab ext4-systemd-boot -->
添加 `/boot/loader/entries/arch.conf`
```text
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw rootfstype=ext4 loglevel=5
```

添加 `/boot/loader/entries/arch-fallback.conf`
```text
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw rootfstype=ext4 loglevel=5
```
`UUID`需要改成你自己的
<!-- endtab -->
<!-- tab btrfs-systemd-boot -->
添加 `/boot/loader/entries/arch.conf`
```text
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw rootfstype=btrfs rootflags=subvol=@ loglevel=5
```

添加 `/boot/loader/entries/arch-fallback.conf`
```text
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw rootfstype=btrfs rootflags=subvol=@ loglevel=5
```
`UUID`需要改成你自己的
<!-- endtab -->
{% endtabs %}

启动参数根据需要添加

## 结束

完成安装
```bash
# exit
```

```bash
# umount -R /mnt
```

```bash
# reboot
```

# 系统设置

## ZRAM

安装`zram-generator`
```bash
# pacman -S zram-generator
```

创建`/etc/systemd/zram-generator.conf`
写入
```text
[zram0]
zram-size = min(ram / 2, 4096)
compression-algorithm = zstd
```

关闭`zswap`
```bash
# echo 0 > /sys/module/zswap/parameters/enabled
```

启动`zram-generator`
```bash
# systemctl daemon-reload
```

```bash
# systemctl start systemd-zram-setup@zram0.service
```

启动参数添加`zswap.enabled=0`

## SWAPFILE

{% tabs swapfile %}
<!-- tab ext4 -->
(如果你使用`zram`可以添加`swapfile`休眠)
创建`swapfile`
```bash
# mkswap -U clear --size 8G --file /swapfile
```
启用`swapfile`
```bash
# swapon /swapfile
```
添加到`/etc/fstab`中
```text
/swapfile none swap defaults 0 0
```

删除`swapfile`
```bash
# swapoff /swapfile
```

```bash
# rm -f /swapfile
```
从`/etc/fstab`中移除相关条目
<!-- endtab -->
<!-- tab btrfs -->
还没写
<!-- endtab -->
{% endtabs %}

## PLYMOUTH
(开机动画)

安装`plymouth`

```bash
# pacman -S plymouth
```

编辑mkinitcpio.conf
```bash
# vim /etc/mkinitcpio.conf
```

修改HOOKS
```text
# HOOKS=(... plymouth ...)
```

如果使用`systemd`，它必须位于`plymouth`之前

此外，如果你的系统使用 `dm-crypt` 加密，请确保在 encrypt 或 `sd-encrypt` 之前放置 `plymouth`

更新 `Initramfs`
```bash
# mkinitcpio -P
```

启动参数添加`splash`

查看所有主题
```bash
# plymouth-set-default-theme -l
```

查看默认主题
```bash
# plymouth-set-default-theme
```

修改主题
```bash
# plymouth-set-default-theme <theme-name>
```

## PACMAN

编辑`pacman.conf`
```bash
# vim /etc/pacman.conf
```

去掉`[multilib]`选项的注释
```text
#[core-testing]
#Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

#[extra-testing]
#Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

# If you want to run 32 bit applications on your x86_64 system,
# enable the multilib repositories as required here.

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
```

添加`archlinuxcn`源
```text
[archlinuxcn]
# 中国科学技术大学开源镜像站
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
# 清华大学开源软件镜像站
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
# 哈尔滨工业大学开源镜像站
Server = https://mirrors.hit.edu.cn/archlinuxcn/$arch
# 华为开源镜像站
Server = https://repo.huaweicloud.com/archlinuxcn/$arch
```

## 创建用户

创建用户
```bash
# useradd -m -G wheel myusernam
```

设置密码
```bash
# passwd myusername
```

安装sudo
```bash
# pacman -S sudo
```

编辑`/etc/sudoers`
修改
```text
##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL:ALL) ALL

## Uncomment to allow members of group wheel to execute any command
# %wheel ALL=(ALL:ALL) ALL

## Same thing without a password
# %wheel ALL=(ALL:ALL) NOPASSWD: ALL

## Uncomment to allow members of group sudo to execute any command
# %sudo ALL=(ALL:ALL) ALL
```
取消注释`%wheel ALL=(ALL:ALL) ALL`

## AUR
`paru` `yay`

如果添加了`archlinuxcn`可以直接安装
```bash
# pacman -S yay paru
```

手动安装
```bash
# pacman -S git
```

`paru`
```bash
$ git clone https://aur.archlinux.org/paru-bin.git
$ cd paru-bin
$ makepkg -sir
```

`yay`
```bash
$ git clone https://aur.archlinux.org/yay-bin.git
$ cd yay-bin
$ makepkg -sir
```

## 其他的一些包
```text
# pacman
adobe-source-han-sans-cn-fonts
adobe-source-han-serif-cn-fonts
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
wqy-microhei
wqy-microhei-lite
wqy-bitmapfont
wqy-zenhei
ttf-arphic-ukai
ttf-arphic-uming
ttf-jetbrains-mono-nerd

nvidia
nvidi-open-dkms
nvidia-settings
lib32-opencl-nvidia
nvidia-utils
lib32-nvidia-utils
opencl-nvidia

net-tools
dnsmasq

lolcat
fastfetch

# aur
ttf-ms-win11-auto
```
