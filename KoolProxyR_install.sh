#!/bin/sh
export soft_name=koolproxyR.tar.gz
export KSROOT=/koolshare
alias echo_date='echo 【$(date +%Y年%m月%d日\ %X)】:'
source $KSROOT/scripts/base.sh
eval `dbus export soft`
TARGET_DIR=/tmp/upload

clean(){
	rm -rf /tmp/$name >/dev/null 2>&1
	rm -rf /tmp/$MODULE_NAME >/dev/null 2>&1
	rm -rf /tmp/$soft_name >/dev/null 2>&1
	find /tmp -name "*.tar.gz"|xargs rm -rf >/dev/null 2>&1
}

url_version="https://raw.githubusercontent.com/user1121114685/koolproxyR/master/version"
wget --no-check-certificate --timeout=8 -qO - $url_version > /tmp/koolproxyR_version
koolproxyR_installing_md5=`cat /tmp/koolproxyR_version  | sed -n '2p'`
rm -rf /tmp/version
echo_date ==============================================
echo_date koolproxyR 开始下载最新版KPR。
echo_date ===============================================
wget -O /tmp/upload/koolproxyR.tar.gz https://raw.githubusercontent.com/user1121114685/koolproxyR/master/koolproxyR.tar.gz
koolproxyR_download_md5=`md5sum /tmp/upload/koolproxyR.tar.gz|awk '{print $1}'`
echo_date 远程版本md5：$koolproxyR_installing_md5
echo_date 您下载版本md5：$koolproxyR_download_md5
if [ "$koolproxyR_installing_md5" != "$koolproxyR_download_md5" ]; then
    echo_date 一个悲伤的故事，MD5校验不通过，勇士请重新来过吧！
    rm -rf /tmp/upload/koolproxyR.tar.gz
    exit
fi

echo_date ==============================================
echo_date koolproxyR 开始执行安装程序。

name=`echo "$soft_name"|sed 's/.tar.gz//g'|awk -F "_" '{print $1}'|awk -F "-" '{print $1}'`
INSTALL_SUFFIX=_install
VER_SUFFIX=_version
NAME_SUFFIX=_name
cd /tmp
echo_date ====================== step 1 ===========================
echo_date 开启软件在线安装！
sleep 1
if [ -f $TARGET_DIR/$soft_name ];then
    mv /tmp/upload/$soft_name /tmp
    sleep 1
    echo_date 尝试解压在线安装包在线安装包
    sleep 1
    tar -zxvf $soft_name >/dev/null 2>&1
    echo_date 解压完成！
    sleep 1
    cd /tmp
    
    if [ -f /tmp/$name/install.sh ];then
        INSTALL_SCRIPT=/tmp/$name/install.sh
    else
        INSTALL_SCRIPT_NU=`find /tmp -name "install.sh"|wc -l` 2>/dev/null
        [ "$INSTALL_SCRIPT_NU" == "1" ] && INSTALL_SCRIPT=`find /tmp -name "install.sh"` || INSTALL_SCRIPT=""
    fi

    if [ -n "$INSTALL_SCRIPT" -a -f "$INSTALL_SCRIPT" ];then
        SCRIPT_AB_DIR=`dirname $INSTALL_SCRIPT`
        MODULE_NAME=${SCRIPT_AB_DIR##*/}
        echo_date 准备安装$MODULE_NAME插件！
        echo_date 找到安装脚本！
        chmod +x $INSTALL_SCRIPT >/dev/null 2>&1
        echo_date 运行安装脚本...
        echo_date ====================== step 2 ===========================
        sleep 1
        start-stop-daemon -S -q -x $INSTALL_SCRIPT 2>&1
        # sh /tmp/$name/install.sh 2>&1
        if [ "$?" != "0" ];then
        	echo_date 因为$MODULE_NAME插件安装失败！退出在线安装！
        	clean
        	dbus remove "softcenter_module_$MODULE_NAME$INSTALL_SUFFIX"
        	echo_date jobdown
        	exit
        fi
        echo_date ====================== step 3 ===========================
        dbus set "softcenter_module_$MODULE_NAME$NAME_SUFFIX=$MODULE_NAME"
        dbus set "softcenter_module_$MODULE_NAME$INSTALL_SUFFIX=1"
        #dbus set "softcenter_module_$name$VER_SUFFIX=$soft_install_version"
        if [ -n "$soft_install_version" ];then
            dbus set "softcenter_module_$MODULE_NAME$VER_SUFFIX=$soft_install_version"
            echo_date "从插件文件名中获取到了版本号：$soft_install_version"
        else
            #已经在插件安装中设置了
            if [ -z "`dbus get softcenter_module_$MODULE_NAME$VER_SUFFIX`" ];then
                dbus set "softcenter_module_$MODULE_NAME$VER_SUFFIX=0.1"
                echo_date "插件安装脚本里没有找到版本号，设置默认版本号为0.1"
            else
                echo_date "插件安装脚本已经设置了插件版本号为：`dbus get softcenter_module_$MODULE_NAME$VER_SUFFIX`"
            fi
        fi
        install_pid=`ps | grep -w install.sh | grep -v grep | awk '{print $1}'`
        i=120
        until [ -z "$install_pid" ]
        do
            install_pid=`ps | grep -w install.sh | grep -v grep | awk '{print $1}'`
            i=$(($i-1))
            if [ "$i" -lt 1 ];then
                echo_date "Could not load nat rules!"
                echo_date 安装似乎出了点问题，请手动重启路由器后重新尝试...
                echo_date 删除相关文件并退出...
                sleep 1
                clean
                dbus remove "softcenter_module_$MODULE_NAME$INSTALL_SUFFIX"
                echo_date jobdown
                exit
            fi
            sleep 1
        done
        echo_date 安装完成！
        sleep 1
        echo_date 一点点清理工作...
        sleep 1
        clean
        echo_date 完成！在线安装插件成功~
        sleep 1
    else
        echo_date 没有找到安装脚本！
        echo_date 删除相关文件并退出...
        clean
    fi
else
    echo_date 没有找到在线安装包！
    echo_date 删除相关文件并退出...
    clean
fi
sleep 1
dbus remove soft_install_version
dbus remove soft_name
echo_date 
clean

echo_date koolproxyR 已经安装/升级完成，请刷新网页试试
echo_date ===============================================