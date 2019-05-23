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
rm -rf $KSROOT/libhavege*.ipk
rm -rf $KSROOT/haveged*.ipk

# 取消dbus注册 TG sadog
cd /tmp 
dbus list koolproxyR|cut -d "=" -f1|sed 's/^/dbus remove /g' > clean.sh
dbus list softcenter_module_|grep koolproxyR|cut -d "=" -f1|sed 's/^/dbus remove /g' >> clean.sh
chmod 777 clean.sh 
sh ./clean.sh > /dev/null 2>&1 
rm clean.sh

exit 0
