# 自用服务器设置
谢谢 Teddy Sun，breakwa11，Google 等

[免费 ss](https://get.freess.today/)

## 测试

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
