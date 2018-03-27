#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear

#Current folder
cur_dir=`pwd`

# Make sure only root can run our script
rootness(){
	if [[ $EUID -ne 0 ]]; then
	   echo "错误：此脚本必须以root身份运行!" 1>&2
	   exit 1
	fi
}

# Disable selinux
disable_selinux(){
	if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
		setenforce 0
	fi
}

#Check system
check_sys(){
	local checkType=$1
	local value=$2

	local release=''
	local systemPackage=''

	if [[ -f /etc/redhat-release ]]; then
		release="centos"
		systemPackage="yum"
	elif cat /etc/issue | grep -Eqi "debian"; then
		release="debian"
		systemPackage="apt"
	elif cat /etc/issue | grep -Eqi "ubuntu"; then
		release="ubuntu"
		systemPackage="apt"
	elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
		release="centos"
		systemPackage="yum"
	elif cat /proc/version | grep -Eqi "debian"; then
		release="debian"
		systemPackage="apt"
	elif cat /proc/version | grep -Eqi "ubuntu"; then
		release="ubuntu"
		systemPackage="apt"
	elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
		release="centos"
		systemPackage="yum"
	fi

	if [[ ${checkType} == "sysRelease" ]]; then
		if [ "$value" == "$release" ]; then
			return 0
		else
			return 1
		fi
	elif [[ ${checkType} == "packageManager" ]]; then
		if [ "$value" == "$systemPackage" ]; then
			return 0
		else
			return 1
		fi
	fi
}

# Get version
getversion(){
	if [[ -s /etc/redhat-release ]]; then
		grep -oE  "[0-9.]+" /etc/redhat-release
	else
		grep -oE  "[0-9.]+" /etc/issue
	fi
}

# CentOS version
centosversion(){
	if check_sys sysRelease centos; then
		local code=$1
		local version="$(getversion)"
		local main_ver=${version%%.*}
		if [ "$main_ver" == "$code" ]; then
			return 0
		else
			return 1
		fi
	else
		return 1
	fi
}

