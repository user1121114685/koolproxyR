#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`

version=`dbus get koolproxyR_version`
status=`ps | grep koolproxy | grep -v grep | wc -l`
url_version="https://raw.githubusercontent.com/user1121114685/koolproxyR/master/version"
wget --no-check-certificate --timeout=8 -qO - $url_version > /tmp/version
koolproxyR_installing_version=`cat /tmp/version  | sed -n '1p'`
rm -rf /tmp/version
rules_date_local=`cat $KSROOT/koolproxyR/data/rules/koolproxy.txt  | sed -n '3p'|awk '{print $3,$4}'`
rules_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/koolproxy.txt | wc -l`

if [ "$status" -ge "1" ]; then
	if [ "$koolproxyR_oline_rules" == "1" ]; then
		http_response " 正在运行KoolProxyR <font color='#CDCD00'> $version <font color='#1bbf35'> / 线上最新版本为: <font color='#FF0000'> $koolproxyR_installing_version @@绿坝规则：$rules_date_local / $rules_nu_local条"
	else
		http_response " 正在运行KoolProxyR <font color='#CDCD00'> $version <font color='#1bbf35'> / 线上最新版本为: <font color='#FF0000'> $koolproxyR_installing_version  @@<font color='#FF0000'>未加载！</font>"	
	fi
else
	http_response "<font color='#FF0000'>【警告】：进程未运行！</font> @@<font color='#FF0000'>未加载！</font>"
fi

