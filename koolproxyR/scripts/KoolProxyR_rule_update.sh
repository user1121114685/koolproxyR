#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

url_cjx="https://dev.tencent.com/u/shaoxia1991/p/cjxlist/git/raw/master/cjx-annoyance.txt"
url_kp="https://kprules.b0.upaiyun.com/kp.dat"
# url_koolproxy="https://kprules.b0.upaiyun.com/koolproxy.txt"
# 原网址跳转到https://kprule.com/koolproxy.txt跳转到又拍云，为了节省时间，还是直接去又拍云下载吧！避免某些时候跳转不过去
url_easylist="https://easylist-downloads.adblockplus.org/easylistchina.txt"
url_yhosts="https://dev.tencent.com/u/shaoxia1991/p/yhosts/git/raw/master/hosts"
url_yhosts1="https://dev.tencent.com/u/shaoxia1991/p/yhosts/git/raw/master/data/tvbox.txt"
kpr_our_rule="https://dev.tencent.com/u/shaoxia1991/p/koolproxyR_rule_list/git/raw/master/kpr_our_rule.txt"
# 检测是否开启fanboy全功能版本
if [[ "$koolproxyR_fanboy_all_rules" == "1" ]]; then
	url_fanboy="https://secure.fanboy.co.nz/r/fanboy-complete.txt"
	dbus set koolproxyR_fanboy_rules=1
else
	url_fanboy="https://secure.fanboy.co.nz/fanboy-annoyance.txt"
