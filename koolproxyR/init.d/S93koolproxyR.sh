#!/bin/sh /etc/rc.common
#
# Copyright (C) 2015 OpenWrt-dist
# Copyright (C) 2016 fw867 <ffkykzs@gmail.com>
# Copyright (C) 2016 sadog <sadoneli@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

START=93
STOP=15

source /koolshare/scripts/base.sh
eval `dbus export koolproxyR_`


start(){
	[ ! -L "/tmp/upload/user.txt" ] && ln -sf $KSROOT/koolproxyR/data/user.txt /tmp/upload/user.txt
	[[ "$koolproxyR_enable" == "1" ]] && sh /koolshare/koolproxyR/kpr_config.sh restart >> /tmp/upload/kpr_log.txt

	entropy_avail=`opkg list-installed |grep -i "haveged"`
	if [[ "$entropy_avail" == "" ]]; then
	# 离线安装包下载地址 https://downloads.openwrt.org/releases/packages-18.06/x86_64/packages/
		opkg install /koolshare/libhavege_1.9.4-1_x86_64.ipk
		sleep 1
		opkg install /koolshare/haveged_1.9.4-1_x86_64.ipk
	fi
}

stop(){
	sh /koolshare/koolproxyR/kpr_config.sh stop >> /tmp/upload/kpr_log.txt
}