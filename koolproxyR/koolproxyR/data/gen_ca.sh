#!/bin/sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
KPR_DIY_CA=`dbus get koolproxy_diy_ca`
# 本功能作为隐藏功能，使用dbus set koolproxy_diy_ca=xxxxyyyzzz
# cd /koolshare/koolproxyR/data && sh gen_ca.sh
if [ ! -f openssl.cnf ]; then
	echo_date "没有找到 openssl.cnf"
	exit 1
fi
if [ "$KPR_DIY_CA" != "" ]; then
	echo_date "生成自定义证书中..."
	rm -rf /koolshare/koolproxyR/data/private/*.pem
	rm -rf /koolshare/koolproxyR/data/certs/ca.crt
	#step 1, root ca
	mkdir -p certs private
	rm -f serial private/ca.key.pem
	chmod 700 private
	echo 1000 > serial
	openssl genrsa -aes256 -passout pass:koolshare -out private/ca.key.pem 2048
	chmod 400 private/ca.key.pem
	openssl req -config openssl.cnf -passin pass:koolshare \
		-subj "/C=CN/ST=Beijing/L=KPR/O=KoolProxyR/CN=$KPR_DIY_CA" \
		-key private/ca.key.pem \
		-new -x509 -days 7300 -sha256 -extensions v3_ca \
		-out certs/ca.crt

	#step 2, domain rsa key
	openssl genrsa -aes256 -passout pass:koolshare -out private/base.key.pem 2048
	# 生成完毕，移除dbus 避免重复生成
	dbus remove koolproxy_diy_ca
	echo_date "自定义证书生成完毕..."
	koolproxyR_enable=`dbus get koolproxyR_enable`
	[ "$koolproxyR_enable" == "1" ] && sh /koolshare/koolproxyR/kpr_config.sh restart
	echo_date "重新给设备安装证书，体验惊喜吧！"
fi

if [ -f /koolshare/koolproxyR/data/private/ca.key.pem ]; then
	echo_date "已经有证书了！"
else
	echo_date "生成证书中..."

	#step 1, root ca
	mkdir -p certs private
	rm -f serial private/ca.key.pem
	chmod 700 private
	echo 1000 > serial
	openssl genrsa -aes256 -passout pass:koolshare -out private/ca.key.pem 2048
	chmod 400 private/ca.key.pem
	openssl req -config openssl.cnf -passin pass:koolshare \
		-subj "/C=CN/ST=Beijing/L=KP/O=KoolProxy inc/CN=koolproxy.com" \
		-key private/ca.key.pem \
		-new -x509 -days 7300 -sha256 -extensions v3_ca \
		-out certs/ca.crt

	#step 2, domain rsa key
	openssl genrsa -aes256 -passout pass:koolshare -out private/base.key.pem 2048
	echo_date "证书生成完毕..."
fi
