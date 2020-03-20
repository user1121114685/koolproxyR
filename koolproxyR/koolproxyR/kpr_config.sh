#! /bin/sh

alias echo_date='echo $(date +%Y年%m月%d日\ %X):'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxyR_`
SOFT_DIR=/koolshare
KP_DIR=$SOFT_DIR/koolproxyR
LOCK_FILE=/var/lock/koolproxy.lock
# 一定要按照source.list的排列顺序/我就不按照顺序。。。啦啦啦啦啦啦
SOURCE_LIST=$KP_DIR/data/source.list
# 关闭规则调试模式
dbus set koolproxyR_debug_0=0


write_user_txt(){
	if [ -n "$koolproxyR_custom_rule" ]; then
		echo $koolproxyR_custom_rule | base64_decode | sed 's/\\n/\n/g' > $KP_DIR/data/rules/user.txt
	fi
}

load_rules(){
	sed -i "s/1|/0|/g" $SOURCE_LIST
	sed -i "s/0|user/1|user/g" $SOURCE_LIST
	if [[ "$koolproxyR_easylist_rules" == "1" ]]; then
		echo_date 加载【KPR主规则】
		sed -i "s/0|easylistchina/1|easylistchina/g" $SOURCE_LIST
	fi
	if [[ "$koolproxyR_easylist_rules" == "2" ]]; then
		echo_date 加载【koolproxy主规则】
		sed -i "s/0|koolproxy/1|koolproxy/g" $SOURCE_LIST

	fi
	if [[ "$koolproxyR_easylist_rules" == "3" ]]; then
		echo_date 加载【koolproxy主规则+每日规则】
		sed -i "s/0|koolproxy/1|koolproxy/g" $SOURCE_LIST
		sed -i "s/0|daily/1|daily/g" $SOURCE_LIST

	fi
	if [[ "$koolproxyR_replenish_rules" == "1" ]]; then
		echo_date 加载【补充规则】
		sed -i "s/0|yhosts.txt/1|yhosts.txt/g" $SOURCE_LIST
	fi

	if [[ "$koolproxyR_video_rules" == "1" ]]; then
		echo_date 加载【KP视频规则】
		sed -i "s/0|kp.dat/1|kp.dat/g" $SOURCE_LIST
	fi
	if [[ "$koolproxyR_fanboy_rules" != "3" ]]; then
		echo_date 加载【Fanboy规则】
		sed -i "s/0|fanboy/1|fanboy/g" $SOURCE_LIST	
	fi	
}

start_koolproxy(){
	write_user_txt
	kp_version=`koolproxy -h | head -n1 | awk '{print $6}'`
	dbus set koolproxyR_binary_version="koolproxy $kp_version "
	echo_date 开启koolproxyR主进程！
	load_rules
	[ -f "$KSROOT/bin/koolproxy" ] && rm -rf $KSROOT/bin/koolproxy
	[ ! -L "$KSROOT/bin/koolproxy" ] && ln -sf $KSROOT/koolproxyR/koolproxy $KSROOT/bin/koolproxy
	if [[ "$koolproxyR_mode_enable" == "1" ]]; then
		echo_date 开启【进阶模式】
		[ "$koolproxyR_mode" == "0" ] && echo_date 选择【不过滤】
		[ "$koolproxyR_mode" == "1" ] && echo_date 选择【HTTP过滤模式】
		[ "$koolproxyR_mode" == "2" ] && echo_date 选择【HTTP/HTTPS双过滤模式】
		[ "$koolproxyR_mode" == "3" ] && echo_date 选择【黑名单模式】
		[ "$koolproxyR_mode" == "4" ] && echo_date 选择【HTTP/HTTPS双黑名单模式】
#		[ "$koolproxyR_mode" == "5" ] && echo_date 选择【全端口模式】
	else
		[ "$koolproxyR_base_mode" == "0" ] && echo_date 选择【不过滤】	
		[ "$koolproxyR_base_mode" == "1" ] && echo_date 选择【HTTP过滤模式】
		[ "$koolproxyR_base_mode" == "2" ] && echo_date 选择【黑名单模式】
	fi
	cd $KP_DIR && koolproxy -d --ttl 188 --ttlport 3001 --ipv6

}

stop_koolproxy(){
	echo_date 关闭koolproxyR主进程...
	kill -9 `pidof koolproxy` >/dev/null 2>&1
	killall koolproxy >/dev/null 2>&1
}

creat_start_up(){
	[ ! -L "/etc/rc.d/S93koolproxyR.sh" ] && {
		echo_date 加入开机自动启动...
		ln -sf $SOFT_DIR/init.d/S93koolproxyR.sh /etc/rc.d/S93koolproxyR.sh
	}
}

write_nat_start(){
	echo_date  添加nat-start触发事件...
	uci -q batch <<-EOT
	  delete firewall.ks_koolproxy
	  set firewall.ks_koolproxy=include
	  set firewall.ks_koolproxy.type=script
	  set firewall.ks_koolproxy.path=/koolshare/koolproxyR/kpr_config.sh
	  set firewall.ks_koolproxy.family=any
	  set firewall.ks_koolproxy.reload=1
	  commit firewall
	EOT
}

remove_nat_start(){
	echo_date 删除nat-start触发...
	uci -q batch <<-EOT
	  delete firewall.ks_koolproxy
	  commit firewall
	EOT
}
# ===============================

add_ipset_conf(){
	if [[ "$koolproxyR_mode_enable" == "1" ]]; then
		if [[ "$koolproxyR_mode" == "3" ]]; then
			echo_date 添加黑名单软连接...
			rm -rf /tmp/dnsmasq.d/koolproxyR_ipset.conf
			ln -sf $KP_DIR/data/koolproxyR_ipset.conf /tmp/dnsmasq.d/koolproxyR_ipset.conf
			dnsmasq_restart=1
		fi
	else
		if [[ "$koolproxyR_base_mode" == "2" ]]; then
			echo_date 添加黑名单软连接...
			rm -rf /tmp/dnsmasq.d/koolproxyR_ipset.conf
			ln -sf $KP_DIR/data/koolproxyR_ipset.conf /tmp/dnsmasq.d/koolproxyR_ipset.conf
			dnsmasq_restart=1
		fi		
	fi
}

remove_ipset_conf(){
	if [ -L "/tmp/dnsmasq.d/koolproxyR_ipset.conf" ]; then
		echo_date 移除黑名单软连接...
		rm -rf /tmp/dnsmasq.d/koolproxyR_ipset.conf
	fi
}

del_dns_takeover(){
	ss_enable=`iptables -t nat -L SHADOWSOCKS 2>/dev/null |wc -l`
	ss_chromecast=`dbus get ss_basic_chromecast`
	[ -z "$ss_chromecast" ] && ss_chromecast=0
	if [[ "$ss_enable" == "0" ]]; then
		chromecast_nu=`iptables -t nat -L PREROUTING -v -n --line-numbers|grep "dpt:53"|awk '{print $1}'`
		[ -n "$chromecast_nu" ] && iptables -t nat -D PREROUTING $chromecast_nu >/dev/null 2>&1
	else
		[ "$ss_chromecast" == "0" ] && [ -n "$chromecast_nu" ] && iptables -t nat -D PREROUTING $chromecast_nu >/dev/null 2>&1
	fi
}

restart_dnsmasq(){
	if [[ "$dnsmasq_restart" == "1" ]]; then
		echo_date 重启dnsmasq进程...
		/etc/init.d/dnsmasq restart > /dev/null 2>&1
	fi
}

write_reboot_job(){
	# start setvice
	[ ! -f  "/etc/crontabs/root" ] && touch /etc/crontabs/root
	CRONTAB=`cat /etc/crontabs/root|grep KoolProxyR_check_chain.sh`
	KoolProxyR_rule_update=`cat /etc/crontabs/root|grep KoolProxyR_rule_update.sh\ update`
	
	[ -z "$KoolProxyR_rule_update" ] && echo_date 写入KPR规则自动更新... && echo  "15 3 * * * /koolshare/scripts/KoolProxyR_rule_update.sh update" >> /etc/crontabs/root

	[ -z "$CRONTAB" ] && echo_date 写入KPR过滤代理链守护... && echo  "*/30 * * * * $SOFT_DIR/scripts/KoolProxyR_check_chain.sh" >> /etc/crontabs/root
#	if [[ "1" == "$koolproxyR_reboot" ]]; then
#		[ -z "$CRONTAB" ] && echo_date 开启插件定时重启，每天"$koolproxyR_reboot_hour"时，自动重启插件... && echo  "0 $koolproxyR_reboot_hour * * * $KP_DIR/kpr_config.sh restart" >> /etc/crontabs/root 
#	elif [[ "2" == "$koolproxyR_reboot" ]]; then
#		[ -z "$CRONTAB" ] && echo_date 开启插件间隔重启，每隔"$koolproxyR_reboot_inter_hour"时，自动重启插件... && echo  "0 */$koolproxyR_reboot_inter_hour * * * $KP_DIR/kpr_config.sh restart" >> /etc/crontabs/root 
#	fi
}

remove_reboot_job(){
	[ ! -f  "/etc/crontabs/root" ] && touch /etc/crontabs/root
	jobexist=`cat /etc/crontabs/root|grep KoolProxyR`
	KP_ENBALE=`dbus get koolproxyR_enable`

	# kill crontab job
	if [[ ! "$KP_ENBALE" == "1" ]]; then
		if [ ! -z "$jobexist" ]; then
			echo_date 删除KPR规则自动更新...
			sed -i '/KoolProxyR_rule_update/d' /etc/crontabs/root >/dev/null 2>&1
			echo_date 删除KPR过滤代理链守护...
			sed -i '/koolproxyR_check_chain/d' /etc/crontabs/root >/dev/null 2>&1
		fi
	fi
}

creat_ipset(){
	echo_date 创建ipset名单
	# Load ipset netfilter kernel modules and kernel modules
	ipset -! create white_kp_list nethash
	ipset -! create black_koolproxy iphash
	cat $KP_DIR/data/rules/user.txt | grep -Eo "(.\w+\:[1-9][0-9]{1,4})/" | grep -Eo "([0-9]{1,5})" | sort -un | sed -e '$a\80' -e '$a\443' | sed -e "s/^/-A kp_full_port &/g" -e "1 i\-N kp_full_port bitmap:port range 0-65535 " | ipset -R -!
}

gen_special_ip() {
	dhcp_mode_wan=`cat /etc/config/network | grep -oi "wan" | sed -n '1p' | cut -c 1-3`
	if [[ "$dhcp_mode_wan" != "" ]]; then
		ethernet=`ifconfig | grep eth | wc -l`
		if [[ "$ethernet" -ge "2" ]]; then
			dhcp_mode=`ubus call network.interface.$dhcp_mode_wan status | grep \"proto\" | sed -e 's/^[ \t]\"proto\": //g' -e 's/"//g' -e 's/,//g'`
		fi
	fi
	cat <<-EOF | grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}"
		0.0.0.0/8
		10.0.0.0/8
		100.64.0.0/10
		127.0.0.0/8
		169.254.0.0/16
		172.16.0.0/12
		192.0.0.0/24
		192.0.2.0/24
		192.31.196.0/24
		192.52.193.0/24
		192.88.99.0/24
		192.168.0.0/16
		192.175.48.0/24
		198.18.0.0/15
		198.51.100.0/24
		203.0.113.0/24
		224.0.0.0/4
		240.0.0.0/4
		255.255.255.255
		$([ "$dhcp_mode" == "pppoe" ] && ubus call network.interface.$dhcp_mode_wan status | grep \"address\" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
EOF
}

