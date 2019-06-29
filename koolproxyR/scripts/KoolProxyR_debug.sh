#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
SOFT_DIR=/koolshare
KP_DIR=$SOFT_DIR/koolproxyR
eval `dbus export koolproxyR_`
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/kpr_log.txt
echo "" > $LOG_FILE

kill_kpr() {
	echo_date 关闭koolproxyR主进程...
	kill -9 `pidof koolproxy` >/dev/null 2>&1
	killall koolproxy >/dev/null 2>&1
	kpr_status
	dbus set koolproxyR_debug_0=0
}

kpr_status() {
	# kpr运行状态判断
	sleep 1
	status=`ps | grep koolproxy | grep -v grep | wc -l`
	if [[ "$status" == "0" ]]; then
		echo_date koolproxyR主进程已关闭...
	else
		echo_date koolproxyR主进程已启动...
	fi
}

kpr_debug_0() {
	dbus set koolproxyR_debug_0=1
	koolproxyR_debug_0=`dbus get koolproxyR_debug_0`
	while [ $koolproxyR_debug_0 = 1 ];do
		user_txt_md5_new=`md5sum /koolshare/koolproxyR/data/rules/user.txt | cut -d \  -f1`
		if [[ "$user_txt_md5_new" != "$user_txt_md5_old" ]]; then
			echo_date 关闭koolproxyR主进程...
			kill -9 `pidof koolproxy` >/dev/null 2>&1
			killall koolproxy >/dev/null 2>&1
			kpr_status
			cd $KP_DIR && koolproxy -d --ttl 188 --ttlport 3001 --ipv6
			echo_date "检测到user.txt规则已改变，已重启kpr"
			user_txt_md5_old=`md5sum /koolshare/koolproxyR/data/rules/user.txt | cut -d \  -f1`
			kpr_status
		fi
		koolproxyR_debug_0=`dbus get koolproxyR_debug_0`
	done	
}

kpr_debug_1() {
	kill_kpr
	echo_date "kpr   debug-info模式启动"
	koolproxy -l 1 --ttl 188 --ttlport 3001 --ipv6
	echo_date "如果您需要查看https流量，请在【访问控制】中指定【HTTP/HTTPS双过滤模式】"
	kpr_status
}

kpr_debug_2() {
	kill_kpr
	echo_date "kpr   debug-ad模式启动"
	koolproxy -l 2 --ttl 188 --ttlport 3001 --ipv6
	kpr_status
}

kpr_debug_3() {
	kill_kpr
	echo_date "kpr   debug-WARNING模式启动"
	koolproxy -l 3 --ttl 188 --ttlport 3001 --ipv6
	kpr_status
}

kpr_debug_4() {
	kill_kpr
	echo_date "关闭dbug调试"
	cd $KP_DIR && koolproxy -d --ttl 188 --ttlport 3001 --ipv6
	kpr_status
}

# $2 表示传入的第2个参数 例如 debug.sh abc 123  中的123 $1 就是 abc
case $2 in
0)
	kpr_debug_0 >> $LOG_FILE
	http_response "$1"
	;;
1)
	kpr_debug_1 >> $LOG_FILE
	http_response "$1"
	;;
2)
	kpr_debug_2 >> $LOG_FILE
	http_response "$1"
	;;
3)
	kpr_debug_3 >> $LOG_FILE
	http_response "$1"
	;;
4)
	kpr_debug_4 >> $LOG_FILE
	http_response "$1"
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	;;
esac

