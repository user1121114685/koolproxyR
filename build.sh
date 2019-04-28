#!/bin/sh

MODULE=koolproxyR
VERSION="900.8.36"
TITLE=koolproxyR
DESCRIPTION="KPR更多规则更舒服！"
HOME_URL="Module_koolproxyR.asp"
CHANGELOG="维护阶段的kpr"

# 转化DOS格式到unix 需要 apt-get install dos2unix
find . -type f -exec dos2unix {} \;
#get latest rules
rm -rf ./koolproxyR/koolproxyR/data/rules/*
rm -rf ./koolproxyR/koolproxyR/data/source.list
rm -rf ./koolproxyR/koolproxyR/koolproxy
cd koolproxyR/koolproxyR/data/rules
# mkdir oridata
# cd oridata
# 下载三方规则

wget https://easylist-downloads.adblockplus.org/easylistchina.txt
wget https://raw.githubusercontent.com/cjx82630/cjxlist/master/cjx-annoyance.txt

wget https://secure.fanboy.co.nz/fanboy-annoyance.txt
# 移动广告过滤规则
wget -O mobile.txt https://filters.adtidy.org/extension/chromium/filters/11.txt

# ad.txt：合并EasylistChina、EasylistLite、CJX'sAnnoyance，以及补充的一些规则；
# ad2.txt：仅合并EasylistChina、EasylistLite、CJX'sAnnoyance；
# ad3.txt：合并EasylistChina、EasylistLite、CJX'sAnnoyance、EasyPrivacy；
# wget https://gitee.com/halflife/list/raw/master/ad.txt

# 分割三方规则

# # split -l 1 easylistchina.txt ./../easylistchina_
# split -l 1 mobile.txt ./../chengfeng_
# # split -l 999 fanboy-annoyance.txt ./../fanboy_
# cd ..

# 同步kp官方规则

# wget https://kprules.b0.upaiyun.com/koolproxy.txt
# wget https://kprules.b0.upaiyun.com/daily.txt
# 暂时先用临时的替代
# wget https://kprules.b0.upaiyun.com/kp.dat
# wget https://kprules.b0.upaiyun.com/user.txt
wget https://raw.githubusercontent.com/user1121114685/koolproxyR/master/koolproxyR/koolproxyR/data/rules/kp.dat
wget https://raw.githubusercontent.com/user1121114685/koolproxyR/master/koolproxyR/koolproxyR/data/rules/user.txt

## ---------------------------------------------------fanboy处理开始------------------------------------------------------
## 删除导致KP崩溃的规则
sed -i '/^\$/d' fanboy-annoyance.txt
sed -i '/\*\$/d' fanboy-annoyance.txt

# 给三大视频网站放行 由kp.dat负责
sed -i '/youku.com/d' fanboy-annoyance.txt
sed -i '/g.alicdn.com/d' fanboy-annoyance.txt
sed -i '/tudou.com/d' fanboy-annoyance.txt
sed -i '/iqiyi.com/d' fanboy-annoyance.txt
sed -i '/qq.com/d' fanboy-annoyance.txt
sed -i '/gtimg.cn/d' fanboy-annoyance.txt
# 给知乎放行
sed -i '/zhihu.com/d' fanboy-annoyance.txt


# # 将白名单转化成https https放行用三个@ http 用2个@
# cat fanboy-annoyance.txt | grep "^@@||" | sed 's#^@@||#@@@@||https://#g' >> fanboy-annoyance_https.txt
# cat fanboy-annoyance.txt | grep "^@@||" | sed 's#^@@||#@@||http://#g' >> fanboy-annoyance_https.txt
# 将规则转化成kp能识别的https
cat fanboy-annoyance.txt | grep "^||" | sed 's#^||#||https://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep "^||" | sed 's#^||#||http://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> fanboy-annoyance_https.txt
# cat fanboy-annoyance.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@@@https://\*#g' >> fanboy-annoyance_https.txt
# cat fanboy-annoyance.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@http://\*#g' >> fanboy-annoyance_https.txt


# 给github的https放行
sed -i '/github/d' fanboy-annoyance_https.txt
# 给apple的https放行
sed -i '/apple.com/d' fanboy-annoyance_https.txt
# 给api.twitter.com的https放行
sed -i '/twitter.com/d' fanboy-annoyance_https.txt
# 给facebook.com的https放行
sed -i '/facebook.com/d' fanboy-annoyance_https.txt
sed -i '/fbcdn.net/d' fanboy-annoyance_https.txt
# 给 instagram.com 放行
sed -i '/instagram.com/d' fanboy-annoyance_https.txt
# 删除可能导致Kpr变慢的Https规则
sed -i '/\.\*\//d' fanboy-annoyance_https.txt

# 给国内三大电商平台放行
sed -i '/https:\/\/jd.com/d' fanboy-annoyance_https.txt
sed -i '/https:\/\/taobao.com/d' fanboy-annoyance_https.txt
sed -i '/https:\/\/tmall.com/d' fanboy-annoyance_https.txt

# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
sed -i '15,$d' fanboy-annoyance.txt
# 合二归一
cat fanboy-annoyance_https.txt >> fanboy-annoyance.txt
# 删除可能导致kpr卡死的神奇规则
sed -i '/https:\/\/\*/d' fanboy-annoyance.txt
# 给 netflix.com 放行
sed -i '/netflix.com/d' fanboy-annoyance.txt
# 给 tvbs.com 放行
sed -i '/tvbs.com/d' fanboy-annoyance.txt

