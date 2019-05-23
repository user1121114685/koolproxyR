#!/bin/sh
alias echo_date1='echo $(date +%Y年%m月%d日\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
date=`echo_date1`
version=`dbus get koolproxyR_version`
status=`ps | grep koolproxy | grep -v grep | wc -l`
koolproxyR_installing_version=`dbus get koolproxyR_new_install_version`

if [[ "$status" -ge "1" ]]; then
		http_response " 【$date】 正在运行KoolProxyR <font color='#CDCD00'> $version <font color='#1bbf35'> / 线上最新版本为: <font color='#FF0000'> $koolproxyR_installing_version @@绿坝规则：$rules_date_local / $rules_nu_local条"
else
	http_response "<font color='#FF0000'>【警告】：KoolProxyR未运行！</font> @@<font color='#FF0000'>未加载！</font>"
fi

