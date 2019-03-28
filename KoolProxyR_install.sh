#!/bin/sh
export soft_name=koolproxyR.tar.gz
echo ==============================================
echo koolproxyR 开始安装，请耐心等待安装完成。
echo ===============================================
wget -O /koolshare/scripts/ks_tar_install.sh https://raw.githubusercontent.com/user1121114685/koolproxyR/master/ks_tar_install.sh && chmod 777 /koolshare/scripts/ks_tar_install.sh
wget -O /tmp/upload/koolproxyR.tar.gz https://raw.githubusercontent.com/user1121114685/koolproxyR/master/koolproxyR.tar.gz && sh /koolshare/scripts/ks_tar_install.sh
export KSROOT=/koolshare

echo ===============================================
echo koolproxyR 已经安装/升级完成，请刷新网页试试
echo ===============================================