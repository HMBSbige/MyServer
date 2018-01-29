#!/usr/bin/env bash

name=ShadowsocksRR
path=/var/log
[[ ! -d ${path} ]] && mkdir -p ${path}
log=${path}/shadowsocks-crond.log

init=/etc/init.d/shadowsocks

pid=""
if [ -f ${init} ]; then
	ss_status=`${init} status`
	if [ $? -eq 0 ]; then
		pid=`echo $ss_status | sed 's/[^0-9]*//g'`
	fi

	if [ -z ${pid} ]; then
		echo "`date +"%Y-%m-%d %H:%M:%S"` ${name[$i]} is not running" >> ${log}
		echo "`date +"%Y-%m-%d %H:%M:%S"` Starting ${name[$i]}" >> ${log}
		${init} start &>/dev/null
		if [ $? -eq 0 ]; then
			echo "`date +"%Y-%m-%d %H:%M:%S"` ${name[$i]} start success" >> ${log}
		else
			echo "`date +"%Y-%m-%d %H:%M:%S"` ${name[$i]} start failed" >> ${log}
		fi
	else
		echo "`date +"%Y-%m-%d %H:%M:%S"` ${name[$i]} is running with pid $pid" >> ${log}
	fi
fi
