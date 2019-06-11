#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

mydiy(){
	echo_date =======================================================================================================
	echo_date 开始应用自定义修改，请等待...
	# 请在以下地区填入自定义shell命令，因为此功能面向高端用户，需要一定shell基础。切勿瞎折腾.
	# 可以修改N多东西，包括不限于规则....此DIY会在你每次保存时候应用
	# 请在其他地方保留备份.
	# 请采用utf-8格式LF格式编码
	# 你可以通过【系统】----【文件管理】上传删除文件
	# 如果出现问题，请使用如下命令删除文件
	# rm -rf /koolshare/scripts/KoolProxyR_my_rule_diy.sh
	# 运行命令 sh /koolshare/scripts/KoolProxyR_my_rule_diy.sh mydiy
		



	echo_date 自定义修改完成.....
	echo_date =======================================================================================================
}

if [ -n "$1" ]; then
	mydiy "$1" > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	http_response "$1"

else
	mydiy > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
fi