## -------------------------------------------------------fanboy处理结束------------------------------------------------------


## ---------------------------------------------------------KPR 中国简易规则处理开始 -------------------------------------------------------
cat cjx-annoyance.txt >> easylistchina.txt
sed -i '/^\$/d' easylistchina.txt
sed -i '/\*\$/d' easylistchina.txt
# 给btbtt.替换过滤规则。
sed -i 's#btbtt.\*#\*btbtt.\*#g' easylistchina.txt
# 给手机百度图片放行
sed -i '/baidu.com\/it\/u/d' easylistchina.txt
# # 给手机百度放行
# sed -i '/mbd.baidu.com/d' easylistchina.txt
# 给知乎放行
sed -i '/zhihu.com/d' easylistchina.txt



# # 将白名单转化成https
# cat easylistchina.txt | grep "^@@||" | sed 's#^@@||#@@@@||https://#g' >> easylistchina_https.txt
# cat easylistchina.txt | grep "^@@||" | sed 's#^@@||#@@||http://#g' >> easylistchina_https.txt
# 将规则转化成kp能识别的https
cat easylistchina.txt | grep "^||" | sed 's#^||#||https://#g' >> easylistchina_https.txt
cat easylistchina.txt | grep "^||" | sed 's#^||#||http://#g' >> easylistchina_https.txt
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> easylistchina_https.txt
# 源文件替换成http
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> easylistchina_https.txt
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> easylistchina_https.txt
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^|http' >> easylistchina_https.txt

# cat easylistchina.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@@@https://\*#g' >> easylistchina_https.txt
# cat easylistchina.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@http://\*#g' >> easylistchina_https.txt
# 给facebook.com的https放行
sed -i '/facebook.com/d' easylistchina_https.txt
sed -i '/fbcdn.net/d' easylistchina_https.txt
# 删除可能导致Kpr变慢的Https规则
sed -i '/\.\*\//d' easylistchina_https.txt



# 腾讯视频真的没办法了。找大佬帮我把
# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
sed -i '6,$d' easylistchina.txt
# 合二归一
wget https://raw.githubusercontent.com/user1121114685/koolproxyR_rule_list/master/kpr_our_rule.txt
cat kpr_our_rule.txt >> easylistchina.txt
cat easylistchina_https.txt >> easylistchina.txt

# 把三大视频网站给剔除来，作为单独文件。
cat easylistchina.txt | grep -i 'youku.com' > kpr_video_list.txt
cat easylistchina.txt | grep -i 'iqiyi.com' >> kpr_video_list.txt
cat easylistchina.txt | grep -i 'v.qq.com' >> kpr_video_list.txt
cat easylistchina.txt | grep -i 'g.alicdn.com' >> kpr_video_list.txt
cat easylistchina.txt | grep -i 'tudou.com' >> kpr_video_list.txt
cat easylistchina.txt | grep -i 'gtimg.cn' >> kpr_video_list.txt
cat easylistchina.txt | grep -i 'l.qq.com' >> kpr_video_list.txt
# 给三大视频网站放行 由kp.dat负责
sed -i '/youku.com/d' easylistchina.txt
sed -i '/iqiyi.com/d' easylistchina.txt
sed -i '/g.alicdn.com/d' easylistchina.txt
sed -i '/tudou.com/d' easylistchina.txt
sed -i '/gtimg.cn/d' easylistchina.txt
# 给https://qq.com的html规则放行
sed -i '/qq.com/d' easylistchina.txt
# 删除可能导致kpr卡死的神奇规则
sed -i '/https:\/\/\*/d' easylistchina.txt
# 给国内三大电商平台放行
sed -i '/https:\/\/jd.com/d' easylistchina.txt
sed -i '/https:\/\/taobao.com/d' easylistchina.txt
sed -i '/https:\/\/tmall.com/d' easylistchina.txt
# 给 tvbs.com 放行
sed -i '/tvbs.com/d' easylistchina.txt
# 给 netflix.com 放行
sed -i '/netflix.com/d' easylistchina.txt