add_white_black_ip(){
	echo_date 添加ipset名单
	ipset -! restore <<-EOF || return 1
		create white_kp_list hash:net hashsize 64
		$(gen_special_ip | sed -e "s/^/add white_kp_list /")
EOF
	ipset -A black_koolproxy 110.110.110.110 >/dev/null 2>&1
	return 0
}

get_mode_name() {
	case "$1" in
		0)
			echo "不过滤"
		;;
		1)
			echo "HTTP过滤模式"
		;;
		2)
			echo "HTTP/HTTPS双过滤模式"
		;;
		3)
			echo "黑名单模式"
		;;
		4)
			echo "HTTP/HTTPS双黑名单模式"
		;;
		5)
			echo "全端口模式"
		;;							
	esac
}

get_base_mode_name() {
	case "$1" in
		0)
			echo "不过滤"
		;;
		1)
			echo "HTTP过滤模式"
		;;
		2)
			echo "黑名单模式"
		;;							
	esac
}

get_jump_mode(){
	case "$1" in
		0)
			echo "-j"
		;;
		*)
			echo "-g"
		;;
	esac
}

get_action_chain() {
	case "$1" in
		0)
			echo "RETURN"
		;;
		1)
			echo "KP_HTTP"
		;;
		2)
			echo "KP_HTTPS"
		;;
		3)
			echo "KP_BLOCK_HTTP"
		;;
		4)
			echo "KP_BLOCK_HTTPS"
		;;				
		5)
			echo "KP_ALL_PORT"
		;;		
	esac
}

