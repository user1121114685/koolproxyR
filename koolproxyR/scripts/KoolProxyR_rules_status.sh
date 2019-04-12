#!/bin/sh

alias echo_date1='echo $(date +%Y年%m月%d日\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`

version=`koolproxy -v`
status=`ps|grep -w koolproxy | grep -cv grep`
date=`echo_date1`
pid=`pidof koolproxy`

easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/ChinaList2.0.txt  | sed -n '2p'|awk '{print $3,$4}'`
easylist_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/ChinaList2.0.txt | wc -l`
# abx_rules_local=`cat $KSROOT/koolproxyR/data/rules/chengfeng.txt  | sed -n '3p'|awk '{print $3,$4}'`
# abx_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/chengfeng.txt | wc -l`
fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
fanboy_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | wc -l`
# video_rules_local=`cat $KSROOT/koolproxyR/data/rules/koolproxy.txt  | sed -n '4p'|awk '{print $3,$4}'`
# 这点我当初都有疑问，今天终于揭开了。
if [ "$koolproxyR_easylist_rules" == "1" -o "$koolproxyR_abx_rules" == "1" -o "$koolproxyR_fanboy_rules" == "1" ]; then
	if [ "$koolproxyR_easylist_rules" == "1" -a "$koolproxyR_abx_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
		http_response "中国规则V2.0：$easylist_rules_local / $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则已经加载&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
		return 0
	fi
	# if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_easylist_rules" == "1" -a "$koolproxyR_abx_rules" == "1" ]; then
	# 	http_response "视频规则：$video_rules_local&nbsp;&nbsp;&nbsp;&nbsp;中国规则V2.0：$easylist_rules_local / $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;乘风规则：$abx_rules_local / $abx_nu_local条"
	# 	return 0		
	# fi
	# if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_easylist_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
	# 	http_response "视频规则：$video_rules_local&nbsp;&nbsp;&nbsp;&nbsp;中国规则V2.0：$easylist_rules_local / $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
	# 	return 0		
	# fi
	# if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_abx_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
	# 	http_response "视频规则：$video_rules_local&nbsp;&nbsp;&nbsp;&nbsp;乘风规则：$abx_rules_local / $abx_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
	# 	return 0		
	# fi	
	# if [ "$koolproxyR_easylist_rules" == "1" -a "$koolproxyR_abx_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
	# 	http_response "中国规则V2.0：$easylist_rules_local / $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;乘风规则：$abx_rules_local / $abx_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
	# 	return 0		
	# fi
	# if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_easylist_rules" == "1" ]; then
	# 	http_response "视频规则：$video_rules_local&nbsp;&nbsp;&nbsp;&nbsp;中国规则V2.0：$easylist_rules_local / $easylist_nu_local条"
	# 	return 0		
	# fi
	# if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_abx_rules" == "1" ]; then
	# 	http_response "视频规则：$video_rules_local&nbsp;&nbsp;&nbsp;&nbsp;乘风规则：$abx_rules_local / $abx_nu_local条"
	# 	return 0
	# fi
	# if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
	# 	http_response "视频规则：$video_rules_local&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
	# 	return 0
	# fi
	if [ "$koolproxyR_easylist_rules" == "1" -a "$koolproxyR_abx_rules" == "1" ]; then
		http_response "中国规则V2.0：$easylist_rules_local / $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则已加载"
		return 0		
	fi
	if [ "$koolproxyR_easylist_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
		http_response "中国规则V2.0：$easylist_rules_local / $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
		return 0		
	fi
	if [ "$koolproxyR_abx_rules" == "1" -a "$koolproxyR_fanboy_rules" == "1" ]; then
		http_response "视频规则已加载&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
		return 0		
	fi	
	# [ "$koolproxyR_video_rules" == "1" ] && http_response "视频规则：$video_rules_local"
	[ "$koolproxyR_easylist_rules" == "1" ] && http_response "中国规则V2.0：$easylist_rules_local / $easylist_nu_local条"
	[ "$koolproxyR_abx_rules" == "1" ] && http_response "视频规则已加载"
	[ "$koolproxyR_fanboy_rules" == "1" ] && http_response "Fanboy规则：$fanboy_rules_local / $fanboy_nu_local条"
else
	http_response "<font color='#FF0000'>未加载！</font>"
fi


