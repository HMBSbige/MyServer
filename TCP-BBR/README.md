# TCP-BBR
## Centos 6 下一键安装
### 安装
```
wget https://raw.githubusercontent.com/HMBSbige/MyServer/master/TCP-BBR/InstallBBRonCentOS6.sh && sh InstallBBRonCentOS6.sh
```


### 验证是否安装成功
```
lsmod | grep bbr
```

## Centos 7

### 更换内核
```
rpm --import https://raw.githubusercontent.com/HMBSbige/MyServer/master/TCP-BBR/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://raw.githubusercontent.com/HMBSbige/MyServer/master/TCP-BBR/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-ml -y
```
### 查看内核是否安装成功
```
rpm -qa | grep kernel
```
### 更新 grub 系统引导文件并重启
```
egrep ^menuentry /etc/grub2.cfg | cut -f 2 -d \'
grub2-set-default 0
reboot
```

## Debian8/Ubuntu14

### 安装
```
wget https://raw.githubusercontent.com/HMBSbige/MyServer/master/TCP-BBR/linux-image-4.9.0-040900rc8-generic_4.9.0-040900rc8.201612051443_amd64.deb
dpkg -i linux-image-4.9.0*.deb
```
### 删除其余内核
```
dpkg -l|grep linux-image

apt-get purge ID
```
如：
```
apt-get purge linux-image-4.4.0-31-generic linux-image-4.4.0-57-generic linux-image-extra-4.4.0-31-generic linux-image-extra-4.4.0-57-generic
```
### 更新 grub 系统引导文件并重启
```
update-grub
reboot
```
## 安装BBR

### 查看当前内核
```
uname -r
```
### 开启TCP-BBR
```
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
```
### 保存，生效
```
sysctl -p
```
### 检测是否完全生效
```
sysctl net.ipv4.tcp_available_congestion_control
sysctl -n net.ipv4.tcp_congestion_control
lsmod | grep bbr
```
显示：
```
net.ipv4.tcp_available_congestion_control = bbr cubic reno
bbr
tcp_bbr                16384  0
```

## Ubuntu17.04

### 查看当前内核
```
uname -r
```
内核版本大于等于 Linux 4.9 即可使用BBR
### 开启TCP-BBR
```
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
```
### 保存，生效
```
sysctl -p
```
显示：
```
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
```
### 检测是否完全生效
```
sysctl net.ipv4.tcp_available_congestion_control
sysctl -n net.ipv4.tcp_congestion_control
lsmod | grep bbr
```
显示：
```
net.ipv4.tcp_available_congestion_control = bbr cubic reno
bbr
tcp_bbr                20480  1
```
### 禁用 BBR
```
sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf
sed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf
sysctl -p
reboot
```

# 内核升级

查看内核版本
```
uname -r
```

## CentOS
```
yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel
```
* CentOS6
```
sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
```
* CentOS7
```
grub2-set-default 0
```

## Debian/Ubuntu
[下载最新镜像](http://kernel.ubuntu.com/~kernel-ppa/mainline/)

* 如果系统是 64 位，则下载 amd64 的 linux-image 中含有 generic 这个 deb 包
* 如果系统是 32 位，则下载 i386 的 linux-image 中含有 generic 这个 deb 包

如:
* 下载
```
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.15/linux-image-4.15.0-041500-generic_4.15.0-041500.201801282230_amd64.deb
```
* 安装
```
dpkg -i linux-image-4.15.0-041500-generic_4.15.0-041500.201801282230_amd64.deb
```
* 更新 grub 系统引导文件并重启
```
update-grub
reboot
```