get_base_mode() {
	case "$1" in
		0)
			echo "RETURN"
		;;
		1)
			echo "KP_HTTP"
		;;
		2)
			echo "KP_BLOCK_HTTP"
		;;
	esac
}

factor(){
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo ""
	else
		echo "$2 $1"
	fi
}

flush_nat(){
	echo_date 移除nat规则...
	cd /tmp
	iptables -t nat -S | grep -E "KOOLPROXY|KOOLPROXY_ACT|KP_HTTP|KP_HTTPS|KP_BLOCK_HTTP|KP_BLOCK_HTTPS|KP_ALL_PORT" | sed 's/-A/iptables -t nat -D/g'|sed 1,7d > clean.sh && chmod 777 clean.sh && ./clean.sh
	iptables -t nat -X KOOLPROXY > /dev/null 2>&1
	iptables -t nat -X KOOLPROXY_ACT > /dev/null 2>&1	
	iptables -t nat -X KP_HTTP > /dev/null 2>&1
	iptables -t nat -X KP_HTTPS > /dev/null 2>&1
	iptables -t nat -X KP_BLOCK_HTTP > /dev/null 2>&1
	iptables -t nat -X KP_BLOCK_HTTPS > /dev/null 2>&1	
	iptables -t nat -X KP_ALL_PORT > /dev/null 2>&1
	ipset -F black_koolproxy > /dev/null 2>&1 && ipset -X black_koolproxy > /dev/null 2>&1
	ipset -F white_kp_list > /dev/null 2>&1 && ipset -X white_kp_list > /dev/null 2>&1
	ipset -F kp_full_port > /dev/null 2>&1 && ipset -X kp_full_port > /dev/null 2>&1
}

