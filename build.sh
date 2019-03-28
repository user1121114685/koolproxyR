#!/bin/sh

MODULE=koolproxyR
VERSION="900.8.7"
TITLE=koolproxyR
DESCRIPTION="听说KP还是自己掌握规则最舒服哟！"
HOME_URL="Module_koolproxyR.asp"
CHANGELOG="测试更新2.1"

#get latest rules
rm -rf ./koolproxyR/koolproxyR/data/rules/*
cd koolproxyR/koolproxyR/data/rules
wget https://kprule.com/koolproxy.txt
wget https://kprule.com/daily.txt
wget https://kprule.com/kp.dat
wget https://kprule.com/user.txt
# wget https://easylist-downloads.adblockplus.org/easylistchina.txt
# wget -O chengfeng.txt https://raw.githubusercontent.com/xinggsf/Adblock-Plus-Rule/master/ABP-FX.txt
wget https://easylist-downloads.adblockplus.org/fanboy-annoyance.txt

cd ../../../..
# Check and include base
DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

# now include build_base.sh
. $DIR/../softcenter/build_base.sh

# change to module directory
cd $DIR

# do something here

do_build_result

sh backup.sh $MODULE
