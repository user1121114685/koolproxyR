#!/bin/sh
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

url_cjx="https://shaoxia1991.coding.net/p/cjxlist/d/cjxlist/git/raw/master/cjx-annoyance.txt"
url_kp="https://houzi-.coding.net/p/my_dream/d/my_dream/git/raw/master/kp.dat"
url_kp_md5="https://houzi-.coding.net/p/my_dream/d/my_dream/git/raw/master/kp.dat.md5"
# url_koolproxy="https://kprules.b0.upaiyun.com/koolproxy.txt"
# 原网址跳转到https://kprule.com/koolproxy.txt跳转到又拍云，为了节省时间，还是直接去又拍云下载吧！避免某些时候跳转不过去
url_easylist="https://easylist-downloads.adblockplus.org/easylistchina.txt"
url_yhosts="https://shaoxia1991.coding.net/p/yhosts/d/yhosts/git/raw/master/hosts"
url_yhosts1="https://shaoxia1991.coding.net/p/yhosts/d/yhosts/git/raw/master/data/tvbox.txt"
kpr_our_rule="https://shaoxia1991.coding.net/p/koolproxyR_rule_list/d/koolproxyR_rule_list/git/raw/master/kpr_our_rule.txt"
# 检测是否开启fanboy全功能版本
if [[ "$koolproxyR_fanboy_all_rules" == "1" ]]; then
	url_fanboy="https://secure.fanboy.co.nz/r/fanboy-complete.txt"
	dbus set koolproxyR_fanboy_rules=1
else
	url_fanboy="https://secure.fanboy.co.nz/fanboy-annoyance.txt"
