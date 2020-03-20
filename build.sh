#!/bin/sh

MODULE=koolproxyR
VERSION="2.8.8"
TITLE=koolproxyR
DESCRIPTION="至   善   至   美"
HOME_URL="Module_koolproxyR.asp"
CHANGELOG="维护阶段的kpr"
# 查看内核日志
# dmesg | less 或者 dmesg
# 转化DOS格式到unix 需要 apt-get install dos2unix
find . -type f -exec dos2unix {} \;
#get latest rules
rm -rf ./koolproxyR/koolproxyR/data/rules/*.txt
rm -rf ./koolproxyR/koolproxyR/data/rules/*.md5
rm -rf ./koolproxyR/koolproxyR/data/rules/*.dat
rm -rf ./koolproxyR/koolproxyR/data/source.list
# rm -rf ./koolproxyR/koolproxyR/koolproxy
cd koolproxyR/koolproxyR/data/rules
# mkdir oridata
# cd oridata
# 下载三方规则
# 从 https://filterlists.com/ 找规则
# https://tgc.cloud/downloads/hosts.txt 36万DNS规则，kpr 生产出来是72万
wget https://easylist-downloads.adblockplus.org/easylistchina.txt

wget https://shaoxia1991.coding.net/p/cjxlist/d/cjxlist/git/raw/master/cjx-annoyance.txt

wget https://secure.fanboy.co.nz/fanboy-annoyance.txt
# ADGUARD-DNS过滤规则
# wget -O yhosts.txt https://filters.adtidy.org/extension/chromium/filters/15.txt
# yhosts过滤规则

wget -O yhosts.txt https://shaoxia1991.coding.net/p/yhosts/d/yhosts/git/raw/master/hosts
wget -O tvbox.txt https://shaoxia1991.coding.net/p/yhosts/d/yhosts/git/raw/master/data/tvbox.txt
cat tvbox.txt >> yhosts.txt

# ad.txt：合并EasylistChina、EasylistLite、CJX'sAnnoyance，以及补充的一些规则；
# ad2.txt：仅合并EasylistChina、EasylistLite、CJX'sAnnoyance；
# ad3.txt：合并EasylistChina、EasylistLite、CJX'sAnnoyance、EasyPrivacy；
# wget https://gitee.com/halflife/list/raw/master/ad.txt

# 分割三方规则

# # split -l 1 easylistchina.txt ./../easylistchina_
# split -l 1 yhosts.txt ./../chengfeng_
# # split -l 999 fanboy-annoyance.txt ./../fanboy_
# cd ..

# 同步kp官方规则

# wget https://kprules.b0.upaiyun.com/koolproxy.txt
# wget https://kprules.b0.upaiyun.com/daily.txt
# 暂时先用临时的替代
# wget https://kprules.b0.upaiyun.com/kp.dat
# wget https://kprules.b0.upaiyun.com/user.txt
# 同步Kpr视频规则及md5
# 电脑的wget 不支持houzi- 的- 域名 所以倒腾了下
wget https://shaoxia1991.coding.net/p/kp_dat/d/kp_dat/git/raw/master/kp.dat
wget https://shaoxia1991.coding.net/p/kp_dat/d/kp_dat/git/raw/master/kp.dat.md5
# read -s -n1 -p "请手动拷贝kp.dat 和kp.dat.md5,按任意键继续...."  

video_rules_local=`cat kp.dat.md5 | sed -n '2p'`
if [[ "$video_rules_local" == "" ]]; then
    # 当本地md5 没有时间戳的时候就更新更新时间戳
    video_rules_online=`curl https://shaoxia1991.coding.net/api/user/shaoxia1991/project/kp_dat/depot/kp_dat/git/blob/master%2Fkp.dat | jq '.data.file.lastCommitDate'`
    date -d @`echo ${video_rules_online:0:10}` +%Y年%m月%d日\ %X >> kp.dat.md5
fi


wget https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/koolproxyR/koolproxyR/data/rules/user.txt

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


# 将规则转化成kp能识别的https
cat fanboy-annoyance.txt | grep "^||" | sed 's#^||#||https://#g' >> fanboy-annoyance_https.txt
# 移出https不支持规则domain=
sed -i 's/\(,domain=\).*//g' fanboy-annoyance_https.txt
sed -i 's/\(\$domain=\).*//g' fanboy-annoyance_https.txt
sed -i 's/\(domain=\).*//g' fanboy-annoyance_https.txt
sed -i '/\^$/d' fanboy-annoyance_https.txt
sed -i '/\^\*\.gif/d' fanboy-annoyance_https.txt
sed -i '/\^\*\.jpg/d' fanboy-annoyance_https.txt


cat fanboy-annoyance.txt | grep "^||" | sed 's#^||#||http://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> fanboy-annoyance_https.txt
cat fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> fanboy-annoyance_https.txt


