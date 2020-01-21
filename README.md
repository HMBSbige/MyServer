# 自用服务器设置
谢谢 Teddy Sun，breakwa11，Google 等

[免费 ss](https://my.freess.today/)

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

### 正确结果
```
ip address list
```

在en3中看到两个inet