get_acl_para(){
	echo `dbus get koolproxyR_acl_list|sed 's/>/\n/g'|sed '/^$/d'|awk NR==$1{print}|cut -d "<" -f "$2"`
}

lan_acess_control(){
	# lan access control
#	[ -z "$koolproxyR_acl_default" ] && koolproxyR_acl_default=1
	acl_nu=`dbus get koolproxyR_acl_list|sed 's/>/\n/g'|sed '/^$/d'|sed '/^ /d'|wc -l`
	if [ -n "$acl_nu" ]; then
		min="1"
		max="$acl_nu"
		while [ $min -le $max ]
		do
			#echo_date $min $max
			proxy_name=`get_acl_para $min 1`
			ipaddr=`get_acl_para $min 2`
			mac=`get_acl_para $min 3`
			proxy_mode=`get_acl_para $min 4`
		
			[ -n "$ipaddr" ] && [ -z "$mac" ] && echo_date 加载ACL规则：【$ipaddr】模式为：$(get_mode_name $proxy_mode)
			[ -z "$ipaddr" ] && [ -n "$mac" ] && echo_date 加载ACL规则：【$mac】模式为：$(get_mode_name $proxy_mode)
			[ -n "$ipaddr" ] && [ -n "$mac" ] && echo_date 加载ACL规则：【$ipaddr】【$mac】模式为：$(get_mode_name $proxy_mode)
			#echo iptables -t nat -A KOOLPROXY $(factor $ipaddr "-s") $(factor $mac "-m mac --mac-source") -p tcp $(get_jump_mode $proxy_mode) $(get_action_chain $proxy_mode)
			iptables -t nat -A KOOLPROXY $(factor $ipaddr "-s") $(factor $mac "-m mac --mac-source") -p tcp $(get_jump_mode $proxy_mode) $(get_action_chain $proxy_mode)
			min=`expr $min + 1`
		done
		if [[ "$koolproxyR_mode_enable" == "1" ]]; then
			echo_date 加载ACL规则：其余主机模式为：$(get_mode_name $koolproxyR_mode)		
		else
			echo_date 加载ACL规则：其余主机模式为：$(get_base_mode_name $koolproxyR_base_mode)
		fi
	else
		if [[ "$koolproxyR_mode_enable" == "1" ]]; then
			echo_date 加载ACL规则：所有模式为：$(get_mode_name $koolproxyR_mode)	
		else
			echo_date 加载ACL规则：所有模式为：$(get_base_mode_name $koolproxyR_base_mode)
		fi
	fi
}

