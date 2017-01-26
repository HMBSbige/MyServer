#!/bin/sh
# chkconfig: 2345 90 10
# description: Start or stop the Shadowsocks R server
#
### BEGIN INIT INFO
# Provides: Shadowsocks-R
# Required-Start: $network $syslog
# Required-Stop: $network
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Start or stop the Shadowsocks R server
### END INIT INFO

NAME=ShadowsocksR
BIN=/usr/local/shadowsocks/server.py
if [ -f /etc/shadowsocks-r/config.json ]; then
    CONF=/etc/shadowsocks-r/config.json
elif [ -f /etc/shadowsocks.json ]; then
    CONF=/etc/shadowsocks.json
fi
RETVAL=0

check_running(){
    PID=`ps -ef | grep -v grep | grep -i "${BIN}" | awk '{print $2}'`
    if [ ! -z $PID ]; then
        return 0
    else
        return 1
    fi
}

do_start(){
    check_running
    if [ $? -eq 0 ]; then
        echo "$NAME (pid $PID) 已在运行..."
        exit 0
    else
        $BIN -c $CONF -d start
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            echo "启动 $NAME 成功"
        else
            echo "启动 $NAME 失败"
        fi
    fi
}

do_stop(){
    check_running
    if [ $? -eq 0 ]; then
        $BIN -c $CONF -d stop
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            echo "结束 $NAME 成功"
        else
            echo "结束 $NAME 失败"
        fi
    else
        echo "$NAME 未在运行"
        RETVAL=1
    fi
}

do_status(){
    check_running
    if [ $? -eq 0 ]; then
        echo "$NAME (pid $PID) 正在运行..."
    else
        echo "$NAME 未启动"
        RETVAL=1
    fi
}

do_restart(){
    do_stop
    do_start
}

case "$1" in
    start|stop|restart|status)
    do_$1
    ;;
    *)
    echo "用法: $0 { start | stop | restart | status }"
    RETVAL=1
    ;;
esac

exit $RETVAL
