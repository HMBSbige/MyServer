# 自用服务器设置
谢谢91yun，breakwa11，Google等

## 测试

Vultr东京节点-上海电信100M

测试下载
```
http://releases.ubuntu.com/16.04.1/ubuntu-16.04.1-desktop-amd64.iso
```
连接方法 | 单线程平均速度 | 多(32)线程平均速度
---|---|---|
ShadowsocksR|90.769KB/S|2.683MB/S
ShadowsocksR+TCP-BBR|821.418KB/S|10.162MB/S
ShadowsocksR+锐速|695.786KB/S|14.434MB/S

在启用TCP-BBR或锐速时，多线程下载其实均100M满速，但是TCP-BBR会有部分波动。

这是凌晨测试的，与高峰时段测试大致相同。

高峰时段用锐速单线程大概300+KB/S，TCP-BBR单线程大概600+KB/S
