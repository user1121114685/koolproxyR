#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxy_`
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

url_koolproxy="https://kprule.com/koolproxy.txt"
url_easylist="https://easylist-downloads.adblockplus.org/easylistchina.txt"
url_abx=""
url_fanboy="https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt"

update_rule(){
	echo =======================================================================================================
	echo_date 开始更新koolproxyR规则，请等待...
	
	# update KP官方规则
	if [ "$koolproxyR_basic_koolproxy_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		wget --no-check-certificate --timeout=8 -qO - $url_koolproxy > /tmp/koolproxy.txt
		rules_date_local=`cat $KSROOT/koolproxyR/data/rules/koolproxy.txt  | sed -n '3p'|awk '{print $3,$4}'`
		rules_date_local1=`cat /tmp/koolproxy.txt  | sed -n '3p'|awk '{print $3,$4}'`
		if [ ! -z "$rules_date_local1" ];then
			if [ "$rules_date_local" != "$rules_date_local1" ];then
				echo_date 检测到新版本 koolproxy规则，开始更新...
				echo_date 将临时文件覆盖到原始koolproxy规则文件
				mv /tmp/koolproxy.txt $KSROOT/koolproxyR/data/rules/koolproxy.txt
			else
				echo_date 检测到koolproxy规则本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date koolproxy规则文件下载失败！
		fi
	fi
	
	
	# update 中国简易列表
	if [ "$koolproxyR_basic_easylist_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		wget --no-check-certificate --timeout=8 -qO - $url_easylist > /tmp/easylistchina.txt
		easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
		easylist_rules_local1=`cat /tmp/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
		if [ ! -z "$easylist_rules_local1" ];then
			if [ "$easylist_rules_local" != "$easylist_rules_local1" ];then
				echo_date 检测到新版本 中国简易规则，开始更新...
				echo_date 将临时文件覆盖到原始 中国简易规则文件
				mv /tmp/easylistchina.txt $KSROOT/koolproxyR/data/rules/easylistchina.txt
			else
				echo_date 检测到 中国简易规则本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date 中国简易规则文件下载失败！
		fi
	fi
	
	# update 乘风规则
	if [ "$koolproxyR_basic_abx_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		wget --no-check-certificate --timeout=8 -qO - $url_abx > /tmp/chengfeng.txt
		abx_rules_local=`cat $KSROOT/koolproxyR/data/rules/chengfeng.txt  | sed -n '3p'|awk '{print $3,$4}'`
		abx_rules_local1=`cat /tmp/chengfeng.txt | sed -n '3p'|awk '{print $3,$4}'`
		if [ ! -z "$abx_rules_local1" ];then
			if [ "$abx_rules_local" != "$abx_rules_local1" ];then
				echo_date 检测到新版本 乘风规则，开始更新...
				echo_date 将临时文件覆盖到原始 乘风规则 文件
				mv /tmp/chengfeng.txt $KSROOT/koolproxyR/data/rules/chengfeng.txt
			else
				echo_date 检测到 乘风规则 本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date 乘风规则文件下载失败！
		fi
	fi

	# update fanboy规则
	if [ "$koolproxyR_basic_fanboy_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		wget --no-check-certificate --timeout=8 -qO - $url_fanboy > /tmp/fanboy-annoyance.txt
		fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
		fanboy_rules_local1=`cat /tmp/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
		if [ ! -z "$fanboy_rules_local1" ];then
			if [ "$fanboy_rules_local" != "$fanboy_rules_local1" ];then
				echo_date 检测到新版本 fanboy规则 列表，开始更新...
				echo_date 将临时文件覆盖到原始 fanboy规则 文件
				mv /tmp/fanboy-annoyance.txt $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
			else
				echo_date 检测到 fanboy规则 本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date fanboy规则 文件下载失败！
		fi
	fi

	rm -rf /fanboy-annoyance.txt
	rm -rf /tmp/chengfeng.txt
	rm -rf /tmp/easylistchina.txt
	rm -rf /tmp/koolproxy.txt
	
	echo_date 所有规则更新完毕！
	# reboot koolproxyR

	echo_date 自动重启koolproxyR，以应用新的规则文件！请稍后！
	sh $KSROOT/koolproxyR/kp_config.sh restart
	echo =======================================================================================================
}
if [ -n "$1" ];then
	update_rule "$1" > /tmp/upload/kp_log.txt
	echo XU6J03M6 >> /tmp/upload/kp_log.txt
	http_response "$1"
else
	update_rule > /tmp/upload/kp_log.txt
	echo XU6J03M6 >> /tmp/upload/kp_log.txt
fi
