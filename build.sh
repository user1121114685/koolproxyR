#!/bin/sh

MODULE=koolproxyR
VERSION="900.8.17"
TITLE=koolproxyR
DESCRIPTION="KPR更多规则更舒服！"
HOME_URL="Module_koolproxyR.asp"
CHANGELOG="正式移除了KP绿坝规则，和KP加密规则。现在所有规则都是未加密的了。"

#get latest rules
rm -rf ./koolproxyR/koolproxyR/data/rules/*
rm -rf ./koolproxyR/koolproxyR/data/source.list
rm -rf ./koolproxyR/koolproxyR/koolproxy
cd koolproxyR/koolproxyR/data/rules
# mkdir oridata
# cd oridata
# 下载三方规则
wget http://tools.yiclear.com/ChinaList2.0.txt

#  http://tools.yiclear.com/ChinaList2.0.txt  取代abp
#  https://easylist.to/easylist/easylist.txt  取代fanboy
#  https://fanboy.co.nz/r/fanboy-ultimate.txt fanboy 旗舰版
#  https://easylist-downloads.adblockplus.org/malwaredomains_full.txt  恶意软件规则

# wget https://easylist-downloads.adblockplus.org/easylistchina.txt
wget -O chengfeng.txt https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/ABP-FX.txt
wget https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt
# 分割三方规则

# # split -l 1 easylistchina.txt ./../easylistchina_
# split -l 1 chengfeng.txt ./../chengfeng_
# # split -l 999 fanboy-annoyance.txt ./../fanboy_
# cd ..

# 同步kp官方规则

# wget https://kprules.b0.upaiyun.com/koolproxy.txt
# wget https://kprules.b0.upaiyun.com/daily.txt
# wget https://kprules.b0.upaiyun.com/kp.dat
wget https://kprules.b0.upaiyun.com/user.txt

## 删除导致KP崩溃的规则
sed -i '/^\$/d' fanboy-annoyance.txt
sed -i '/\*\$/d' fanboy-annoyance.txt

sed -i '/youku.com/d' fanboy-annoyance.txt
sed -i '/iqiyi.com/d' fanboy-annoyance.txt
sed -i '/v.qq.com/d' fanboy-annoyance.txt

# 将白名单转化成https
cat fanboy-annoyance.txt | grep "^@@||" | sed 's#^@@||#@@||https://#g' >> fanboy-annoyance_https.txt
# 将规则转化成kp能识别的https
cat fanboy-annoyance.txt | grep "^||" | sed 's#^||#||https://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| sed 's#^#https://#g' >> fanboy-annoyance_https.txt
# 给github的https放行
sed -i '/github/d' fanboy-annoyance_https.txt

sed -i '/^\$/d' ChinaList2.0.txt
sed -i '/\*\$/d' ChinaList2.0.txt

# 将白名单转化成https
cat ChinaList2.0.txt | grep "^@@||" | sed 's#^@@||#@@||https://#g' >> ChinaList2.0_https.txt
# 将规则转化成kp能识别的https
cat ChinaList2.0.txt | grep "^||" | sed 's#^||#||https://#g' >> ChinaList2.0_https.txt
# 给优酷放行，解决一直加载的问题
echo "@@mp4.ts" >> ChinaList2.0.txt
echo "||https://valipl.cp31.ott.cibntv.net" >> ChinaList2.0.txt
echo "||https://bsv.atm.youku.com" >> ChinaList2.0.txt
# 给手机百度图片放行
sed -i '/baidu.com\/it\/u/d' ChinaList2.0.txt
sed -i '/baidu.com\/it\/u/d' ChinaList2.0_https.txt
# echo "@@https://f*.baidu.com/it/u=*,*&fm=$third-party" >> ChinaList2.0.txt
# echo "@@http://f*.baidu.com/it/u=*,*&fm=$third-party" >> ChinaList2.0.txt
cat ChinaList2.0.txt | grep -i '^[0-9a-z]'| sed 's#^#https://#g' >> ChinaList2.0_https.txt


sed -i '/^\$/d' chengfeng.txt
sed -i '/\*\$/d' chengfeng.txt

# 给三大视频网站放行 由kp.dat负责
sed -i '/youku.com/d' chengfeng.txt
sed -i '/iqiyi.com/d' chengfeng.txt
sed -i '/v.qq.com/d' chengfeng.txt

# 将白名单转化成https
cat chengfeng.txt | grep "^@@||" | sed 's#^@@||#@@||https://#g' >> chengfeng_https.txt
# 将规则转化成kp能识别的https
cat chengfeng.txt | grep "^||" | sed 's#^||#||https://#g' >> chengfeng_https.txt
cat chengfeng.txt | grep -i '^[0-9a-z]'| sed 's#^#https://#g' >> chengfeng_https.txt

# 测试专用
# split -l 1 chengfeng.txt chengfeng_
# ls|grep chengfeng_|xargs -n1 -i{} mv {} {}.txt

cd ..
find -name *.txt |sed 's#.*/##' > source.list

# find -name chengfeng* |sed 's#.*/##' >> source.list
# find -name fanboy_* |sed 's#.*/##' >> source.list
sed -i 's/^/0|/' source.list
sed -i 's/$/|0|0/' source.list
echo "1|user.txt|0|0" >> source.list

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