# Get public IP address
get_ip(){
	local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
	[ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
	[ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
	[ ! -z ${IP} ] && echo ${IP} || echo
}

get_char(){
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
}
rand() {
	index=0
	str=""
	for i in {a..z}; do arr[index]=${i}; index=`expr ${index} + 1`; done
	for i in {A..Z}; do arr[index]=${i}; index=`expr ${index} + 1`; done
	for i in {0..9}; do arr[index]=${i}; index=`expr ${index} + 1`; done
	for i in {1..20}; do str="$str${arr[$RANDOM%$index]}"; done
	echo ${str}
}
# Pre-installation settings
pre_install(){
	if check_sys packageManager yum || check_sys packageManager apt; then
		# Not support CentOS 5
		if centosversion 5; then
			echo "错误：不支持CentOS 5，请用CentOS 6+/Debian 7+/Ubuntu 12+。"
			exit 1
		fi
	else
		echo "错误：不支持你的操作系统。请用CentOS 6+/Debian 7+/Ubuntu 12+。"
		exit 1
	fi
	# Set ShadowsocksR config password
	randpassword=`rand`
	echo "请输入ShadowsocksR密码："
	read -p "(默认密码: ${randpassword}):" shadowsockspwd
	[ -z "${shadowsockspwd}" ] && shadowsockspwd="${randpassword}"
	echo
	echo "---------------------------"
	echo "密码 = ${shadowsockspwd}"
	echo "---------------------------"
	echo
	# Set ShadowsocksR config port
	while true
	do
	echo -e "请输入ShadowsocksR监听端口[1-65535]："
	read -p "(默认端口: 443):" shadowsocksport
	[ -z "${shadowsocksport}" ] && shadowsocksport="443"
	expr ${shadowsocksport} + 0 &>/dev/null
	if [ $? -eq 0 ]; then
		if [ ${shadowsocksport} -ge 1 ] && [ ${shadowsocksport} -le 65535 ]; then
			echo
			echo "---------------------------"
			echo "端口 = ${shadowsocksport}"
			echo "---------------------------"
			echo
			break
		else
			echo "输入错误，请输入正确的数字"
		fi
	else
		echo "输入错误，请输入正确的数字"
	fi
	done

	echo
	echo "请按任意键继续...或按Ctrl+C取消"
	char=`get_char`
	# Install necessary dependencies
	if check_sys packageManager yum; then
		yum install -y unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel
	elif check_sys packageManager apt; then
		apt-get -y update
		apt-get -y install python python-dev python-pip python-m2crypto curl wget unzip gcc swig automake make perl cpio build-essential
	fi
	cd ${cur_dir}
}

# Download files
download_files(){
	# Download libsodium file
	if ! wget --no-check-certificate -O libsodium-1.0.16.tar.gz https://github.com/jedisct1/libsodium/releases/download/1.0.15/libsodium-1.0.16.tar.gz; then
		echo "libsodium-1.0.16.tar.gz下载失败!"
		exit 1
	fi
	# Download ShadowsocksR file
	if ! wget --no-check-certificate -O manyuser.zip https://github.com/HMBSbige/shadowsocksr/archive/manyuser.zip; then
		echo "ShadowsocksR下载失败!"
		exit 1
	fi
	# Download ShadowsocksR init script 
	if ! wget --no-check-certificate https://raw.githubusercontent.com/HMBSbige/MyServer/master/ShadowsocksR/init.sh -O /etc/init.d/shadowsocks; then
				echo "ShadowsocksR初始化脚本下载失败!"
			exit 1
	 	fi
}

# Firewall set
firewall_set(){
	echo "开始设置防火墙..."
	if centosversion 6; then
		/etc/init.d/iptables status > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			iptables -L -n | grep -i ${shadowsocksport} > /dev/null 2>&1
			if [ $? -ne 0 ]; then
				iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${shadowsocksport} -j ACCEPT
				iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${shadowsocksport} -j ACCEPT
				/etc/init.d/iptables save
				/etc/init.d/iptables restart
			else
				echo "端口 ${shadowsocksport} 设置完成。"
			fi
		else
			echo "警告: iptables好像未启动或根本没安装, 如有需要请手动设置。"
		fi
	elif centosversion 7; then
		systemctl status firewalld > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/tcp
			firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/udp
			firewall-cmd --reload
		else
			echo "Firewalld好像未运行，正在尝试启动..."
			systemctl start firewalld
			if [ $? -eq 0 ]; then
				firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/tcp
				firewall-cmd --permanent --zone=public --add-port=${shadowsocksport}/udp
				firewall-cmd --reload
			else
				echo "警告: 尝试启动Firewalld失败。 如有需要请手动启用 ${shadowsocksport} 端口。"
			fi
		fi
	fi
	echo "防火墙设置完成!"
}

# Config ShadowsocksR
config_shadowsocks(){
	cat > /etc/shadowsocks.json<<-EOF
{
	"server":"0.0.0.0",
	"server_ipv6":"::",
	"local_address":"127.0.0.1",
	"local_port":23333,
	"port_password":{
		"${shadowsocksport}":"${shadowsockspwd}"
	},
	"timeout":600,
	"method":"none",
	"protocol": "auth_chain_d",
	"protocol_param": "",
	"obfs": "tls1.2_ticket_auth_compatible",
	"obfs_param": "",
	"redirect": ["steamcommunity.com:443","github.com:443"],
	"dns_ipv6": false,
	"fast_open": true,
	"workers": 1
}
EOF
}

# Install ShadowsocksR
install(){
	# Install libsodium
	tar zxf libsodium-1.0.16.tar.gz
	cd libsodium-1.0.16
	./configure && make && make install
	if [ $? -ne 0 ]; then
		echo "libsodium安装失败!"
		install_cleanup
		exit 1
	fi
	echo "/usr/local/lib" > /etc/ld.so.conf.d/local.conf
	ldconfig
	# Install ShadowsocksR
	cd ${cur_dir}
	unzip -q manyuser.zip
	mv shadowsocksr-manyuser/shadowsocks /usr/local/
	if [ -f /usr/local/shadowsocks/server.py ]; then
		chmod +x /etc/init.d/shadowsocks
		if check_sys packageManager yum; then
			chkconfig --add shadowsocks
			chkconfig shadowsocks on
		elif check_sys packageManager apt; then
			update-rc.d -f shadowsocks defaults
		fi
		/etc/init.d/shadowsocks start

		clear
		echo
		echo "ShadowsocksR安装完成!"
		echo -e "服务器 IP: \033[41;37m $(get_ip) \033[0m"
		echo -e "服务器 Port: \033[41;37m ${shadowsocksport} \033[0m"
		echo -e "密码: \033[41;37m ${shadowsockspwd} \033[0m"
		echo -e "本地 IP: \033[41;37m 127.0.0.1 \033[0m"
		echo -e "本地端口: \033[41;37m 23333 \033[0m"
		echo -e "协议: \033[41;37m auth_chain_d \033[0m"
		echo -e "混淆: \033[41;37m tls1.2_ticket_auth_compatible \033[0m"
		echo -e "加密方式: \033[41;37m none \033[0m"
		echo
	else
		echo "ShadowsocksR安装失败!"
		install_cleanup
		exit 1
	fi
}

# Install cleanup
install_cleanup(){
	cd ${cur_dir}
	rm -rf manyuser.zip shadowsocks-manyuser libsodium-1.0.16.tar.gz libsodium-1.0.16
}


# Uninstall ShadowsocksR
uninstall_shadowsocks(){
	printf "确定卸载ShadowsocksR? (y/n)"
	printf "\n"
	read -p "(Default: n):" answer
	[ -z ${answer} ] && answer="n"
	if [ "${answer}" == "y" ] || [ "${answer}" == "Y" ]; then
		/etc/init.d/shadowsocks status > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			/etc/init.d/shadowsocks stop
		fi
		if check_sys packageManager yum; then
			chkconfig --del shadowsocks
		elif check_sys packageManager apt; then
			update-rc.d -f shadowsocks remove
		fi
		rm -f /etc/shadowsocks.json
		rm -f /etc/init.d/shadowsocks
		rm -f /var/log/shadowsocks.log
		rm -rf /usr/local/shadowsocks
		echo "ShadowsocksR卸载成功!"
	else
		echo
		echo "卸载程序被取消..."
		echo
	fi
}

# Install ShadowsocksR
install_shadowsocks(){
	rootness
	disable_selinux
	pre_install
	download_files
	config_shadowsocks
	install
	if check_sys packageManager yum; then
		firewall_set
	fi
	install_cleanup
}

# Initialization step
action=$1
[ -z $1 ] && action=install
case "$action" in
	install|uninstall)
	${action}_shadowsocks
	;;
	*)
	echo "参数错误! [${action}]"
	echo "用法: `basename $0` {install|uninstall}"
	;;
esac
