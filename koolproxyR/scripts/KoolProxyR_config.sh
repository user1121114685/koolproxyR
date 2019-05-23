#!/bin/sh

alias echo_date1='echo $(date +%Y年%m月%d日\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`

echo "" > /tmp/upload/kpr_log.txt
sleep 1
case $2 in
restart)
	if [[ "$koolproxyR_enable" == "1" ]]; then
		sh /koolshare/koolproxyR/kpr_config.sh restart >> /tmp/upload/kpr_log.txt 2>&1
	else
		sh /koolshare/koolproxyR/kpr_config.sh stop >> /tmp/upload/kpr_log.txt 2>&1
	fi
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	http_response "$1"
	;;
esac