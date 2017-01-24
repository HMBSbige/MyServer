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
rpm --import https://github.com/HMBSbige/MyServer/TCP-BBR/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://github.com/HMBSbige/MyServer/TCP-BBR/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
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
