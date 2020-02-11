#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
# mkdir -p /tmp/upload

# 判断路由架构和平台
case $(uname -m) in
	armv7l)
		echo_date 本KoolProxyR插件用于koolshare OpenWRT/LEDE x86_64固件平台，arm平台不能安装！！！
		echo_date 退出KoolProxyR安装！
		exit 1
	;;
	mips)
		echo_date 本KoolProxyR插件用于koolshare OpenWRT/LEDE x86_64固件平台，mips平台不能安装！！！
		echo_date 退出KoolProxyR安装！
		exit 1
	;;
	x86_64)
		fw867=`cat /etc/banner|grep fw867`
		if [ -d "/koolshare" ] && [ -n "$fw867" ]; then
			echo_date 固件平台【koolshare OpenWRT/LEDE x86_64】符合安装要求，开始安装插件！
		else
			echo_date 本KoolProxyR插件用于koolshare OpenWRT/LEDE x86_64固件平台，其它x86_64固件平台不能安装！！！
			echo_date 退出KoolProxyR安装！
			exit 1
		fi
	;;
  *)
		echo_date 本KoolProxyR插件用于koolshare OpenWRT/LEDE x86_64固件平台，其它平台不能安装！！！
  		echo_date 退出KoolProxyR安装！
		exit 1
	;;
esac
# 感谢这位大佬的教程。
# https://www.linuxquestions.org/questions/debian-26/debian-hangs-at-boot-with-random-crng-init-done-4175613405/#post5889997
# 此举解决了kpr与v2ray冲突，与SS冲突，导致开机过慢的问题
# haveged 项目的目的是提供一个易用、不可预测的随机数生成器，基于 HAVEGE 算法。

# entropy_avail=`cat /proc/sys/kernel/random/entropy_avail`
entropy_avail=`opkg list-installed |grep -i "haveged"`


if [[ "$entropy_avail" == "" ]]; then
 # 离线安装包下载地址 https://downloads.openwrt.org/releases/packages-18.06/x86_64/packages/
 	echo_date 开始安装haveged,解决ss,v2ray冲突导致开机变慢的问题。
	opkg install /tmp/koolproxyR/variable/libhavege.ipk
	sleep 1
	opkg install /tmp/koolproxyR/variable/haveged.ipk
	entropy_avail1=`opkg list-installed |grep -i "haveged"`
	if [[ "$entropy_avail1" == "" ]]; then
		echo_date 离线安装haveged失败,正在尝试在线安装！
		opkg update && opkg install haveged
		entropy_avail2=`opkg list-installed |grep -i "haveged"`
		if [[ "$entropy_avail2" == "" ]]; then
			echo_date 离线,在线安装haveged失败请手动尝试，在ssh中执行如下命令，否则无法解决开机变慢的问题。
			echo_date opkg update && opkg install haveged
		fi
	fi
else
	echo_date 你已安装haveged，不用担心与ss,v2ray冲突导致开机变慢的问题。
fi
# stop first
KP_ENBALE=`dbus get koolproxy_enable`
koolproxyR_enable=`dbus get koolproxyR_enable`

if [[ "$KP_ENBALE" == "1" ]]; then
	if [ -f "$KSROOT/koolproxy/kp_config.sh" ]; then
		sh $KSROOT/koolproxy/kp_config.sh stop >> /tmp/upload/kpr_log.txt
	fi
fi
# 删除KP的二进制和核心配置文件。保留其他所有配置，避免小白两个都安装导致一些莫名其妙的问题。
rm -rf $KSROOT/koolproxy/kp_config.sh >/dev/null 2>&1
rm -rf $KSROOT/koolproxy/koolproxy >/dev/null 2>&1
# 暂时关闭kpr进程。进行更新
if [[ "$koolproxyR_enable" == "1" ]]; then
	echo_date 关闭koolproxyR主进程...
	kill -9 `pidof koolproxy` >/dev/null 2>&1
	killall koolproxy >/dev/null 2>&1
fi
# remove old files
echo_date 移除koolproxyR旧文件...

rm -rf $KSROOT/bin/koolproxy >/dev/null 2>&1
# 自定义shell 移动，避免安装丢失
if [ -f /koolshare/scripts/KoolProxyR_my_rule_diy.sh ]; then
	mv /koolshare/scripts/KoolProxyR_my_rule_diy.sh /tmp/KoolProxyR_my_rule_diy.sh.tmp