# 给github的https放行
sed -i '/github/d' fanboy-annoyance_https.txt
# 给apple的https放行
sed -i '/apple.com/d' fanboy-annoyance_https.txt
sed -i '/mzstatic.com/d' fanboy-annoyance_https.txt
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
sed -i '/jd.com/d' fanboy-annoyance_https.txt
sed -i '/taobao.com/d' fanboy-annoyance_https.txt
sed -i '/tmall.com/d' fanboy-annoyance_https.txt

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
sed -i '/googletagmanager.com/d' fanboy-annoyance.txt
# 给 microsoft.com 放行
sed -i '/microsoft.com/d' fanboy-annoyance.txt

# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
koolproxyR_del_rule=1
while [ $koolproxyR_del_rule = 1 ];do
    del_rule=`cat fanboy-annoyance.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
    if [[ "$del_rule" != "" ]]; then
        sed -i "${del_rule}d" fanboy-annoyance.txt
    else
        koolproxyR_del_rule=0
    fi
done	


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



# 将规则转化成kp能识别的https
cat easylistchina.txt | grep "^||" | sed 's#^||#||https://#g' >> easylistchina_https.txt
# 移出https不支持规则domain=
sed -i 's/\(,domain=\).*//g' easylistchina_https.txt
sed -i 's/\(\$domain=\).*//g' easylistchina_https.txt
sed -i 's/\(domain=\).*//g' easylistchina_https.txt
sed -i '/\^$/d' easylistchina_https.txt
sed -i '/\^\*\.gif/d' easylistchina_https.txt
sed -i '/\^\*\.jpg/d' easylistchina_https.txt

cat easylistchina.txt | grep "^||" | sed 's#^||#||http://#g' >> easylistchina_https.txt
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> easylistchina_https.txt
# 源文件替换成http
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> easylistchina_https.txt
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> easylistchina_https.txt
cat easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^|http' >> easylistchina_https.txt

# 给facebook.com的https放行
sed -i '/facebook.com/d' easylistchina_https.txt
sed -i '/fbcdn.net/d' easylistchina_https.txt
# 删除可能导致Kpr变慢的Https规则
sed -i '/\.\*\//d' easylistchina_https.txt



# 腾讯视频真的没办法了。找大佬帮我把
# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
sed -i '6,$d' easylistchina.txt
# 合二归一

wget https://shaoxia1991.coding.net/p/koolproxyR_rule_list/d/koolproxyR_rule_list/git/raw/master/kpr_our_rule.txt
# https://shaoxia1991.coding.net/p/koolproxyR_rule_list/d/koolproxyR_rule_list/git/raw/master/kpr_our_rule.txt
cat easylistchina_https.txt >> easylistchina.txt

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
sed -i '/jd.com/d' easylistchina.txt
sed -i '/taobao.com/d' easylistchina.txt
sed -i '/tmall.com/d' easylistchina.txt
# 给 tvbs.com 放行
sed -i '/tvbs.com/d' easylistchina.txt
sed -i '/googletagmanager.com/d' easylistchina.txt
# 给 netflix.com 放行
sed -i '/netflix.com/d' easylistchina.txt
# 给 microsoft.com 放行
sed -i '/microsoft.com/d' easylistchina.txt
# 给apple的https放行
sed -i '/apple.com/d' easylistchina.txt
sed -i '/mzstatic.com/d' easylistchina.txt

# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
koolproxyR_del_rule=1
while [ $koolproxyR_del_rule = 1 ];do
    del_rule=`cat easylistchina.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
    if [[ "$del_rule" != "" ]]; then
        sed -i "${del_rule}d" easylistchina.txt
    else
        koolproxyR_del_rule=0
    fi
done	
cat kpr_our_rule.txt >> easylistchina.txt





# -----------------------------------------KPR 中国简易规则处理结束------------------------------------------------


# -------------------------------------- 补充规则处理开始----------------------------------------------------------
# 删除不必要信息重新打包 0-11行 表示从第15行开始 $表示结束
# sed -i '1,11d' yhosts.txt
# 开始Kpr规则化处理
cat yhosts.txt > yhosts_https.txt 
sed -i 's/^127.0.0.1\ /||https:\/\//g' yhosts_https.txt
cat yhosts.txt >> yhosts_https.txt 
sed -i 's/^127.0.0.1\ /||http:\/\//g' yhosts_https.txt
# 处理tvbox.txt本身规则。
sed -i 's/^127.0.0.1\ /||/g' tvbox.txt
# 给国内三大电商平台放行
sed -i '/jd.com/d' yhosts_https.txt
sed -i '/taobao.com/d' yhosts_https.txt
sed -i '/tmall.com/d' yhosts_https.txt