load_nat(){
	echo_date 加载nat规则！
	#----------------------BASIC RULES---------------------
	echo_date 写入iptables规则到nat表中...
	# 创建KOOLPROXY nat rule
	iptables -t nat -N KOOLPROXY
	# 创建KOOLPROXY_ACT nat rule
	iptables -t nat -N KOOLPROXY_ACT
	# 匹配TTL走TTL Port
	iptables -t nat -A KOOLPROXY_ACT -p tcp -m ttl --ttl-eq 188 -j REDIRECT --to 3001
	# 不匹配TTL走正常Port
	iptables -t nat -A KOOLPROXY_ACT -p tcp -j REDIRECT --to 3000
	# 局域网地址不走KP
	iptables -t nat -A KOOLPROXY -m set --match-set white_kp_list dst -j RETURN
	# 生成对应CHAIN
	iptables -t nat -N KP_HTTP
	iptables -t nat -A KP_HTTP -p tcp -m multiport --dport 80 -j KOOLPROXY_ACT
	iptables -t nat -N KP_HTTPS
	iptables -t nat -A KP_HTTPS -p tcp -m multiport --dport 80,443 -j KOOLPROXY_ACT
	iptables -t nat -N KP_BLOCK_HTTP
	iptables -t nat -A KP_BLOCK_HTTP -p tcp -m multiport --dport 80 -m set --match-set black_koolproxy dst -j KOOLPROXY_ACT
	iptables -t nat -N KP_BLOCK_HTTPS
	iptables -t nat -A KP_BLOCK_HTTPS -p tcp -m multiport --dport 80,443 -m set --match-set black_koolproxy dst -j KOOLPROXY_ACT	
	iptables -t nat -N KP_ALL_PORT
	iptables -t nat -A KP_ALL_PORT -p tcp -j KOOLPROXY_ACT
	# 局域网控制
	lan_acess_control
	# 剩余流量转发到缺省规则定义的链中
	[ "$koolproxyR_mode_enable" == "1" ] && iptables -t nat -A KOOLPROXY -p tcp -j $(get_action_chain $koolproxyR_mode)
	[ ! "$koolproxyR_mode_enable" == "1" ] && iptables -t nat -A KOOLPROXY -p tcp -j $(get_base_mode $koolproxyR_base_mode)
	# 重定所有流量到 KOOLPROXY
	# HTTP过滤模式和视频模式
	PR_NU=`iptables -nvL PREROUTING -t nat |sed 1,2d | sed -n '/prerouting_rule/='`
	if [[ "$PR_NU" == "" ]]; then
		PR_NU=1
	else
		let PR_NU+=1
	fi	
#	[ "$koolproxyR_mode" == "1" ] || [ "$koolproxyR_mode" == "3" ] && iptables -t nat -I PREROUTING "$PR_NU" -p tcp -j KOOLPROXY
	iptables -t nat -I PREROUTING "$PR_NU" -p tcp -j KOOLPROXY
	# ipset 黑名单模式
#	[ "$koolproxyR_mode" == "2" ] && iptables -t nat -I PREROUTING "$PR_NU" -p tcp -m set --match-set black_koolproxy dst -j KOOLPROXY
}


