# 自用服务器设置
谢谢 Teddy Sun，breakwa11，Google 等

[免费 ss](https://get.freess.today/)

## 测试1

Vultr东京节点-上海电信100M

测试下载
```
http://releases.ubuntu.com/16.04.1/ubuntu-16.04.1-desktop-amd64.iso
```
连接方法 | 单线程平均速度 | 多(32)线程平均速度
---|---|---
L2TP/IPSec|几乎没有速度|16.413KB/S
L2TP/IPSec+锐速|48.400KB/S|902.368KB/S
ShadowsocksR|90.769KB/S|2.683MB/S
ShadowsocksR+TCP-BBR|821.418KB/S|10.162MB/S
ShadowsocksR+锐速|695.786KB/S|14.434MB/S

在启用TCP-BBR或锐速时，多线程下载其实均100M满速，但是TCP-BBR会有部分波动。

这是凌晨测试的，与高峰时段测试大致相同。

高峰时段用锐速单线程大概300+KB/S，TCP-BBR单线程大概600+KB/S

## 测试2

Vultr西雅图节点-上海电信100M

测试下载
```
http://releases.ubuntu.com/17.04/ubuntu-17.04-desktop-amd64.iso
```
连接方法 | 单线程平均速度 | 多(32)线程平均速度
---|---|---
ShadowsocksR|3.115MB/S|14.352MB/S
ShadowsocksR+TCP-BBR|11.594MB/S|14.333MB/S

~~然而对于电信来说不是CN2线路丢包还是太严重了...~~

## 测试3
搬瓦工CN2-上海电信200M

测试下载
```
http://releases.ubuntu.com/17.10.1/ubuntu-17.10.1-desktop-amd64.iso
```
加密|协议|混淆|单线程下载平均速度|多(32)线程下载平均速度
---|---|---|---|---
none|auth_chain_a|tls1.2_ticket_auth|12.7MB/S|15.1MB/S
none|auth_chain_a|plain|14.9MB/S|15.1MB/S
none|origin|plain|13.8MB/S|26.9MB/S

# **👆以上测试已经过时**

## 测试4
Vultr/搬瓦工-上海电信200M(Only IPv4)

测试地址

https://fast.com/

ID|地理位置|网际协议(IP)版本|平均延迟（ms）|丢包率（%）|下行速度
---|---|---|---|---|---
1|法兰克福-Vultr|4|201|0|240Mbps
2|法兰克福-Vultr|6|275|33|170Kbps
3|法兰克福-Vultr|6|293|25|97Kbps
4|法兰克福-Vultr|6|285|31|250Kbps
5|洛杉矶-Vultr|4|160|0|50Mbps
6|洛杉矶-Vultr|6|269|6|2.1Mbps
7|洛杉矶-Vultr|6|279|14|3Mbps
8|洛杉矶-Vultr|6|279|6|2.6Mbps
9|洛杉矶-搬瓦工QNETCN2|4|166|0|180Mbps

高峰期测 IPv6 速度好慢，闲时测跟 IPv4 差不多的

## 关闭22端口使用密钥来进行登录
### 设置密钥
```
mkdir -p /root/.ssh
chmod 600 /root/.ssh
echo ecdsa-sha2-nistp521 AA... youremail@example.com > /root/.ssh/authorized_keys
chmod 700 /root/.ssh/authorized_keys
```
### 修改SSH配置文件
```
vim /etc/ssh/sshd_config
```
```
Port 22 # 修改端口
PermitRootLogin yes # 是否允许Root使用SSH登陆
RSAAuthentication yes # 可能没有
PubkeyAuthentication yes # 使用密钥登陆
PasswordAuthentication no # 使用密钥登陆测试成功后再修改
ChallengeResponseAuthentication no
```
### 重启SSH服务
```
service sshd restart
```

## Ubuntu 18.04 启用多个 IP 地址
### 更改 hostname
```
hostnamectl set-hostname $hostname
```

### 修改配置文件
```
vim /etc/netplan/10-ens3.yaml
```
根据自己的网络，修改`10-ens3.yaml`

格式像下面这样
```
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      dhcp4: no
      addresses: [$IP1/$CIDR1,$IP2/$CIDR2,'$IPv6/$Netmask']
      gateway4: $Gateway4
      nameservers:
        addresses: [$DNS]
      routes:
      - to: 169.254.0.0/16
        via: $Gateway4
        metric: 100
```

### 应用
```
netplan apply
```
