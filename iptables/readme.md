# 自用Ubuntu 17.04 x64 iptables设置
```
# 初始化
iptables -F
iptables -X
iptables -Z

iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
# 允许ping
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 0 -j ACCEPT
# 开放端口
iptables -A INPUT -p tcp --dport ssh -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p udp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 4000 -j ACCEPT
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
iptables -A INPUT -p tcp --dport 3001 -j ACCEPT
iptables -A INPUT -p udp --dport 3000 -j ACCEPT
iptables -A INPUT -p udp --dport 3001 -j ACCEPT
# Resilio Sync路由转发
iptables -t nat -A PREROUTING -p tcp --dport 4000 -j DNAT --to-destination 173.244.217.42:4000
iptables -t nat -A PREROUTING -p tcp --dport 4000 -j DNAT --to-destination 209.95.56.60:4000
iptables -t nat -A PREROUTING -p tcp --dport 3000 -j DNAT --to-destination 107.182.230.198:3000
iptables -t nat -A PREROUTING -p udp --dport 3000 -j DNAT --to-destination 107.182.230.198:3000
iptables -t nat -A PREROUTING -p tcp --dport 3001 -j DNAT --to-destination 107.182.230.198:3001
iptables -t nat -A PREROUTING -p udp --dport 3001 -j DNAT --to-destination 107.182.230.198:3001
iptables -t nat -A PREROUTING -p tcp --dport 3000 -j DNAT --to-destination 173.244.209.150:3000
iptables -t nat -A PREROUTING -p udp --dport 3000 -j DNAT --to-destination 173.244.209.150:3000
iptables -t nat -A PREROUTING -p tcp --dport 3001 -j DNAT --to-destination 173.244.209.150:3001
iptables -t nat -A PREROUTING -p udp --dport 3001 -j DNAT --to-destination 173.244.209.150:3001
iptables -t nat -A POSTROUTING -j MASQUERADE
# 保存
iptables-save >/etc/iptables.up.rules
```

## 关于Resilio Sync的relay 和 tracker 服务器
https://config.resilio.com/sync.conf

从上面的连接获取官方的IP地址后，用自己的服务器转发

并自建sync.conf服务器，然后在host添加

> 服务器IP config.getsync.com config.resilio.com config.usyncapp.com
