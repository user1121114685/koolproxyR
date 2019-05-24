#!/bin/sh

export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/kpr_log.txt
CA_DIR=/tmp/upload/CA/
echo "" > $LOG_FILE

backup() {
	echo_date "开始备份证书！"
	mkdir -p $KSROOT/webs/files
	
	if [ ! -f $KSROOT/koolproxyR/data/private/ca.key.pem ]; then
		echo_date "证书文件：$KSROOT/koolproxyR/data/private/ca.key.pem 不存在！"
		file_found=0
	fi
	if [ ! -f $KSROOT/koolproxyR/data/private/base.key.pem ]; then
		echo_date "证书文件：$KSROOT/koolproxyR/data/private/base.key.pem 不存在！"
		file_found=0
	fi
	if [ ! -f $KSROOT/koolproxyR/data/certs/ca.crt ]; then
		echo_date "$KSROOT/koolproxyR/data/certs/ca.crt 不存在！"
		file_found=0
	fi

	if [[ "$file_found" == "0" ]]; then
		echo_date "退出备份！"
		echo XU6J03M6
		exit 1
	fi

	cd $KSROOT/koolproxyR/data
	tar czf /tmp/upload/koolproxyca.tar.gz private/ca.key.pem private/base.key.pem certs/ca.crt 
	cp /tmp/upload/koolproxyca.tar.gz $KSROOT/webs/files/koolproxyca.tar.gz	
	echo_date "证书备份完毕"
}

backup_0() {
	echo_date "开始生成  .0 证书！"
	mkdir -p $KSROOT/webs/files

	if [ ! -f $KSROOT/koolproxyR/data/certs/ca.crt ]; then
		echo_date "$KSROOT/koolproxyR/data/certs/ca.crt 不存在！"
		file_found=0
	fi

	if [[ "$file_found" == "0" ]]; then
		echo_date "退出生成 .0 根证书！"
		echo XU6J03M6
		exit 1
	fi
	# 生成证书的hash名字
	ca_0_hash=$(openssl x509 -subject_hash_old -in $KSROOT/koolproxyR/data/certs/ca.crt|head -1).0
	cp $KSROOT/koolproxyR/data/certs/ca.crt $KSROOT/webs/files/$ca_0_hash
	#  生成.0根证书
	openssl x509 -text -in cp $KSROOT/koolproxyR/data/certs/ca.crt -out /dev/null >> $KSROOT/webs/files/$ca_0_hash
	cd $KSROOT/webs/files
	tar czf ca_0.tar.gz $ca_0_hash
	# zip ca_0.zip $ca_0_hash >/dev/null
	echo_date " .0根证书生成成功，名字为  $ca_0_hash"
}

stop_koolproxy(){
	echo_date 关闭koolproxy主进程...
	kill -9 `pidof koolproxy` >/dev/null 2>&1
	killall koolproxy >/dev/null 2>&1
}

restart_koolproxy(){
	
	echo_date 重启koolproxy主进程！
	[ "$koolproxyR_mode" == "3" ] && EXT_ARG="-e" || EXT_ARG=""
	cd $KSROOT/koolproxyR && koolproxyR $EXT_ARG --mark -d
}

restore() {
	if [ -f /tmp/upload/koolproxyCA.tar.gz ]; then
		echo_date "开始恢复证书！"
		mkdir -p $CA_DIR
		cp /tmp/upload/koolproxyCA.tar.gz $CA_DIR
		cd $CA_DIR
		tar xzf $CA_DIR/koolproxyCA.tar.gz
	else
		echo_date "没有找到上传的证书备份文件！退出恢复！"
		echo XU6J03M6
		exit 1
	fi
	
	cp -rf $CA_DIR/* $KSROOT/koolproxyR/data
	rm -rf $CA_DIR
	rm -f /tmp/upload/koolproxyCA.tar.gz
	rm -rf /tmp/upload/koolproxyca.tar.gz
	rm -rf $KSROOT/koolproxyR/data/koolproxyCA.tar.gz

	stop_koolproxy
	sleep 1
	restart_koolproxy
	echo_date "证书恢复成功！"
}

case $2 in
1)
	#备份证书
	backup >> $LOG_FILE
	http_response "$1"
	echo XU6J03M6 >> $LOG_FILE
	sleep 10
	rm -rf /koolshare/webs/files/koolproxyca.tar.gz
	rm -rf /tmp/upload/koolproxyca.tar.gz
	;;
2)
	#恢复证书
	restore >> $LOG_FILE
	$KSROOT/koolproxyR/kpr_config.sh restart
	http_response "$1"
	echo XU6J03M6 >> $LOG_FILE
	;;
3)
	#生成.0根证书
	backup_0 >> $LOG_FILE
	http_response "$1"
	echo XU6J03M6 >> $LOG_FILE
	sleep 10
	rm -rf $KSROOT/webs/files/$ca_0_hash
	rm -rf $KSROOT/webs/files/ca_0.tar.gz
	;;
esac

