#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh

sh $KSROOT/koolproxyR/kpr_config.sh stop
rm -rf $KSROOT/bin/koolproxy >/dev/null 2>&1
rm -rf $KSROOT/scripts/KoolProxyR_* >/dev/null 2>&1
rm -rf $KSROOT/scripts/KoolproxyR_* >/dev/null 2>&1
rm -rf $KSROOT/webs/module_KoolproxyR.asp >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR >/dev/null 2>&1
rm -rf $KSROOT/init.d/S93koolproxyR.sh >/dev/null 2>&1
rm -rf /etc/rc.d/S93koolproxyR.sh >/dev/null 2>&1
# 取消dbus注册
dbus remove koolproxyR_enable
dbus remove koolproxy_enable
