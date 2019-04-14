#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

url_cjx="https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt"
url_kp="https://kprules.b0.upaiyun.com/kp.dat"
# url_koolproxy="https://kprules.b0.upaiyun.com/koolproxy.txt"
# 原网址跳转到https://kprule.com/koolproxy.txt跳转到又拍云，为了节省时间，还是直接去又拍云下载吧！避免某些时候跳转不过去
url_easylist="https://easylist-downloads.adblockplus.org/easylistchina.txt"
url_mobile="https://filters.adtidy.org/extension/chromium/filters/11.txt"
url_fanboy="https://secure.fanboy.co.nz/fanboy-annoyance.txt"

update_rule(){
	echo =======================================================================================================
	echo_date 开始更新koolproxyR规则，请等待...
	
	# update KP官方规则 以后此规则都不需要更新了
	# if [ "$koolproxyR_basic_koolproxyR_update" == "1" ] || [ -n "$1" ];then
	# 	echo_date " ---------------------------------------------------------------------------------------"
	# 	wget --no-check-certificate --timeout=8 -qO - $url_koolproxy > /tmp/koolproxy.txt
	# 	rules_date_local=`cat $KSROOT/koolproxyR/data/rules/koolproxy.txt  | sed -n '3p'|awk '{print $3,$4}'`
	# 	rules_date_local1=`cat /tmp/koolproxy.txt  | sed -n '3p'|awk '{print $3,$4}'`
	# 	if [ ! -z "$rules_date_local1" ];then
	# 		if [ "$rules_date_local" != "$rules_date_local1" ];then
	# 			echo_date 检测到新版本 koolproxy规则，开始更新...
	# 			echo_date 将临时文件覆盖到原始koolproxy规则文件
	# 			mv /tmp/koolproxy.txt $KSROOT/koolproxyR/data/rules/koolproxy.txt
	# 			wget --no-check-certificate --timeout=8 -qO - $url_daily > $KSROOT/koolproxyR/data/rules/daily.txt
	# 			wget --no-check-certificate --timeout=8 -qO - $url_kp > $KSROOT/koolproxyR/data/rules/kp.dat
	# 		else
	# 			echo_date 检测到koolproxy规则本地版本号和在线版本号相同，那还更新个毛啊!
	# 		fi
	# 	else
	# 		echo_date koolproxy规则文件下载失败！
	# 	fi
	# fi
	
	
	# update 中国简易列表 2.0
	if [ "$koolproxyR_basic_easylist_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		# wget --no-check-certificate --timeout=8 -qO - $url_easylist > /tmp/easylistchina.txt
		wget -a /tmp/upload/kpr_log.txt -O /tmp/easylistchina.txt $url_easylist
		wget -a /tmp/upload/kpr_log.txt -O /tmp/cjx-annoyance.txt $url_cjx
		cat /tmp/cjx-annoyance.txt >> /tmp/easylistchina.txt
		rm /tmp/cjx-annoyance.txt
		easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
		easylist_rules_local1=`cat /tmp/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`

		echo_date KPR主规则 本地版本号： $easylist_rules_local
		echo_date KPR主规则 在线版本号： $easylist_rules_local1
		if [ ! -z "$easylist_rules_local1" ];then
			if [ "$easylist_rules_local" != "$easylist_rules_local1" ];then
				echo_date 检测到新版本 KPR主规则 ，开始更新...
				echo_date 将临时文件覆盖到原始 KPR主规则文件
				mv /tmp/easylistchina.txt $KSROOT/koolproxyR/data/rules/easylistchina.txt
				koolproxyR_https_ChinaList=1
			else
				echo_date 检测到 KPR主规则本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date KPR主规则文件下载失败！
		fi
	fi
	
		# update 移动设备规则
	if [ "$koolproxyR_basic_video_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		wget -a /tmp/upload/kpr_log.txt -O /tmp/mobile.txt $url_mobile
		mobile_rules_local=`cat $KSROOT/koolproxyR/data/rules/mobile.txt  | sed -n '4p'|awk '{print $3,$4}'`
		mobile_rules_local1=`cat /tmp/mobile.txt | sed -n '4p'|awk '{print $3,$4}'`
		echo_date 移动设备规则本地版本号： $mobile_rules_local
		echo_date 移动设备规则在线版本号： $mobile_rules_local1
		if [ ! -z "$mobile_rules_local1" ];then
			if [ "$mobile_rules_local" != "$mobile_rules_local1" ];then
				echo_date 检测到新版本 移动设备规则，开始更新...
				echo_date 将临时文件覆盖到原始 移动设备规则 文件
				mv /tmp/mobile.txt $KSROOT/koolproxyR/data/rules/mobile.txt
				koolproxyR_https_mobile=1
			else
				echo_date 检测到 移动设备规则 本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date 移动设备规则文件下载失败！
		fi
	fi

	# update 视频规则
	if [ "$koolproxyR_basic_video_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		echo_date 加密视频规则kp.dat 看不到版本号。所以强制更新。！
		wget -a /tmp/upload/kpr_log.txt -O $KSROOT/koolproxyR/data/rules/kp.dat $url_kp
		echo_date  视频规则已经更新。

	fi

	# update fanboy规则
	if [ "$koolproxyR_basic_fanboy_update" == "1" ] || [ -n "$1" ];then
		echo_date " ---------------------------------------------------------------------------------------"
		wget -a /tmp/upload/kpr_log.txt -O /tmp/fanboy-annoyance.txt $url_fanboy
		# wget --no-check-certificate --timeout=8 -qO - $url_fanboy > /tmp/fanboy-annoyance.txt
		fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
		fanboy_rules_local1=`cat /tmp/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
		echo_date fanboy规则本地版本号： $fanboy_rules_local
		echo_date fanboy规则在线版本号： $fanboy_rules_local1
		if [ ! -z "$fanboy_rules_local1" ];then
			if [ "$fanboy_rules_local" != "$fanboy_rules_local1" ];then
				echo_date 检测到新版本 fanboy规则 列表，开始更新...
				echo_date 将临时文件覆盖到原始 fanboy规则 文件
				mv /tmp/fanboy-annoyance.txt $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
				koolproxyR_https_fanboy=1
			else
				echo_date 检测到 fanboy规则 本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		else
			echo_date fanboy规则 文件下载失败！
		fi
	fi

	rm -rf /fanboy-annoyance.txt
	rm -rf /tmp/mobile.txt
	rm -rf /tmp/easylistchina.txt

	echo_date 正在优化kpr规则。。。。。
	if [ "$koolproxyR_https_fanboy" == "1" ];then
		# 删除导致KP崩溃的规则
		# 听说高手?都打的很多、这样才能体现技术
		sed -i '/^\$/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/\*\$/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/iqiyi.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/v.qq.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/g.alicdn.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/tudou.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/gtimg.cn/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/l.qq.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt


		# 将白名单转化成https
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep "^@@||" | sed 's#^@@||#@@@||https://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep "^@@||" | sed 's#^@@||#@@||http://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 将规则转化成kp能识别的https
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt

		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@@https://\*#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@http://\*#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt


		# 给github放行
		sed -i '/github/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给apple的https放行
		sed -i '/apple.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给api.twitter.com的https放行
		sed -i '/twitter.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/fbcdn.net/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给 instagram.com 放行
		sed -i '/instagram.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt


		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '15,$d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 合二归一
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
	fi



	if [ "$koolproxyR_https_ChinaList" == "1" ];then
		sed -i '/^\$/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/\*\$/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给btbtt.替换过滤规则。
		sed -i 's#btbtt.\*#\*btbtt.\*#g' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给手机百度图片放行
		sed -i '/baidu.com\/it\/u/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt



		# 将白名单转化成https
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep "^@@||" | sed 's#^@@||#@@@||https://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep "^@@||" | sed 's#^@@||#@@||http://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt

		# 将规则转化成kp能识别的https
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt

		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@@https://\*#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@http://\*#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i '/fbcdn.net/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt


		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '6,$d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 合二归一
		wget -a /tmp/upload/kpr_log.txt -O $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt https://raw.githubusercontent.com/user1121114685/koolproxyR_rule_list/master/kpr_our_rule.txt
		cat $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt >> $KSROOT/koolproxyR/data/rules/easylistchina.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina_https.txt >> $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 把三大视频网站给剔除来，作为单独文件。
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'youku.com' > $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'iqiyi.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'v.qq.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'g.alicdn.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'tudou.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'gtimg.cn' >> $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i 'l.qq.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/iqiyi.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/v.qq.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/g.alicdn.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/tudou.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/gtimg.cn/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/l.qq.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给https://qq.com的html规则放行
		sed -i '/https:\/\/qq.com#/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt

	fi


	if [ "$koolproxyR_https_mobile" == "1" ];then
		sed -i '/^\$/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/\*\$/d' $KSROOT/koolproxyR/data/rules/mobile.txt

		# 将白名单转化成https
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep "^@@||" | sed 's#^@@||#@@@||https://#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep "^@@||" | sed 's#^@@||#@@||http://#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt

		# 将规则转化成kp能识别的https
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt

		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@@https://\*#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@http://\*#g' >> $KSROOT/koolproxyR/data/rules/mobile_https.txt

		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '8,$d' $KSROOT/koolproxyR/data/rules/mobile.txt
		# 合二归一
		cat  $KSROOT/koolproxyR/data/rules/mobile_https.txt >> $KSROOT/koolproxyR/data/rules/mobile.txt
		# 把三大视频网站给剔除来，作为单独文件。
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'youku.com' > $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'iqiyi.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'v.qq.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'g.alicdn.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'tudou.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'gtimg.cn' >> $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		cat $KSROOT/koolproxyR/data/rules/mobile.txt | grep -i 'l.qq.com' >> $KSROOT/koolproxyR/data/rules/kpr_video_list_1.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/iqiyi.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/v.qq.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/g.alicdn.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/tudou.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/gtimg.cn/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		sed -i '/l.qq.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' $KSROOT/koolproxyR/data/rules/mobile.txt
		# 给https://qq.com的html规则放行
		sed -i '/https:\/\/qq.com#/d' $KSROOT/koolproxyR/data/rules/mobile.txt



	fi
	# 删除临时文件
	rm $KSROOT/koolproxyR/data/rules/*_https.txt
	rm $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt



	echo_date 所有规则更新完毕！

	echo_date 自动重启koolproxyR，以应用新的规则文件！请稍后！
	sh $KSROOT/koolproxyR/kpr_config.sh restart
	echo =======================================================================================================
}

if [ -n "$1" ];then
	update_rule "$1" > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	http_response "$1"

else
	update_rule > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
fi
