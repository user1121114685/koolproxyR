#!/bin/sh

alias echo_date1='echo $(date +%Y年%m月%d日\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`

version=`koolproxy -v`
status=`ps|grep -w koolproxy | grep -cv grep`
date=`echo_date1`
pid=`pidof koolproxy`


if [[ "$koolproxyR_easylist_rules" == "1" ]]; then
	easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
fi
if [[ "$koolproxyR_easylist_rules" == "2" -o "$koolproxyR_easylist_rules" == "3" ]]; then
	easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/koolproxy.txt | sed -n '3p'|awk '{print $3,$4}'`
fi
easylist_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/easylistchina.txt | wc -l`
# 补充规则版本号暂时没有
replenish_rules_local=`cat $KSROOT/koolproxyR/data/rules/yhosts.txt  | sed -n '2p' | cut -d "=" -f2`
replenish_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/yhosts.txt | wc -l`
fanboy_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | wc -l`
# 检测是否开启fanboy 全规则版本
if [ "$koolproxyR_fanboy_rules" == "2" ]; then
	fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '4p'|awk '{print $3,$4}'`

	
fi
# 加载普通fanboy规则
if [ "$koolproxyR_fanboy_rules" != "3" ]; then
	

	fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
fi
# 从此由kpr自己更新视频规则
video_rules_local=`cat $KSROOT/koolproxyR/data/rules/kp.dat.md5 | sed -n '2p'`
# video_nu_local=`cat $KSROOT/koolproxyR/data/rules/kp.dat.md5 | sed -n '3p'`

if [ "$koolproxyR_enable" == "1" ]; then
	if [ "$koolproxyR_easylist_rules" != "4" -o "$koolproxyR_video_rules" == "1" -o "$koolproxyR_replenish_rules" == "1" -o "$koolproxyR_fanboy_rules" != "3" ]; then
		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_replenish_rules" == "1" -a "$koolproxyR_video_rules" == "1" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则版本号：$video_rules_local &nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0
		fi
		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_replenish_rules" == "1" -a "$koolproxyR_video_rules" == "1" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则版本号：$video_rules_local &nbsp;&nbsp;&nbsp;&nbsp;"
			return 0
		fi
		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_replenish_rules" == "1" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0
		fi
		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_video_rules" == "1" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则版本号：$video_rules_local &nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0
		fi
		if [ "$koolproxyR_replenish_rules" == "1" -a "$koolproxyR_video_rules" == "1" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则版本号：$video_rules_local &nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0
		fi

		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_replenish_rules" == "1" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条"
			return 0
		fi
		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_video_rules" == "1" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则版本号：$video_rules_local "
			return 0
		fi
		if [ "$koolproxyR_replenish_rules" == "1" -a "$koolproxyR_video_rules" == "1" ]; then
			http_response "补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;视频规则版本号：$video_rules_local "
			return 0
		fi
		if [ "$koolproxyR_replenish_rules" == "1" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0
		fi

		if [ "$koolproxyR_easylist_rules" != "4" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0		
		fi
		if [ "$koolproxyR_video_rules" == "1" -a "$koolproxyR_fanboy_rules" != "3" ]; then
			http_response "视频规则已加载&nbsp;&nbsp;&nbsp;&nbsp;Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
			return 0		
		fi	
		[ "$koolproxyR_replenish_rules" == "1" ] && http_response "补充规则版本号：$replenish_rules_local /合计 $replenish_nu_local条"
		[ "$koolproxyR_easylist_rules" != "4" ] && http_response "主规则版本号：$easylist_rules_local /合计 $easylist_nu_local条"
		[ "$koolproxyR_video_rules" == "1" ] && http_response "视频规则已加载"
		[ "$koolproxyR_fanboy_rules" != "3" ] && http_response "Fanboy规则版本号：$fanboy_rules_local /合计 $fanboy_nu_local条"
	else
		http_response "<font color='#FF0000'>未加载！</font>"
	fi
else
	http_response "<font color='#FF0000'>KoolProxyR未开启....</font>"
fi