# 合二归一
cat yhosts_https.txt > yhosts.txt
cat tvbox.txt >> yhosts.txt
# 此处对yhosts进行单独处理
sed -i 's/^@/!/g' yhosts.txt
sed -i 's/^#/!/g' yhosts.txt
sed -i '/localhost/d' yhosts.txt
sed -i '/broadcasthost/d' yhosts.txt
sed -i '/broadcasthost/d' yhosts.txt
sed -i '/cn.bing.com/d' yhosts.txt


# 给三大视频网站放行 由kp.dat负责
sed -i '/youku.com/d' yhosts.txt
sed -i '/iqiyi.com/d' yhosts.txt
sed -i '/g.alicdn.com/d' yhosts.txt
sed -i '/tudou.com/d' yhosts.txt
sed -i '/gtimg.cn/d' yhosts.txt


# 给知乎放行
sed -i '/zhihu.com/d' yhosts.txt

# 给qq.com放行
sed -i '/qq.com/d' yhosts.txt

# 给github的https放行
sed -i '/github/d' yhosts.txt
# 给apple的https放行
sed -i '/apple.com/d' yhosts.txt
sed -i '/mzstatic.com/d' yhosts.txt
# 给api.twitter.com的https放行
sed -i '/twitter.com/d' yhosts.txt
# 给facebook.com的https放行
sed -i '/facebook.com/d' yhosts.txt
sed -i '/fbcdn.net/d' yhosts.txt
# 给 instagram.com 放行
sed -i '/instagram.com/d' yhosts.txt
# 删除可能导致kpr卡死的神奇规则
sed -i '/https:\/\/\*/d' yhosts.txt
# 给 tvbs.com 放行
sed -i '/tvbs.com/d' yhosts.txt
sed -i '/googletagmanager.com/d' yhosts.txt
# 给 netflix.com 放行
sed -i '/netflix.com/d' yhosts.txt
# 给 microsoft.com 放行
sed -i '/microsoft.com/d' yhosts.txt

# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
koolproxyR_del_rule=1
while [ $koolproxyR_del_rule = 1 ];do
    del_rule=`cat yhosts.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
    if [[ "$del_rule" != "" ]]; then
        sed -i "${del_rule}d" yhosts.txt
    else
        koolproxyR_del_rule=0
    fi
done	



# ---------------------------------------------补充规则处理结束----------------------------------------------

## 删除临时文件
rm *_https.txt
rm kpr_our_rule.txt
rm cjx-annoyance.txt
rm tvbox.txt

# 测试专用
# split -l 1 yhosts.txt chengfeng_
# ls|grep chengfeng_|xargs -n1 -i{} mv {} {}.txt


cd ..

cp -rf ../../../koolproxy/* ./rules
find -name *.txt |sed 's#.*/##' > source.list

# find -name chengfeng* |sed 's#.*/##' >> source.list
# find -name fanboy_* |sed 's#.*/##' >> source.list
sed -i 's/^/0|/' source.list
sed -i 's/$/|0|0/' source.list
sed -i '/user.txt/d' source.list
echo "1|user.txt|0|0" >> source.list
echo "0|kp.dat|0|0" >> source.list
# source.list的格式命名
# 开关 0表示关闭 1表示开启
# 开关|规则名字|规则网址|规则备注名字
# 不支持规则

# 1 小于2个字符的 例如 ab
# ~开头的
# $webrtc,domain=avgle.com 
# @@*$stylesheet

cd ..
# 现在在\koolproxyR\koolproxyR\koolproxyR
# wget https://raw.githubusercontent.com/koolshare/ledesoft/master/koolproxy/koolproxy/koolproxy/koolproxy
cd ../..
# 现在在 Y:\koolproxyR 也就是主目录
# # Check and include base
# DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# # now include build_base.sh
# . $DIR/../softcenter/build_base.sh

# # change to module directory
# cd $DIR

# # do something here

# 


do_build_result() {
    rm -f koolproxyR.tar.gz
    tar -zcvf koolproxyR.tar.gz koolproxyR
    md5value=`md5sum koolproxyR.tar.gz | cut -d \  -f1`
    echo "$VERSION" > version
    echo "$md5value" >> version
}
do_build_result


sh backup.sh koolproxyR
cd koolproxyR/koolproxyR/data/rules
# ls | grep .txt | sed 's/^/md5sum /g' | >> rules_md5.sh
md5sum easylistchina.txt|awk '{print $1}' > easylistchina.txt.md5
# md5sum kp.dat|awk '{print $1}' > kp.dat.md5
md5sum user.txt|awk '{print $1}' > user.txt.md5
md5sum fanboy-annoyance.txt|awk '{print $1}' > fanboy-annoyance.txt.md5
md5sum yhosts.txt|awk '{print $1}' > yhosts.txt.md5