fi
rm -rf $KSROOT/scripts/KoolProxyR_* >/dev/null 2>&1
rm -rf $KSROOT/webs/Module_koolproxyR.asp >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/koolproxy >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/*.sh >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/gen_ca.sh >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/source.list >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/koolproxyR_ipset.conf >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/openssl.cnf >/dev/null 2>&1
rm -rf $KSROOT/koolproxyR/data/rules >/dev/null 2>&1
# 移动 自定义规则
if [ -f "$KSROOT/koolproxyR/data/rules/user.txt" ]; then
	mv $KSROOT/koolproxyR/data/rules/user.txt /tmp/user.txt.tmp
fi
rm -rf $KSROOT/koolproxyR/data/rules/* >/dev/null 2>&1

# copy new files
echo_date 复制koolproxyR新文件...
cd /tmp
mkdir -p $KSROOT/koolproxyR
mkdir -p $KSROOT/init.d
mkdir -p $KSROOT/koolproxyR/data
cp -rf /tmp/koolproxyR/scripts/* $KSROOT/scripts/
cp -rf /tmp/koolproxyR/webs/* $KSROOT/webs/
cp -rf /tmp/koolproxyR/init.d/* $KSROOT/init.d/
# 自定义规则 判断
if [ -f "/tmp/user.txt.tmp" ]; then
	cp -rf /tmp/koolproxyR/* $KSROOT/
	rm -rf $KSROOT/koolproxyR/data/rules/user.txt
	mv /tmp/user.txt.tmp $KSROOT/koolproxyR/data/rules/user.txt
else
	cp -rf /tmp/koolproxyR/* $KSROOT/	
fi
# 自定义shell 移动，避免安装丢失
if [ -f /tmp/KoolProxyR_my_rule_diy.sh.tmp ]; then
	mv /tmp/KoolProxyR_my_rule_diy.sh.tmp /koolshare/scripts/KoolProxyR_my_rule_diy.sh
fi

cp -f /tmp/koolproxyR/uninstall.sh $KSROOT/scripts/uninstall_koolproxyR.sh
rm -rf $KSROOT/install.sh
rm -rf $KSROOT/uninstall.sh
# rm -rf $KSROOT/libhavege*.ipk
# rm -rf $KSROOT/haveged*.ipk
[ ! -L "/tmp/upload/user.txt" ] && ln -sf $KSROOT/koolproxyR/data/rules/user.txt /tmp/upload/user.txt

echo_date 赋予koolproxyR文件权限...

cd /
chmod 755 $KSROOT/koolproxyR/*
chmod 755 $KSROOT/koolproxyR/data/*
chmod 755 $KSROOT/scripts/*
chmod 755 $KSROOT/init.d/*
ln -sf  $KSROOT/koolproxyR/koolproxy  $KSROOT/bin/koolproxy

# remove install tar
echo_date 移除koolproxyR安装残留...
rm -rf /tmp/koolproxy* >/dev/null 2>&1

# remove old files if exist
echo_date koolproxyR后续处理...
find /etc/rc.d/ -name *koolproxyR.sh* | xargs rm -rf
[ ! -L "/etc/rc.d/S93koolproxyR.sh" ] && ln -sf $KSROOT/init.d/S93koolproxyR.sh /etc/rc.d/S93koolproxyR.sh

[ -z "$koolproxyR_mode" ] && dbus set koolproxyR_mode="1"
[ -z "$koolproxyR_acl_default" ] && dbus set koolproxyR_acl_default="1"
[ -z "$koolproxyR_acl_list" ] && dbus set koolproxyR_acl_list=" "
[ -z "$koolproxyR_arp" ] && dbus set koolproxyR_arp=" "

# add icon into softerware center
# 酷软 插件首行
dbus set softcenter_module_koolproxyR_title="KoolProxyR"
# 酷软 插件次行
dbus set softcenter_module_koolproxyR_description="至   善   至   美"
dbus set softcenter_module_koolproxyR_install=1
dbus set softcenter_module_koolproxyR_home_url="Module_koolproxyR.asp"
dbus set softcenter_module_koolproxyR_name=koolproxyR
dbus set softcenter_module_koolproxyR_version=2.2.7
dbus set koolproxyR_version=2.2.7

echo_date 安装koolproxyR完成，开始重启koolproxyR...

[[ "$koolproxyR_enable" == "1" ]] && sh $KSROOT/koolproxyR/kpr_config.sh restart
echo_date koolproxyR重启完成...

# 首次安装/更新之后进行一次规则升级。避免规则过久。
# sh /koolshare/scripts/KoolProxyR_rule_update.sh update

# 修复离线安装失败的问题 TG sadog
exit 0