fi
update_rule(){
	echo_date =======================================================================================================
	echo_date 开始更新koolproxyR规则，请等待...
		
	# update 中国简易列表 2.0
	if [[ "$koolproxyR_basic_easylist_update" == "1" ]] || [ -n "$1" ]; then
		echo_date " ---------------------------------------------------------------------------------------"
		# wget --no-check-certificate --timeout=8 -qO - $url_easylist > /tmp/easylistchina.txt
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/easylistchina.txt $url_easylist
			easylistchina_rule_nu_local=`grep -E -v "^!" /tmp/easylistchina.txt | wc -l`
			if [[ "$easylistchina_rule_nu_local" -gt 5000 ]]; then
				break
			else
				echo_date easylistchina下载失败
				koolproxyR_basic_easylist_failed=1
			fi
		done
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/cjx-annoyance.txt $url_cjx
			cjx_rule_nu_local=`grep -E -v "^!" /tmp/cjx-annoyance.txt | wc -l`
			if [[ "$cjx_rule_nu_local" -gt 500 ]]; then
				break
			else
				echo_date cjx-annoyance下载失败
				koolproxyR_basic_easylist_failed=1
			fi
		done
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt $kpr_our_rule
			kpr_our_rule_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt | wc -l`
			if [[ "$kpr_our_rule_nu_local" -gt 500 ]]; then
				break
			else
				echo_date kpr_our_rule下载失败
				koolproxyR_basic_easylist_failed=1
			fi
		done
		# expr 进行运算，将统计到的规则条数相加 如果条数大于 10000 条就说明下载完毕
		easylistchina_rule_local=`expr $kpr_our_rule_nu_local + $cjx_rule_nu_local + $easylistchina_rule_nu_local`
		cat /tmp/cjx-annoyance.txt >> /tmp/easylistchina.txt
		rm /tmp/cjx-annoyance.txt
		easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
		easylist_rules_local1=`cat /tmp/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`

		echo_date KPR主规则 本地版本号： $easylist_rules_local
		echo_date KPR主规则 在线版本号： $easylist_rules_local1
		if [[ "koolproxyR_basic_easylist_failed" != "1" ]]; then
			if [[ "$easylistchina_rule_local" -gt 10000 ]]; then
				if [[ "$easylist_rules_local" != "$easylist_rules_local1" ]]; then
					echo_date 检测到新版本 KPR主规则 ，开始更新...
					echo_date 将临时文件覆盖到原始 KPR主规则文件
					mv /tmp/easylistchina.txt $KSROOT/koolproxyR/data/rules/easylistchina.txt
					koolproxyR_https_ChinaList=1
				else
					echo_date 检测到 KPR主规则本地版本号和在线版本号相同，那还更新个毛啊!
				fi
			fi
		else
			echo_date KPR主规则文件下载失败！
		fi
	fi
	
		# update 补充规则
	if [[ "$koolproxyR_basic_replenish_update" == "1" ]] || [ -n "$1" ]; then
		echo_date " ---------------------------------------------------------------------------------------"
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/yhosts.txt $url_yhosts
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/tvbox.txt $url_yhosts1
			cat /tmp/tvbox.txt >> /tmp/yhosts.txt
			replenish_rules_local=`cat $KSROOT/koolproxyR/data/rules/yhosts.txt  | sed -n '2p' | cut -d "=" -f2`
			replenish_rules_local1=`cat /tmp/yhosts.txt | sed -n '2p' | cut -d "=" -f2`
			mobile_nu_local=`grep -E -v "^!" /tmp/yhosts.txt | wc -l`
			echo_date 补充规则本地版本号： $replenish_rules_local
			echo_date 补充规则在线版本号： $replenish_rules_local1
			if [[ "$mobile_nu_local" -gt 5000 ]]; then
				if [[ "$replenish_rules_local" != "$replenish_rules_local1" ]]; then
					echo_date 将临时文件覆盖到原始 补充规则 文件
					mv /tmp/yhosts.txt $KSROOT/koolproxyR/data/rules/yhosts.txt
					koolproxyR_https_mobile=1
					break
				else
					echo_date 检测到 补充规则 本地版本号和在线版本号相同，那还更新个毛啊!
				fi
			else
				echo_date 补充规则文件下载失败！
			fi
		done

	fi

	# update 视频规则
	# if [[ "$koolproxyR_basic_video_update" == "1" ]] || [[-n "$1" ]]; then
	# 	echo_date " ---------------------------------------------------------------------------------------"
	# 	echo_date 加密视频规则kp.dat 看不到版本号。所以强制更新。！
	# 	wget -4 -a /tmp/upload/kpr_log.txt -O $KSROOT/koolproxyR/data/rules/kp.dat $url_kp
	# 	echo_date  视频规则已经更新。

	# fi

	# update fanboy规则
	if [[ "$koolproxyR_basic_fanboy_update" == "1" ]] || [ -n "$1" ]; then
		echo_date " ---------------------------------------------------------------------------------------"
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/fanboy-annoyance.txt $url_fanboy
			# wget --no-check-certificate --timeout=8 -qO - $url_fanboy > /tmp/fanboy-annoyance.txt
			# 检测是否开启fanboy 全规则版本
			if [[ "$koolproxyR_fanboy_all_rules" == "1" ]]; then
				fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '4p'|awk '{print $3,$4}'`
				fanboy_rules_local1=`cat /tmp/fanboy-annoyance.txt  | sed -n '4p'|awk '{print $3,$4}'`
			else
				fanboy_rules_local=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
				fanboy_rules_local1=`cat /tmp/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
			fi
			fanboy_nu_local=`grep -E -v "^!" /tmp/fanboy-annoyance.txt | wc -l`

			echo_date fanboy规则本地版本号： $fanboy_rules_local
			echo_date fanboy规则在线版本号： $fanboy_rules_local1
			if [[ "$fanboy_nu_local" -gt 15000 ]]; then
				if [[ "$fanboy_rules_local" != "$fanboy_rules_local1" ]]; then
					echo_date 检测到新版本 fanboy规则 列表，开始更新...
					echo_date 将临时文件覆盖到原始 fanboy规则 文件
					mv /tmp/fanboy-annoyance.txt $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
					koolproxyR_https_fanboy=1
					break
				else
					echo_date 检测到 fanboy规则 本地版本号和在线版本号相同，那还更新个毛啊!
				fi
			else
				echo_date fanboy规则 文件下载失败！
			fi
		done
	fi

	rm -rf /fanboy-annoyance.txt
	rm -rf /tmp/yhosts.txt
	rm -rf /tmp/easylistchina.txt

	echo_date 正在优化kpr规则。。。。。
	if [[ "$koolproxyR_https_fanboy" == "1" ]]; then
		# 删除导致KP崩溃的规则
		# 听说高手?都打的很多、这样才能体现技术
		sed -i '/^\$/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/\*\$/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/iqiyi.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/qq.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/g.alicdn.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/tudou.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/gtimg.cn/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt


		# 将规则转化成kp能识别的https
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 移出https不支持规则domain=
		sed -i 's/\(,domain=\).*//g' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i 's/\(\$domain=\).*//g' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i 's/\(domain=\).*//g' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/\^$/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/\^\*\.gif/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/\^\*\.jpg/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt

		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt

		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt


		# 给github放行
		sed -i '/github/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给api.twitter.com的https放行
		sed -i '/twitter.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/fbcdn.net/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给 instagram.com 放行
		sed -i '/instagram.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给 twitch.tv 放行
		sed -i '/twitch.tv/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 删除可能导致卡顿的HTTPS规则
		sed -i '/\.\*\//d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		# 给国内三大电商平台放行
		sed -i '/https:\/\/jd.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/https:\/\/taobao.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/https:\/\/tmall.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt

		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '15,$d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 合二归一
		cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt >> $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/googletagmanager.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		# 给apple的https放行
		sed -i '/apple.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
		sed -i '/mzstatic.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt


	fi



	if [[ "$koolproxyR_https_ChinaList" == "1" ]]; then
		sed -i '/^\$/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/\*\$/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给btbtt.替换过滤规则。
		sed -i 's#btbtt.\*#\*btbtt.\*#g' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给手机百度图片放行
		sed -i '/baidu.com\/it\/u/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# # 给手机百度放行
		# sed -i '/mbd.baidu.comd' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给知乎放行
		sed -i '/zhihu.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给apple的https放行
		sed -i '/apple.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/mzstatic.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt





		# 将规则转化成kp能识别的https
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		# 移出https不支持规则domain=
		sed -i 's/\(,domain=\).*//g' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i 's/\(\$domain=\).*//g' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i 's/\(domain=\).*//g' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i '/\^$/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i '/\^\*\.gif/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i '/\^\*\.jpg/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt



		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt

		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		sed -i '/fbcdn.net/d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt
		# 删除可能导致卡顿的HTTPS规则
		sed -i '/\.\*\//d' $KSROOT/koolproxyR/data/rules/easylistchina_https.txt



		# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
		sed -i '6,$d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 合二归一
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
		sed -i '/g.alicdn.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/tudou.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/gtimg.cn/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给https://qq.com的html规则放行
		sed -i '/qq.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给国内三大电商平台放行
		sed -i '/https:\/\/jd.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/https:\/\/taobao.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/https:\/\/tmall.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/googletagmanager.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt



	fi


	if [[ "$koolproxyR_https_mobile" == "1" ]]; then
		# 删除不必要信息重新打包 0-11行 表示从第15行开始 $表示结束
		# sed -i '1,11d' $KSROOT/koolproxyR/data/rules/yhosts.txt

		# 开始Kpr规则化处理
		cat $KSROOT/koolproxyR/data/rules/yhosts.txt > $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		sed -i 's/^127.0.0.1\ /||https:\/\//g' $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		cat $KSROOT/koolproxyR/data/rules/yhosts.txt >> $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		sed -i 's/^127.0.0.1\ /||http:\/\//g' $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		# 处理tvbox.txt本身规则。
		sed -i 's/^127.0.0.1\ /||/g' /tmp/tvbox.txt
		rm -rf /tmp/tvbox.txt
		# 给国内三大电商平台放行
		sed -i '/https:\/\/jd.com/d' $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		sed -i '/https:\/\/taobao.com/d' $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		sed -i '/https:\/\/tmall.com/d' $KSROOT/koolproxyR/data/rules/yhosts_https.txt

		# 合二归一
		cat  $KSROOT/koolproxyR/data/rules/yhosts_https.txt > $KSROOT/koolproxyR/data/rules/yhosts.txt
		cat /tmp/tvbox.txt >> $KSROOT/koolproxyR/data/rules/yhosts.txt


		# 此处对yhosts进行单独处理
		sed -i 's/^@/!/g' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i 's/^#/!/g' $KSROOT/koolproxyR/data/rules/yhosts.txt


		# 给知乎放行
		sed -i '/zhihu.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给https://qq.com的html规则放行
		sed -i '/qq.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给github的https放行
		sed -i '/github/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给apple的https放行
		sed -i '/apple.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/mzstatic.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给api.twitter.com的https放行
		sed -i '/twitter.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给facebook.com的https放行
		sed -i '/facebook.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/fbcdn.net/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 instagram.com 放行
		sed -i '/instagram.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 删除可能导致kpr卡死的神奇规则
		sed -i '/https:\/\/\*/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给国内三大电商平台放行
		sed -i '/https:\/\/jd.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/https:\/\/taobao.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/https:\/\/tmall.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/googletagmanager.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt


	fi
	# 删除临时文件
	rm $KSROOT/koolproxyR/data/rules/*_https.txt
	rm $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt



	echo_date 所有规则更新完毕！

	echo_date 自动重启koolproxyR，以应用新的规则文件！请稍后！
	sh $KSROOT/koolproxyR/kpr_config.sh restart
	echo_date =======================================================================================================
}

if [ -n "$1" ]; then
	update_rule "$1" > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	http_response "$1"

else
	update_rule > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
fi