dns_takeover(){
	ss_chromecast=`uci -q get shadowsocks.@global[0].dns_53`
	ss_enable=`iptables -t nat -L PREROUTING | grep SHADOWSOCKS |wc -l`
	[ -z "$ss_chromecast" ] && ss_chromecast=0
	lan_ipaddr=`uci get network.lan.ipaddr`
	#chromecast=`iptables -t nat -L PREROUTING -v -n|grep "dpt:53"`
	chromecast_nu=`iptables -t nat -L PREROUTING -v -n --line-numbers|grep "dpt:53"|awk '{print $1}'`
	is_right_lanip=`iptables -t nat -L PREROUTING -v -n --line-numbers|grep "dpt:53" |grep "$lan_ipaddr"`
	if [[ "$koolproxyR_mode_enable" == "1" ]]; then
		if [[ "$koolproxyR_mode" == "3" ]]; then
			if [ -z "$chromecast_nu" ]; then
				echo_date 黑名单模式开启DNS劫持
				iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
			else
				if [ -z "$is_right_lanip" ]; then
					echo_date 黑名单模式开启DNS劫持
					iptables -t nat -D PREROUTING $chromecast_nu >/dev/null 2>&1
					iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
				else
					echo_date DNS劫持规则已经添加，跳过~
				fi
			fi
		else
			if [[ "$ss_chromecast" != "1" ]] || [["$ss_enable" -eq 0 ]]; then
				if [ -n "$chromecast_nu" ]; then
					echo_date 全局过滤模式下删除DNS劫持
					iptables -t nat -D PREROUTING $chromecast_nu >/dev/null 2>&1
				fi
			fi
		fi	
	else	
		if [[ "$koolproxyR_base_mode" == "2" ]]; then
			if [ -z "$chromecast_nu" ]; then
				echo_date 黑名单模式开启DNS劫持
				iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
			else
				if [ -z "$is_right_lanip" ]; then
					echo_date 黑名单模式开启DNS劫持
					iptables -t nat -D PREROUTING $chromecast_nu >/dev/null 2>&1
					iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to $lan_ipaddr >/dev/null 2>&1
				else
					echo_date DNS劫持规则已经添加，跳过~
				fi
			fi
		else
			if [[ "$ss_chromecast" != "1" ]] || [["$ss_enable" -eq 0 ]]; then
				if [ -n "$chromecast_nu" ]; then
					echo_date 全局过滤模式下删除DNS劫持
					iptables -t nat -D PREROUTING $chromecast_nu >/dev/null 2>&1
				fi
			fi
		fi
	fi
} 

detect_cert(){
	if [ ! -f $KP_DIR/data/private/ca.key.pem -o ! -f $KP_DIR/data/certs/ca.crt ]; then
		echo_date 开始生成koolproxyR证书，用于https过滤！
		cd $KP_DIR/data && sh gen_ca.sh
	fi
}

set_lock(){
	exec 1000>"$LOCK_FILE"
	flock -x 1000
}

unset_lock(){
	flock -u 1000
	rm -rf "$LOCK_FILE"
}

my_rule_diy(){
	if [ -f /koolshare/scripts/KoolProxyR_my_rule_diy.sh ]; then
		chmod 777 /koolshare/scripts/KoolProxyR_my_rule_diy.sh
		sh /koolshare/scripts/KoolProxyR_my_rule_diy.sh mydiy
	fi
}

new_kpr_version(){
	url_version="https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/version"
	wget --no-check-certificate --timeout=8 -qO - $url_version > /tmp/version
	koolproxyR_installing_version=`cat /tmp/version  | sed -n '1p'`
	echo_date 获取到最新在线版本为：$koolproxyR_installing_version！
	dbus set koolproxyR_new_install_version=$koolproxyR_installing_version
	rm -rf /tmp/version
	echo_date 请和koolproxy二选一，因为我会打开koolproxy开关来，骗过V2RAY
}

