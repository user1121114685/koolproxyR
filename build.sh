#!/bin/sh

MODULE=koolproxyR
VERSION="900.8.12"
TITLE=koolproxyR
DESCRIPTION="KPR更多规则更舒服！"
HOME_URL="Module_koolproxyR.asp"
CHANGELOG="正式版本上线"

#get latest rules
rm -rf ./koolproxyR/koolproxyR/data/rules/*
rm -rf ./koolproxyR/koolproxyR/data/source.list
rm -rf ./koolproxyR/koolproxyR/koolproxy
cd koolproxyR/koolproxyR/data/rules
# mkdir oridata
# cd oridata
# 下载三方规则
wget https://easylist-downloads.adblockplus.org/easylistchina.txt
wget -O chengfeng.txt https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/ABP-FX.txt
wget https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt
# 分割三方规则

# # split -l 1 easylistchina.txt ./../easylistchina_
# split -l 1 chengfeng.txt ./../chengfeng_
# # split -l 999 fanboy-annoyance.txt ./../fanboy_
# cd ..
# # 给三方规则添加后缀
# ls|grep easylistchina_|xargs -n1 -i{} mv {} {}.txt
# ls|grep chengfeng_|xargs -n1 -i{} mv {} {}.txt
# ls|grep fanboy_|xargs -n1 -i{} mv {} {}.txt
# # 清除三方规则的原始文件，并将条数版本信息写入文件以此来减少安装包大小，减少不不要的浪费
# easylist_rules_local=`cat ./oridata/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
# easylist_nu_local=`grep -E -v "^!" ./oridata/easylistchina.txt | wc -l`
# abx_rules_local=`cat ./oridata/chengfeng.txt  | sed -n '3p'|awk '{print $3,$4}'`
# abx_nu_local=`grep -E -v "^!" ./oridata/chengfeng.txt | wc -l`
# fanboy_rules_local=`cat ./oridata/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
# fanboy_nu_local=`grep -E -v "^!" ./oridata/fanboy-annoyance.txt | wc -l`
# echo $easylist_rules_local > abp.txt
# echo $easylist_nu_local >> abp.txt
# echo $abx_rules_local > cf.txt
# echo $abx_nu_local >> cf.txt
# echo $fanboy_rules_local > fb.txt 
# echo $fanboy_nu_local >> fb.txt
# rm -rf oridata


# 同步kp官方规则

wget https://kprules.b0.upaiyun.com/koolproxy.txt
wget https://kprules.b0.upaiyun.com/daily.txt
wget https://kprules.b0.upaiyun.com/kp.dat
wget https://kprules.b0.upaiyun.com/user.txt

## 删除导致KP崩溃的规则
sed -i '/^\$/d' fanboy-annoyance.txt
sed -i '/*\$/d' fanboy-annoyance.txt
# sed -i '/??\$/d' fanboy-annoyance.txt
# sed -i '/???\$/d' fanboy-annoyance.txt
# sed -i '/????\$/d' fanboy-annoyance.txt
# sed -i '/?????\$/d' fanboy-annoyance.txt
sed -i '/^\$/d' easylistchina.txt
sed -i '/*\$/d' easylistchina.txt
# sed -i '/??\$/d' easylistchina.txt
# sed -i '/???\$/d' easylistchina.txt
# sed -i '/????\$/d' easylistchina.txt
# sed -i '/?????\$/d' easylistchina.txt
sed -i '/^\$/d' chengfeng.txt
sed -i '/*\$/d' chengfeng.txt
# sed -i '/??\$/d' chengfeng.txt
# sed -i '/???\$/d' chengfeng.txt
# sed -i '/????\$/d' chengfeng.txt
# sed -i '/?????\$/d' chengfeng.txt

# 测试专用
# split -l 1 chengfeng.txt chengfeng_
# ls|grep chengfeng_|xargs -n1 -i{} mv {} {}.txt

cd ..
find -name *.txt |sed 's#.*/##' > source.list

# find -name chengfeng* |sed 's#.*/##' >> source.list
# find -name fanboy_* |sed 's#.*/##' >> source.list
sed -i 's/^/0|/' source.list
sed -i 's/$/|0|0/' source.list
echo "0|kp.dat|0|0" >> source.list

# 不支持规则

# 1 小于2个字符的 例如 ab
# ~开头的
# $webrtc,domain=avgle.com 
# @@*$stylesheet

cd ..
wget https://github.com/koolshare/ledesoft/raw/master/koolproxy/koolproxy/koolproxy/koolproxy
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
