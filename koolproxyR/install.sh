#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxy_`
# mkdir -p /tmp/upload

# stop first
[ "$koolproxy_enable" == "1" ] && sh $KSROOT/koolproxyR/kp_config.sh stop

# remove old files
rm -rf $KSROOT/bin/koolproxy >/dev/null 2>&1
rm -rf $KSROOT/res/icon-koolproxy.png >/dev/null 2>&1
rm -rf $KSROOT/scripts/KoolproxyR_* >/dev/null 2>&1
rm -rf $KSROOT/webs/module_Koolproxy.asp >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/koolproxy >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/*.sh >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/gen_ca.sh >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/koolproxy_ipset.conf >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/openssl.cnf >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/version >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/rules/* >/dev/null 2>&1

# copy new files
cd /tmp
mkdir -p $KSROOT/koolproxyR
mkdir -p $KSROOT/init.d
mkdir -p $KSROOT/koolproxyR/data
cp -rf /tmp/koolproxyR/scripts/* $KSROOT/scripts/
cp -rf /tmp/koolproxyR/webs/* $KSROOT/webs/
cp -rf /tmp/koolproxyR/init.d/* $KSROOT/init.d/
if [ ! -f $KSROOT/koolproxyR/data/rules/user.txt ];then
	cp -rf /tmp/koolproxyR/* $KSROOT/
else
	mv $KSROOT/koolproxyR/data/rules/user.txt /tmp/user.txt.tmp
	cp -rf /tmp/koolproxyR/* $KSROOT/
	mv /tmp/user.txt.tmp $KSROOT/koolproxyR/data/rules/user.txt
fi
cp -f /tmp/koolproxyR/uninstall.sh $KSROOT/scripts/uninstall_koolproxyR.sh
rm -rf $KSROOT/install.sh
rm -rf $KSROOT/uninstall.sh

[ ! -L "/tmp/upload/user.txt" ] && ln -sf $KSROOT/koolproxyR/data/rules/user.txt /tmp/upload/user.txt

cd /
chmod 755 $KSROOT/koolproxyR/*
chmod 755 $KSROOT/koolproxyR/data/*
chmod 755 $KSROOT/scripts/*
chmod 755 $KSROOT/init.d/*
ln -sf  $KSROOT/koolproxyR/koolproxy  $KSROOT/bin/koolproxy

# remove install tar
rm -rf /tmp/koolproxy* >/dev/null 2>&1

# remove old files if exist
find /etc/rc.d/ -name *koolproxy.sh* | xargs rm -rf
[ ! -L "/etc/rc.d/S93koolproxy.sh" ] && ln -sf $KSROOT/init.d/S93koolproxy.sh /etc/rc.d/S93koolproxy.sh

[ -z "$koolproxy_mode" ] && dbus set koolproxy_mode="1"
[ -z "$koolproxy_acl_default" ] && dbus set koolproxy_acl_default="1"
[ -z "$koolproxy_acl_list" ] && dbus set koolproxy_acl_list=" "
[ -z "$koolproxy_arp" ] && dbus set koolproxy_arp=" "

# add icon into softerware center
dbus set softcenter_module_koolproxyR_description="KP自定义规则最舒服！"
dbus set softcenter_module_koolproxyR_install=1
dbus set softcenter_module_koolproxyR_home_url="Module_koolproxyR.asp"
dbus set softcenter_module_koolproxyR_name=koolproxyR
dbus set softcenter_module_koolproxyR_version=900.8.5
dbus set koolproxyR_version=900.8.5

[ "$koolproxy_enable" == "1" ] && sh $KSROOT/koolproxyR/kp_config.sh restart