ss_v2ray_game_restrt(){
	SS_ENABLE=`dbus get ss_basic_enable`
	V2_ENABLE=`dbus get v2ray_basic_enable`
	KG_ENABLE=`dbus get koolgame_basic_enable`
	koolclash_ENABLE=`dbus get koolclash_enable`
	if [[ "$SS_ENABLE" == "1" ]]; then
		echo_date ================== 以下为SS日志 =================
		/koolshare/ss/ssstart.sh restart >> /tmp/upload/kpr_log.txt
		echo_date ================== 以上为SS日志 =================
		echo_date 检测到SS开启，重启了你的SS插件以适应KPR的开启与关闭！
	fi
	if [[ "$V2_ENABLE" == "1" ]]; then
		# 顺带检查到，自启服务脚本写错了，干脆我写成控制文件
		echo_date ================== 以下为V2RAY日志 =================
		/koolshare/scripts/v2ray_config.sh restart
		echo_date ================== 以上为V2RAY日志 =================
		echo_date 检测到V2RAY开启，重启了你的V2RAY插件以适应KPR的开启与关闭！
	fi
	if [[ "$KG_ENABLE" == "1" ]]; then
		# 顺带检查到，自启服务脚本写错了，干脆我写成控制文件
		echo_date ================== 以下为koolgame日志 =================
		/koolshare/scripts/koolgame_config.sh restart
		echo_date ================== 以上为koolgame日志 =================
		echo_date 检测到koolgame开启，重启了你的koolgame插件以适应KPR的开启与关闭！
	fi
	if [[ "$koolclash_ENABLE" == "1" ]]; then
		# echo_date ================== 以下为koolclash日志 =================
		# /koolshare/scripts/koolclash_control.sh stop
		# dbus set koolclash_enable=1
		# /koolshare/scripts/koolclash_control.sh start
		# echo_date ================== 以上为koolclash日志 =================
		# echo_date 检测到koolclash开启，重启了你的koolclash插件以适应KPR的开启与关闭！
		echo_date 检测到koolclash开启，等koolclash兼容KP后开放此功能！
	fi
}

case $1 in
start)
	set_lock
	echo_date ================== koolproxyR启用 =================
	rm -rf /tmp/upload/user.txt && ln -sf $KSROOT/koolproxyR/data/rules/user.txt /tmp/upload/user.txt
	my_rule_diy
	detect_cert
	start_koolproxy
	add_ipset_conf && restart_dnsmasq
	creat_ipset
	add_white_black_ip
	load_nat
	dns_takeover
	write_nat_start
	write_reboot_job
	echo_date =================================================
	unset_lock
	new_kpr_version
	# 伪装KP的开启，骗过V2RAY
	dbus set koolproxy_enable=1
	ss_v2ray_game_restrt
	;;
restart)
	set_lock
	# now stop
	echo_date ================== 关闭 =================
	rm -rf /tmp/upload/user.txt && ln -sf $KSROOT/koolproxyR/data/rules/user.txt /tmp/upload/user.txt
	remove_reboot_job
	del_dns_takeover
	remove_ipset_conf
	remove_nat_start
	flush_nat
	stop_koolproxy
	# now start
	echo_date ================== koolproxyR启用 =================
	my_rule_diy
	detect_cert
	start_koolproxy
	add_ipset_conf && restart_dnsmasq
	creat_ipset
	add_white_black_ip
	load_nat
	dns_takeover
	creat_start_up
	write_nat_start
	write_reboot_job
	echo_date koolproxyR启用成功，请等待日志窗口自动关闭，页面会自动刷新...
	echo_date =================================================
	unset_lock
	new_kpr_version
	# 伪装KP的开启，骗过V2RAY
	dbus set koolproxy_enable=1
	ss_v2ray_game_restrt
	;;
stop)
	set_lock
	remove_reboot_job
	del_dns_takeover
	remove_ipset_conf && restart_dnsmasq
	remove_nat_start
	flush_nat
	stop_koolproxy
	unset_lock
	new_kpr_version
	# 伪装KP的关闭，骗过V2RAY
	dbus set koolproxy_enable=0
	ss_v2ray_game_restrt
	;;
*)
	set_lock
	flush_nat
	creat_ipset
	add_white_black_ip
	load_nat
	dns_takeover
	unset_lock
	new_kpr_version
	ss_v2ray_game_restrt
	;;
esac