# -----------------------------------------KPR 中国简易规则处理结束------------------------------------------------


# -------------------------------------- 移动设备规则处理开始----------------------------------------------------------

sed -i '/^\$/d' mobile.txt
sed -i '/\*\$/d' mobile.txt


# # 将白名单转化成https
# cat mobile.txt | grep "^@@||" | sed 's#^@@||#@@@@||https://#g' >> mobile_https.txt
# cat mobile.txt | grep "^@@||" | sed 's#^@@||#@@||http://#g' >> mobile_https.txt
# 将规则转化成kp能识别的https
cat mobile.txt | grep "^||" | sed 's#^||#||https://#g' >> mobile_https.txt
cat mobile.txt | grep "^||" | sed 's#^||#||http://#g' >> mobile_https.txt
cat mobile.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> mobile_https.txt
cat mobile.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> mobile_https.txt
cat mobile.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> mobile_https.txt
# cat mobile.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@@@https://\*#g' >> mobile_https.txt
# cat mobile.txt | grep -i '^@@'| grep -v '^@@|'| sed 's#^@@#@@http://\*#g' >> mobile_https.txt


# 删除可能导致Kpr变慢的Https规则
sed -i '/\.\*\//d' mobile_https.txt

# 给国内三大电商平台放行
sed -i '/https:\/\/jd.com/d' mobile_https.txt
sed -i '/https:\/\/taobao.com/d' mobile_https.txt
sed -i '/https:\/\/tmall.com/d' mobile_https.txt


# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
sed -i '8,$d' mobile.txt
# 合二归一
cat mobile_https.txt >> mobile.txt

# 把三大视频网站给剔除来，作为单独文件。
cat mobile.txt | grep -i 'youku.com' > kpr_video_list_1.txt
cat mobile.txt | grep -i 'iqiyi.com' >> kpr_video_list_1.txt
cat mobile.txt | grep -i 'v.qq.com' >> kpr_video_list_1.txt
cat mobile.txt | grep -i 'g.alicdn.com' >> kpr_video_list_1.txt
cat mobile.txt | grep -i 'tudou.com' >> kpr_video_list_1.txt
cat mobile.txt | grep -i 'gtimg.cn' >> kpr_video_list_1.txt
cat mobile.txt | grep -i 'l.qq.com' >> kpr_video_list_1.txt
# 给三大视频网站放行 由kp.dat负责
sed -i '/youku.com/d' mobile.txt
sed -i '/iqiyi.com/d' mobile.txt
sed -i '/g.alicdn.com/d' mobile.txt
sed -i '/tudou.com/d' mobile.txt
sed -i '/gtimg.cn/d' mobile.txt
# 给知乎放行
sed -i '/zhihu.com/d' mobile.txt

# 给https://qq.com的html规则放行
sed -i '/qq.com/d' mobile.txt

# 给github的https放行
sed -i '/github/d' mobile.txt
# 给apple的https放行
sed -i '/apple.com/d' mobile.txt
# 给api.twitter.com的https放行
sed -i '/twitter.com/d' mobile.txt
# 给facebook.com的https放行
sed -i '/facebook.com/d' mobile.txt
sed -i '/fbcdn.net/d' mobile.txt
# 给 instagram.com 放行
sed -i '/instagram.com/d' mobile.txt
# 删除可能导致kpr卡死的神奇规则
sed -i '/https:\/\/\*/d' mobile.txt
# 给 tvbs.com 放行
sed -i '/tvbs.com/d' mobile.txt
# 给 netflix.com 放行
sed -i '/netflix.com/d' mobile.txt




# ---------------------------------------------移动设备规则处理结束----------------------------------------------

## 删除临时文件
rm *https.txt
rm kpr_our_rule.txt
rm cjx-annoyance.txt

# 测试专用
# split -l 1 mobile.txt chengfeng_
# ls|grep chengfeng_|xargs -n1 -i{} mv {} {}.txt

cd ..
find -name *.txt |sed 's#.*/##' > source.list

# find -name chengfeng* |sed 's#.*/##' >> source.list
# find -name fanboy_* |sed 's#.*/##' >> source.list
sed -i 's/^/0|/' source.list
sed -i 's/$/|0|0/' source.list
sed -i '/user.txt/d' source.list
echo "1|user.txt|0|0" >> source.list
echo "0|kp.dat|0|0" >> source.list

# 不支持规则

# 1 小于2个字符的 例如 ab
# ~开头的
# $webrtc,domain=avgle.com 
# @@*$stylesheet

cd ..
wget https://raw.githubusercontent.com/koolshare/ledesoft/master/koolproxy/koolproxy/koolproxy/koolproxy
cd ../..
# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here

do_build_result

sh backup.sh $MODULE
