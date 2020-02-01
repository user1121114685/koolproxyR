# KoolShare LEDE koolproxyR 项目
**Thanks To**
- Koolshare 的各位大佬，包括不限于：xiaobao、sadog、houzi-、 Fw867 、.......
- 晴天 、Leo Jo 对页面布局所做的贡献.
- Sukka / 苏卡卡 对交互界面的指点.
- 油炸包子 对页面调试的指点.
- 233boy 对脚本代码的指点.
- cjx 对easylistchina与cjx-annoyance规则的贡献.
- fanboy 对fanboy规则的整理和完善.
- vokins 对yhosts的整理和完善.
- 感谢在更新日志里面提到的所有人.
- Github 对代码进行托管.
- Gitlab 对代码进行中转
- 腾讯开发者平台 提供更新及文件下载.
---
**KPR是一个开源活性高的项目，它不一定满足你的需求，但你可以让它变得更好**

**欢迎大佬随时提交更新和问题**

## 为什么有这个项目！

官方其实是有项目的，但是我喜欢fanboy规则，在多方反馈无果的情况下，我当然自己动手丰衣足食了。这个项目允许大家提供好的规则。我们要以去广告为先。去掉所有的广告。谢谢！

## 怎么使用这个插件！ （请先卸载koolproxy，互不兼容。）
### 最佳方法 
在**SSH**中执行如下代码实现在线安装。（**请全部复制**）  
`wget -4 -O /tmp/KoolProxyR_install.sh https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/KoolProxyR_install.sh && chmod 777 /tmp/KoolProxyR_install.sh && sh /tmp/KoolProxyR_install.sh`


### 稳定方法
到F大没修复软件中心之前，或者我上架软件中心（其实根本没这个可能），你可以通过如下步骤进行使用本软件！

[点我下载](https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/koolproxyR.tar.gz)，通过软件中心的离线安装进行安装！**PS 请勿修改名字保持koolproxyR.tar.gz才能安装**，并且你可能需要执行下面的ssh代码.

---
如果你遇到** `离线安装` ** 无法安装，你还需要在SSH中执行如下步骤。（**请全部复制**）    

---

`wget -4 -O /koolshare/scripts/ks_tar_install.sh https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/ks_tar_install.sh && chmod 777 /koolshare/scripts/ks_tar_install.sh`

---

如果遇到其他问题，请提交问题反馈。能力有限不一定都能解决。


## 参考截图

![目前版本截图](https://github.com/user1121114685/koolproxyR/blob/master/20190328233937.jpg?raw=true "后续更新可能还会有更新！")
![目前版本截图](https://github.com/user1121114685/koolproxyR/blob/master/20190328233849.jpg?raw=true "后续更新可能还会有更新！")
![目前版本截图](https://github.com/user1121114685/koolproxyR/blob/master/20190407215443.jpg?raw=true "后续更新可能还会有更新！")

## 文件树简要说明
<details>
<summary>查看文件树更了解kpr</summary>
<pre><code>.
├── 20190328233849.jpg      项目首页用图片
├── 20190328233937.jpg      项目首页用图片
├── 20190407215443.jpg      项目首页用图片
├── backup.sh       软件中心调用的备份sh用于生成 history
├── build.sh        编译kpr版本---需要配合软件中心。当然也可以剔除那部分配合.
├── Changelog.txt       更新日志
├── config.json.js      暂时无用
├── history     历史版本
├── koolproxyR      主程序文件夹
│   ├── variable/haveged.ipk  用于解决kpr与v2ray ss 冲突导致开机变慢的问题
│   ├── init.d
│   │   └── S93koolproxyR.sh        自启脚本
│   ├── install.sh      离线安装执行脚本
│   ├── koolproxyR      /koolshare 下的文件夹 也是软件名字
│   │   ├── data
│   │   │   ├── gen_ca.sh       生成证书的脚本
│   │   │   ├── koolproxyR_ipset.conf       黑名单控制文件
│   │   │   ├── openssl.cnf     生成证书用的openssl配置文件
│   │   │   ├── rules       规则
│   │   │   │   ├── easylistchina.txt       主规则
│   │   │   │   ├── easylistchina.txt.md5
│   │   │   │   ├── fanboy-annoyance.txt        fanboy普通规则
│   │   │   │   ├── fanboy-annoyance.txt.md5
│   │   │   │   ├── kp.dat         视频加密规则
│   │   │   │   ├── kp.dat.md5
│   │   │   │   ├── kpr_video_list.txt      备用视频规则（主规则加载，视频规则没有加载的情况下使用）
│   │   │   │   ├── kpr_video_list.txt.md5
│   │   │   │   ├── user.txt           自定义规则文件
│   │   │   │   ├── user.txt.md5
│   │   │   │   ├── yhosts.txt      补充规则文件
│   │   │   │   └── yhosts.txt.md5
│   │   │   └── source.list     规则控制文件，此文件控制koolproxy加载那些规则。
│   │   ├── koolproxy       kp二进制文件
│   │   └── kpr_config.sh   kpr保存的时候执行的配置文件。【核心】
│   ├── variable/libhavege.ipk        用于解决kpr与v2ray ss 冲突导致开机变慢的问题
│   ├── scripts     脚本目录 安装后位于/koolshare/scripts
│   │   ├── KoolProxyR_cert.sh      证书相关脚本备份.恢复.生成 .0 根证书
│   │   ├── KoolProxyR_check_chain.sh    检查SS WG V2RAY 和是否被kiil的脚本
│   │   ├── KoolProxyR_config.sh        控制重启Kpr的文件----
│   │   ├── KoolProxyR_debug.sh         附加设置-调试模式的脚本
│   │   ├── KoolProxyR_getarp.sh        获取arp 脚本
│   │   ├── KoolProxyR_rules_status.sh      规则的状态脚本
│   │   ├── KoolProxyR_rule_update.sh       规则的更新脚本
│   │   ├── KoolProxyR_status.sh        kpr状态监测脚本
│   │   └── KoolProxyR_update_now.sh    kpr在线更新脚本
│   ├── uninstall.sh        卸载脚本
│   └── webs
│       ├── Module_koolproxyR.asp       Kpr界面文件
│       └── res
│           ├── icon-koolproxyR-bg.png      软件中心背景图标
│           ├── icon-koolproxyR.png         软件中心主图标
│           └── icon_koolproxyR-v.png       kpr界面文件左上角调用的图标
├── KoolProxyR_install.sh       在线安装/更新KPR的脚本
├── KoolProxyR_my_rule_diy.sh     自定义SHELL文件,放入/koolshare/scripts下即可
├── koolproxyR.tar.gz       最新版本的kpr离线安装包
├── kpr_tar_install.sh      kpr在线更新调用的离线安装脚本
├── KPR内图标.psd       图标开源
├── KPR图标背景图片.psd     图片开源
├── ks_tar_install.sh        软件中心离线安装脚本（修复了离线安装验证不通过的问题）
├── README.md       你现在所看到的页面
└── version        版本号，负责控制kpr的更新和md5核对。
</code></pre>
</details>


## 开源及授权
如果同时满足如下要求，无需取得授权。  
1.不得用于非开源项目.  
2.不得用于商业用途.  
3.给予本项目优先反馈，和知情权。  