fi
update_rule(){
	echo_date =======================================================================================================
	echo_date 开始更新koolproxyR的规则，请等待...
	# 赋予文件夹权限 
	chmod -R 777 /koolshare/koolproxyR/data/rules
	# update 中国简易列表 2.0
	if [[ "$koolproxyR_basic_easylist_update" == "1" ]]; then
		echo_date " ---------------------------------------------------------------------------------------"
		# wget --no-check-certificate --timeout=8 -qO - $url_easylist > /tmp/easylistchina.txt
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/easylistchina.txt $url_easylist
			easylistchina_rule_nu_local=`grep -E -v "^!" /tmp/easylistchina.txt | wc -l`
			if [[ "$easylistchina_rule_nu_local" -gt 5000 ]]; then
				break
			else
				echo_date easylistchina规则文件下载失败
				koolproxyR_basic_easylist_failed=1
			fi
		done
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/cjx-annoyance.txt $url_cjx
			cjx_rule_nu_local=`grep -E -v "^!" /tmp/cjx-annoyance.txt | wc -l`
			if [[ "$cjx_rule_nu_local" -gt 500 ]]; then
				break
			else
				echo_date cjx-annoyance规则文件下载失败
				koolproxyR_basic_easylist_failed=1
			fi
		done
		for i in {1..5}; do
			wget -4 -a /tmp/upload/kpr_log.txt -O $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt $kpr_our_rule
			kpr_our_rule_nu_local=`grep -E -v "^!" $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt | wc -l`
			if [[ "$kpr_our_rule_nu_local" -gt 500 ]]; then
				break
			else
				echo_date kpr_our_rule规则文件下载失败
				koolproxyR_basic_easylist_failed=1
			fi
		done
		# expr 进行运算，将统计到的规则条数相加 如果条数大于 10000 条就说明下载完毕
		easylistchina_rule_local=`expr $kpr_our_rule_nu_local + $cjx_rule_nu_local + $easylistchina_rule_nu_local`
		cat /tmp/cjx-annoyance.txt >> /tmp/easylistchina.txt
		rm /tmp/cjx-annoyance.txt
		easylist_rules_local=`cat $KSROOT/koolproxyR/data/rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
		easylist_rules_local1=`cat /tmp/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`

		echo_date KPR主规则的本地版本号： $easylist_rules_local
		echo_date KPR主规则的在线版本号： $easylist_rules_local1
		if [[ "$koolproxyR_basic_easylist_failed" != "1" ]]; then
			if [[ "$easylistchina_rule_local" -gt 10000 ]]; then
				if [[ "$easylist_rules_local" != "$easylist_rules_local1" ]]; then
					echo_date 检测到 KPR主规则 已更新，现在开始更新...
					echo_date 将临时的KPR主规则文件移动到指定位置
					mv /tmp/easylistchina.txt $KSROOT/koolproxyR/data/rules/easylistchina.txt
					koolproxyR_https_ChinaList=1
				else
					echo_date 检测到 KPR主规则本地版本号和在线版本号相同，那还更新个毛啊!
				fi
			fi
		else
			echo_date KPR主规则文件下载失败！
		fi
	else
		echo_date 未打开 KPR主规则 的更新开关！
	fi
	
		# update 补充规则
	if [[ "$koolproxyR_basic_replenish_update" == "1" ]]; then
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
	else
		echo_date 未打开 补充规则 的更新开关！
	fi

	# update 视频规则
	if [[ "$koolproxyR_basic_video_update" == "1" ]] || [[ -n "$1" ]]; then
		echo_date " ---------------------------------------------------------------------------------------"
		for i in {1..5}; do
			kpr_video_md5=`md5sum $KSROOT/koolproxyR/data/rules/kp.dat | awk '{print $1}'`
			wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/kp.dat.md5 $url_kp_md5
			kpr_video_new_md5=`cat /tmp/kp.dat.md5 | sed -n '1p'`
			echo_date 远程视频规则md5：$kpr_video_new_md5
			echo_date 您本地视频规则md5：$kpr_video_md5

			if [[ "$kpr_video_md5" != "$kpr_video_new_md5" ]]; then
				echo_date 检测到新版视频规则.开始更新..........
				wget -4 -a /tmp/upload/kpr_log.txt -O /tmp/kp.dat $url_kp
				kpr_video_download_md5=`md5sum /tmp/kp.dat | awk '{print $1}'`
				echo_date 您下载的视频规则md5：$kpr_video_download_md5
				if [[ "$kpr_video_download_md5" == "$kpr_video_new_md5" ]]; then
					echo_date 将临时文件覆盖到原始 视频规则 文件
					mv /tmp/kp.dat $KSROOT/koolproxyR/data/rules/kp.dat
					mv /tmp/kp.dat.md5 $KSROOT/koolproxyR/data/rules/kp.dat.md5

					video_rules_local=`cat $KSROOT/koolproxyR/data/rules/kp.dat.md5 | sed -n '2p'`
					if [[ "$video_rules_local" == "" ]]; then
						# 当本地md5 没有时间戳的时候就更新更新时间戳
						video_rules_online=`curl https://houzi-.coding.net/api/user/houzi-/project/my_dream/depot/my_dream/git/blob/master%2Fkp.dat | jq '.data.file.lastCommitDate'`
						date -d @`echo ${video_rules_online:0:10}` +%Y年%m月%d日\ %X >> $KSROOT/koolproxyR/data/rules/kp.dat.md5
					fi
					break
				else
					echo_date 视频规则md5校验不通过...
				fi
			else
				echo_date 检测到 视频规则 本地版本号和在线版本号相同，那还更新个毛啊!
			fi
		done
	else
		echo_date 未打开 视频规则 的更新开关！
	fi

	# update fanboy规则
	if [[ "$koolproxyR_basic_fanboy_update" == "1" ]]; then
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
	else
		echo_date 未打开 fanboy规则 的更新开关！
	fi

	rm -rf /tmp/fanboy-annoyance.txt
	rm -rf /tmp/yhosts.txt
	rm -rf /tmp/easylistchina.txt

	if [[ "$koolproxyR_https_fanboy" == "1" ]]; then
		echo_date 正在优化 fanboy规则。。。。。
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
		sed -i '/jd.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/taobao.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt
		sed -i '/tmall.com/d' $KSROOT/koolproxyR/data/rules/fanboy-annoyance_https.txt

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
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxyR_del_rule=1
		while [ $koolproxyR_del_rule = 1 ];do
			del_rule=`cat $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [[ "$del_rule" != "" ]]; then
				sed -i "${del_rule}d" $KSROOT/koolproxyR/data/rules/fanboy-annoyance.txt
			else
				koolproxyR_del_rule=0
			fi
		done	


	else
		echo_date 跳过优化 fanboy规则。。。。。
	fi



	if [[ "$koolproxyR_https_ChinaList" == "1" ]]; then
		echo_date 正在优化 KPR主规则。。。。。
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
		cat $KSROOT/koolproxyR/data/rules/easylistchina_https.txt >> $KSROOT/koolproxyR/data/rules/easylistchina.txt
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
		sed -i '/jd.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/taobao.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/tmall.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		sed -i '/googletagmanager.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' $KSROOT/koolproxyR/data/rules/easylistchina.txt
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxyR_del_rule=1
		while [ $koolproxyR_del_rule = 1 ];do
			del_rule=`cat $KSROOT/koolproxyR/data/rules/easylistchina.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [[ "$del_rule" != "" ]]; then
				sed -i "${del_rule}d" $KSROOT/koolproxyR/data/rules/easylistchina.txt
			else
				koolproxyR_del_rule=0
			fi
		done	
		cat $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt >> $KSROOT/koolproxyR/data/rules/easylistchina.txt

	else
		echo_date 跳过优化 KPR主规则。。。。。
	fi


	if [[ "$koolproxyR_https_mobile" == "1" ]]; then
		# 删除不必要信息重新打包 0-11行 表示从第15行开始 $表示结束
		# sed -i '1,11d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		echo_date 正在优化 补充规则yhosts。。。。。

		# 开始Kpr规则化处理
		cat $KSROOT/koolproxyR/data/rules/yhosts.txt > $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		sed -i 's/^127.0.0.1\ /||https:\/\//g' $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		cat $KSROOT/koolproxyR/data/rules/yhosts.txt >> $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		sed -i 's/^127.0.0.1\ /||http:\/\//g' $KSROOT/koolproxyR/data/rules/yhosts_https.txt
		# 处理tvbox.txt本身规则。
		sed -i 's/^127.0.0.1\ /||/g' /tmp/tvbox.txt
		# 合二归一
		cat  $KSROOT/koolproxyR/data/rules/yhosts_https.txt > $KSROOT/koolproxyR/data/rules/yhosts.txt
		cat /tmp/tvbox.txt >> $KSROOT/koolproxyR/data/rules/yhosts.txt
		rm -rf /tmp/tvbox.txt


		# 此处对yhosts进行单独处理
		sed -i 's/^@/!/g' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i 's/^#/!/g' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/localhost/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/broadcasthost/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/broadcasthost/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/cn.bing.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给三大视频网站放行 由kp.dat负责
		sed -i '/youku.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/iqiyi.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/g.alicdn.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/tudou.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/gtimg.cn/d' $KSROOT/koolproxyR/data/rules/yhosts.txt


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
		sed -i '/jd.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/taobao.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/tmall.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 netflix.com 放行
		sed -i '/netflix.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 tvbs.com 放行
		sed -i '/tvbs.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		sed -i '/googletagmanager.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 给 microsoft.com 放行
		sed -i '/microsoft.com/d' $KSROOT/koolproxyR/data/rules/yhosts.txt
		# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
		# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
		koolproxyR_del_rule=1
		while [ $koolproxyR_del_rule = 1 ];do
			del_rule=`cat $KSROOT/koolproxyR/data/rules/yhosts.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
			if [[ "$del_rule" != "" ]]; then
				sed -i "${del_rule}d" $KSROOT/koolproxyR/data/rules/yhosts.txt
			else
				koolproxyR_del_rule=0
			fi
		done	


	else
		echo_date 跳过优化 补充规则yhosts。。。。。
	fi
	# 删除临时文件
	rm $KSROOT/koolproxyR/data/rules/*_https.txt
	rm $KSROOT/koolproxyR/data/rules/kpr_our_rule.txt



	echo_date 所有规则更新并优化完毕！

	echo_date 自动重启koolproxyR，以应用新的规则文件！请稍后！
	sh $KSROOT/koolproxyR/kpr_config.sh restart
	echo_date =======================================================================================================
}


case $2 in
5)
	update_rule "$1" > /tmp/upload/kpr_log.txt
	echo XU6J03M6 >> /tmp/upload/kpr_log.txt
	http_response "$1"
	;;
*)
	# 此次由于定时任务无法产生随机Id,所以直接判断$1.
	if [[ "$1" == "update" ]]; then
		# 此处生产随机的三位数 用来缓解瞬间产生大量请求导致服务器拒绝的情况。
		sleep_time=`tr -cd 0-9 </dev/urandom | head -c 4`
		sleep $sleep_time
		update_rule "$1" > /tmp/upload/kpr_log.txt
		echo_date "本次自动更新等待了 $sleep_time 秒" >> /tmp/upload/kpr_log.txt
		echo XU6J03M6 >> /tmp/upload/kpr_log.txt
		http_response "$1"
	fi
	;;
esac
