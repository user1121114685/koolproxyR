#!/bin/sh
export soft_name=koolproxyR.tar.gz
alias echo_date1='echo $(date +%Y年%m月%d日\ %X)'


update_kpr(){
    echo_date1 ====================== 开始检查更新 ===========================
    url_version="https://raw.githubusercontent.com/user1121114685/koolproxyR/master/version"
    wget --no-check-certificate --timeout=8 -qO - $url_version > /tmp/koolproxyR_version
    koolproxyR_installing_md5=`cat /tmp/koolproxyR_version  | sed -n '2p'`
    koolproxyR_installing_version=`cat /tmp/koolproxyR_version  | sed -n '1p'`
    # koolproxyR_installing_version=`dbus get koolproxyR_new_install_version`
    koolproxyR_version_now=`dbus get koolproxyR_version`
    echo_date1 当前本地版本：$koolproxyR_version_now  ,当前最新版本为: $koolproxyR_installing_version
    rm -rf /tmp/version
    echo_date1 ====================== 判断更新 ===========================
    if [ "$koolproxyR_installing_version" != "$koolproxyR_version_now" ]; then
        echo_date1 检查到与线上版本不一致，开始更新.....
        echo_date1 请耐心等待更新完成.....
        wget -O /koolshare/scripts/kpr_tar_install.sh https://raw.githubusercontent.com/user1121114685/koolproxyR/master/kpr_tar_install.sh && chmod 777 /koolshare/scripts/kpr_tar_install.sh
        wget -O /tmp/upload/koolproxyR.tar.gz https://raw.githubusercontent.com/user1121114685/koolproxyR/master/koolproxyR.tar.gz && sh /koolshare/scripts/kpr_tar_install.sh
    else
        echo_date1 并没有更新，下次再来看吧！
    fi

    echo_date1 ==========================================================
}
if [ -n "$1" ];then
	update_kpr "$1" > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	http_response "$1"
else
	update_kpr > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
fi
