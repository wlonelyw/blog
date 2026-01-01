---
title: QEMU虚拟机直通
date: 12/30/2025
updated:
tags: KVM QEMU
categories: libvirt
keywords: KVM QEMU
description: QEMU虚拟机直通硬件
top_img: cover.png
comments:
cover: cover.png
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

# 介绍

部分部分来自

[PVE WIKI](https://pve.proxmox.com/wiki/PCI(e)_Passthrough)

# 安装

```bash
# pacman -S libvirt virt-manager qemu-full
```

启动libvirtd
```bash
# systemctl start libvirtd
```
加入libvirt组
```bash
# usermod -aG libvirt $(whoami)
```

# 配置

查看是否支持(开启)硬件虚拟化
```bash
$ LC_ALL=C.UTF-8 lscpu | grep Virtualization
```
或
```bash
$ grep -E 'vmx|svm|0xc0f' /proc/cpuinfo
```

如果没有任何显示就先去`BIOS`看一下是否开启了虚拟化

## KVM

查看是否支持KVM内核模块
```bash
$ zgrep CONFIG_KVM= /proc/config.gz
```
`y`或`m`为可用

开机自动加载模块
创建`/etc/modules-load.d/kvm.conf`
写入
```text
kvm
 kvm_intel
```

加载模块时的参数
创建`/etc/modprobe.d/kvm_intel.conf`
写入
```text
options kvm_intel nested=1
```
`amd`需要改成`kvm_amd`

## IOMMU

启用`IOMMU`
添加内核参数
```text
intel_iommu=on
```
`amd`需要改成`amd_iommu`

启用`IOMMU`直通模式
添加内核参数
```bash
iommu=pt
```

## VFIO

创建`/etc/modules-load.d/vfio.conf`
写入
```bash
vfio
 vfio_iommu_type1
 vfio_pci
```

## VIRTIO
(这个其实可以不用设置 只是想写上来)
查看是否支持VIRTIO内核模块
```bash
$ zgrep VIRTIO /proc/config.gz
```
`y`或`m`为可用

开机自动加载模块
创建`/etc/modules-load.d/virtio.conf`
写入
```text
virtio
 virtio-net
 virtio-blk
 virtio-scsi
 virtio-serial
 virtio-balloon
```

## VIRT-MANAGER
打开virt-manager(虚拟系统管理器)
如果只有一个LXC

文件 > 添加连接 > 选择 QEMU/KVM > 连接
![](/2025/12/30/libvirt/virt-manager-add-connect.png)

## 结束

这个好像还不能用来直通GPU({% psw 没东西测 %})
其他的好像是没有问题()
