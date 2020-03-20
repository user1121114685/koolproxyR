<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/
For use with Tomato Firmware only.
No part of this file may be used without permission.
-->
<title>KoolProxyR</title>
<content>
<script type="text/javascript" src="/js/jquery.min.js"></script>
<script type="text/javascript" src="/js/tomato.js"></script>
<script type="text/javascript" src="/js/advancedtomato.js"></script>
<script type="text/javascript" src="/layer/layer.js"></script>
<style type="text/css">
	#kpr_debug_management label.control-left-label{
		width: 0%
	}
</style>
<script type="text/javascript">
var softcenter = 0;
var dbus;
get_arp_list();
get_dbus_data();
var options_type = [];
var options_list = [];
var option_arp_list = [];
var option_arp_local = [];
var option_arp_web = [];
var _responseLen;
var noChange = 0;
var reload = 0;
var option_day_time = [["7", "每天"], ["1", "周一"], ["2", "周二"], ["3", "周三"], ["4", "周四"], ["5", "周五"], ["6", "周六"], ["0", "周日"]];
var option_time_hour = [];
for(var i = 0; i < 24; i++){
	option_time_hour[i] = [i, i + "点"];
}
var option_reboot_hour = [];
var option_reboot_inter = [];
for(var i = 0; i < 24; i++){
	option_reboot_hour[i] = [i, i + "时"];
}
for(var i = 0; i < 72; i++){
	option_reboot_inter[i] = [i + 1, i + 1 + "时"];
}
tabSelect('app1');
if(typeof btoa == "Function") {
	Base64 = {encode:function(e){ return btoa(e); }, decode:function(e){ return atob(e);}};
} else {
	Base64 ={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/\r\n/g,"\n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}
}

// 开始检查KPR软件是否更新
$.ajax({
	// url: "https://dev.tencent.com/u/shaoxia1991/p/koolproxyr/git/raw/master/version",
	url: "https://raw.githubusercontent.com/user1121114685/koolproxyR/master/version",
	method: 'GET',
	async: true,
	cache: false,
	success: (resp) => {
		let data_version = resp.split('\n');
		// 以 换行符分割数据为一组 其中第一个是 [0] 第二个是[1]
		// var kpr_installing_version = data_version[0];
		// var kpr_installing_md5 = data_version[1];
		locversion = dbus["koolproxyR_version"];
		// 这里调用本地参数 与 dubs get 同理
		if (locversion != data_version[0]) {
			// data_version[0] 表示组的第1个数
			$("#update").show();
				layer.open({
					type: 1,
					title: false,
					closeBtn: false,
					area: '500px;',
					shade: 0.8,
					scrollbar: false,
					id: 'update_koolproxyR',
					// 鬼知道这个id 什么意思！！
					btn: ['更新', '关闭'],
					btnAlign: 'c',
					moveType: 1,
					content: '<div style="padding: 50px; line-height: 22px; background-color: #393D49; color: #fff; font-weight: 300;">\
								<b>KoolProxyR更新提醒！</b><br><br><br>\
								如你所见，KoolProxyR又双叒叕更新了！<br>\
								KoolProxyR更新至' + data_version[0] + '~<br><br>\
								● 更新日志详情<a style="color:#33CCCC" target="_blank" href="https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/Changelog.txt">请戳我了解~</a><br><br>\
								● 长期召集懂abp去广告规则的热心人士<br>\
								● 长期召集懂反编译或者擅长抓包的热心人士<br><br>\
								我们的征途是星辰大海 ^_^</div>',
					success: function(layero) {
						var btn = layero.find('.layui-layer-btn');
						$(".layui-layer-btn0").click(function () {
							update_KPR();
							// 原来调用已经定义的 function 就是如此简单。。。（）内加子项目参数即可
						});
					}
				});
	}
}
});

//============================================
var kpacl = new TomatoGrid();

kpacl.exist = function( f, v ) {
	var data = this.getAllData();
	for ( var i = 0; i < data.length; ++i ) {
		if ( data[ i ][ f ] == v ) return true;
	}
	return false;
}
kpacl.dataToView = function( data ) {
	if (data[0]){
		return [ "【" + data[0] + "】", data[1], data[2], ['不过滤', 'HTTP过滤模式', 'HTTP/HTTPS双过滤模式', '黑名单模式', 'HTTP/HTTPS双黑名单模式', '全端口模式'][data[3]] ];
	}else{
		if (data[1]){
			return [ "【" + data[1] + "】", data[1], data[2], ['不过滤', 'HTTP过滤模式', 'HTTP/HTTPS双过滤模式', '黑名单模式', 'HTTP/HTTPS双黑名单模式', '全端口模式'][data[3]] ];
		}else{
			if (data[2]){
				return [ "【" + data[2] + "】", data[1], data[2], ['不过滤', 'HTTP过滤模式', 'HTTP/HTTPS双过滤模式', '黑名单模式', 'HTTP/HTTPS双黑名单模式', '全端口模式'][data[3]] ];
			}
		}
	}
}
kpacl.fieldValuesToData = function( row ) {
	var f = fields.getAll( row );
	//alert(dbus["koolproxyR_portctrl_mode"]);
	if (f[0].value){
		return [ f[0].value, f[1].value, f[2].value, f[3].value ];
	}else{
		if (f[1].value){
			return [ f[1].value, f[1].value, f[2].value, f[3].value ];
		}else{
			if (f[1].value){
				return [ f[2].value, f[1].value, f[2].value, f[3].value ];
			}
		}
		
	}
}
kpacl.onChange = function(which, cell) {
	return this.verifyFields((which == 'new') ? this.newEditor: this.editor, true, cell);
}
kpacl.verifyFields = function( row, quiet, cell) {
	var f = fields.getAll( row );
	if ( $(cell).attr("id") == "_[object HTMLTableElement]_1" ) {
		if (f[0].value){
			f[1].value = option_arp_list[f[0].selectedIndex][2];
			f[2].value = option_arp_list[f[0].selectedIndex][3];
		}
	}
	
	if (f[1].value && !f[2].value){
		return v_ip( f[1], quiet );
	}
	if (!f[1].value && f[2].value){
		return v_mac( f[2], quiet );
	}
	if (f[1].value && f[2].value){
		return v_ip( f[1], quiet ) || v_mac( f[2], quiet );
	}
	if (f[0].value == "自定义"){
		console.log("sucess!");
		kpacl.updateUI;
	}
}
kpacl.onAdd = function() {
	var data;
	this.moving = null;
	this.rpHide();
	if (!this.verifyFields(this.newEditor, false)) return;
	data = this.fieldValuesToData(this.newEditor);
	this.insertData(1, data);
	this.disableNewEditor(false);
	this.resetNewEditor();
}
kpacl.resetNewEditor = function() {
	var f;
	f = fields.getAll( this.newEditor );
	ferror.clearAll( f );
	f[ 0 ].value = '';
	f[ 1 ].value   = '';
	f[ 2 ].value   = '';
	f[ 3 ].value   = '1';
}
kpacl.setup = function() {
	this.init( 'ctrl-grid', 'delete', 500, [
	{ type: 'select',maxlen:50,options:option_arp_list },
	{ type: 'text', maxlen: 50 },
	{ type: 'text', maxlen: 50 },
	{ type: 'select',maxlen:20,options:[['0', '不过滤'], ['1', 'HTTP过滤模式'], ['2', 'HTTP/HTTPS双过滤模式'], ['3', '黑名单模式'], ['4', 'HTTP/HTTPS双黑名单模式'], ['5', '全端口模式']], value: '1' }
	] );

	this.headerSet( [ '主机别名', '主机IP地址', 'MAC地址', '过滤模式控制' ] );
//			this.footerSet( [ '', '', '', ('')]);
	if(typeof(dbus["koolproxyR_acl_list"]) != "undefined" ){
		var s = dbus["koolproxyR_acl_list"].split( '>' );
	}else{
		var s =""
		return false;
	}
//			dbus.koolproxyR_acl_mode = E('_koolproxyR_acl_mode').value;
//			if(typeof(dbus["koolproxyR_acl_mode"]) != "undefined" ){
//			E("_koolproxyR_acl_mode").value = dbus["koolproxyR_acl_mode"];
//			}
	for ( var i = 0; i < s.length; ++i ) {
		var t = s[ i ].split( '<' );
		if ( t.length == 4 ) this.insertData( -1, t );
	}
	this.showNewEditor();
	this.resetNewEditor();
}
//============================================

function init_kp(){
	verifyFields();
	//kpacl.setup(dbus);
	set_version();
	get_user_txt();
	$("#_koolproxyR_log").click(
		function() {
			x = -1;
	});
	setTimeout("get_run_status();", 1000);
	setTimeout("get_rules_status();", 1000);	
}

function get_arp_list(){
	var id = parseInt(Math.random() * 100000000);
	var postData1 = {"id": id, "method": "KoolProxyR_getarp.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async:true,
		cache:false,
		data: JSON.stringify(postData1),
		dataType: "json",
		success: function(response){
			if (response){
				get_dbus_data();
				//var s2 = response.result.split( '>' );
				var s2 = dbus["koolproxyR_arp"].split( '>' );
				//console.log("s2", s2);
				for ( var i = 0; i < s2.length; ++i ) {
					option_arp_local[i] = [s2[ i ].split( '<' )[0],"【" + s2[ i ].split( '<' )[0] + "】",s2[ i ].split( '<' )[1],s2[ i ].split( '<' )[2]];
				}
				
				//console.log("option_arp_local", option_arp_local);
				var s3 = dbus["koolproxyR_acl_list"].split( '>' );
				//console.log("s3", s3);
				for ( var i = 0; i < s3.length -1; ++i ) {
					option_arp_web[i] = [s3[ i ].split( '<' )[0],"【" + s3[ i ].split( '<' )[0] + "】",s3[ i ].split( '<' )[1],s3[ i ].split( '<' )[2]];
				}
				option_arp_web[s3.length -1] = ["自定义", "【自定义设备】","",""];
				//console.log("option_arp_web", option_arp_web);
				//option_arp_list = $.extend([],option_arp_local, option_arp_web);
				option_arp_list = unique_array(option_arp_local.concat( option_arp_web ));
				//console.log("option_arp_list", option_arp_list);
				kpacl.setup();
			}
		},
		error:function(){
			kpacl.setup();
		},
		timeout:1000
	});
}
function unique_array(array){
	var r = [];
	for(var i = 0, l = array.length; i < l; i++) {
		for(var j = i + 1; j < l; j++)
		if (array[i][0] === array[j][0]) j = ++i;
			r.push(array[i]);
	}
	return r.sort();;
}

function get_dbus_data(){
	$.ajax({
		type: "GET",
		url: "/_api/koolproxyR_",
		dataType: "json",
		async:false,
		success: function(data){
			dbus = data.result[0];
			setTimeout("get_log();", 500);	
		}
	});
}
function get_run_status(){
	var id5 = parseInt(Math.random() * 100000000);
	var postData1 = {"id": id5, "method": "KoolProxyR_status.sh", "params":[2], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData1),
		dataType: "json",
		success: function(response){
			if(softcenter == 1){
				return false;
			}
			document.getElementById("_koolproxyR_status").innerHTML = response.result.split("@@")[0];
			// document.getElementById("_koolproxyR_rule_status").innerHTML = response.result.split("@@")[1];
			setTimeout("get_run_status();", 1000);
		},
		error: function(){
			if(softcenter == 1){
				return false;
			}
			document.getElementById("_koolproxyR_status").innerHTML = "获取运行状态失败！";
			// document.getElementById("_koolproxyR_rule_status").innerHTML = "获取规则状态失败！";
			setTimeout("get_run_status();", 1000);
		}
	});
}

function get_rules_status(){
	var id6 = parseInt(Math.random() * 100000000);
	var postData2 = {"id": id6, "method": "KoolProxyR_rules_status.sh", "params":[2], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData2),
		dataType: "json",
		success: function(response){
			if(softcenter == 1){
				return false;
			}
			document.getElementById("_koolproxyR_third_rule_status").innerHTML = response.result.split("@@");
			setTimeout("get_rules_status();", 20000);
		},
		error: function(){
			if(softcenter == 1){
				return false;
			}
			document.getElementById("_koolproxyR_third_rule_status").innerHTML = "获取规则状态失败！";
			setTimeout("get_rules_status();", 10000);
		}
	});
}		

function download_cert(){
	location.href = "http://110.110.110.110";
}
function https_KP(){
	window.open("https://shaoxia.xyz/post/koolproxyr%E6%8C%87%E5%8D%97/");			
}	
function find_github(){
	window.open("https://github.com/user1121114685/koolproxyR.git");
}
function find_telegram(){
	window.open("https://t.me/koolproxyR");
}
function update_KPR(){
	var id2 = parseInt(Math.random() * 100000000);
	var postData2 = {"id": id2, "method": "KoolProxyR_update_now.sh", "params":[], "fields": ""};
	showMsg("msg_warring","正在提交数据！","<b>等待后台运行完毕，请不要刷新本页面！</b>");
	$.ajax({
		url: "/_api/",
		cache:false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData2),
		error: function(){
			showMsg("msg_error","失败","<b>当前系统存在异常查看系统日志！</b>");
		}
	});
	reload = 1;
	tabSelect("app8");

}
function issues_KP(){
	window.open("https://www.wjx.cn/jq/42669897.aspx");
	
}

function update_KPR_rule(){
	window.open("https://github.com/user1121114685/koolproxyR_rule_list/edit/master/kpr_our_rule.txt");
}
function update_KPR_rule_education(){
	window.open("https://shaoxia.xyz/post/koolproxyr%E8%A7%84%E5%88%99%E7%BC%96%E5%86%99%E6%95%99%E7%A8%8B/");
}

function verifyFields(){
	var a = E('_koolproxyR_enable').checked;
	var h = (E('_koolproxyR_mode_enable').value == '0');
	var s = (E('_koolproxyR_mode_enable').value == '1');
	E('_koolproxyR_mode_enable').disabled = !a;
	E('_koolproxyR_mode').disabled = !a;
	E('_koolproxyR_base_mode').disabled = !a;		
	E('_download_cert').disabled = !a;
	elem.display(PR('_koolproxyR_mode'), s);
	elem.display(PR('_koolproxyR_base_mode'), h);
	if (dbus["koolproxyR_portctrl_mode"]=="1"){
		var z = true;
	}else{
		var z = false;
		x = false;
	}
}

function tabSelect(obj){
	var tableX = ['app1-server1-jb-tab','app2-server1-fwlb-tab','app3-server1-kz-tab','app4-server1-zdy-tab','app5-server1-zsgl-tab','app6-server1-gzgl-tab','app7-server1-rzz-tap','app8-server1-rz-tab'];
	var boxX = ['boxr1','boxr2','boxr3','boxr4','boxr5','boxr6','boxr7','boxr8'];
	var appX = ['app1','app2','app3','app4','app5','app6','app7','app8'];
	for (var i = 0; i < tableX.length; i++){
		if(obj == appX[i]){
			$('#'+tableX[i]).addClass('active');
			$('.'+boxX[i]).show();
		}else{
			$('#'+tableX[i]).removeClass('active');
			$('.'+boxX[i]).hide();
		}
	}
	if(obj=='app8'){
		setTimeout("get_log();", 400);
		elem.display('save-button', false);
	}else{
		elem.display('save-button', true);
	}
	if(obj=='app7'){
		elem.display('save-button', false);
	}

}
function showMsg(Outtype, title, msg){
	$('#'+Outtype).html('<h5>'+title+'</h5>'+msg+'<a class="close"><i class="icon-cancel"></i></a>');
	$('#'+Outtype).show();
}

function toggleVisibility(whichone) {
	if (E('sesdiv' + whichone).style.display == '') {
		E('sesdiv' + whichone).style.display = 'none';
		E('sesdiv' + whichone + 'showhide').innerHTML = '<i class="icon-chevron-up"></i>';
		cookie.set('adv_dhcpdns_' + whichone + '_vis', 0);
	} else {
		E('sesdiv' + whichone).style.display = '';
		E('sesdiv' + whichone + 'showhide').innerHTML = '<i class="icon-chevron-down"></i>';
		cookie.set('adv_dhcpdns_' + whichone + '_vis', 1);
	}
}

function save(){

	verifyFields();
	// collect basic data
	dbus.koolproxyR_enable = E('_koolproxyR_enable').checked ? '1':'0';
	dbus.koolproxyR_mode_enable = E('_koolproxyR_mode_enable').value;			
	dbus.koolproxyR_base_mode = E('_koolproxyR_base_mode').value;			
	dbus.koolproxyR_mode = E('_koolproxyR_mode').value;
	dbus.koolproxyR_replenish_rules = E("_koolproxyR_replenish_rules").checked ? "1" : "0";
	dbus.koolproxyR_easylist_rules = E("_koolproxyR_easylist_rules").value;
	dbus.koolproxyR_video_rules = E("_koolproxyR_video_rules").checked ? "1" : "0";
	dbus.koolproxyR_fanboy_rules = E("_koolproxyR_fanboy_rules").value;

	// 更新规则
	dbus.koolproxyR_basic_easylist_update = E("_koolproxyR_basic_easylist_update").checked ? "1" : "0";
	dbus.koolproxyR_basic_replenish_update = E("_koolproxyR_basic_replenish_update").checked ? "1" : "0";
	dbus.koolproxyR_basic_video_update = E("_koolproxyR_basic_video_update").checked ? "1" : "0";
	dbus.koolproxyR_basic_fanboy_update = E("_koolproxyR_basic_fanboy_update").checked ? "1" : "0";
	// 自定义规则
	dbus["koolproxyR_custom_rule"] = Base64.encode(document.getElementById("_koolproxyR_custom_rule").value);
	// collect data from acl pannel
	var data2 = kpacl.getAllData();
	if(data2.length > 0){
		dbus["koolproxyR_acl_node_max"] = data2.length;
	}else{
		dbus["koolproxyR_acl_node_max"] = "";
	}
	var acllist = '';
	if(data2.length > 0){
		for ( var i = 0; i < data2.length; ++i ) {
			acllist += data2[ i ].join( '<' ) + '>';
		}
		dbus["koolproxyR_acl_list"] = acllist;
	}else{
		dbus["koolproxyR_acl_list"] = " ";
	}
	if(dbus["koolproxyR_acl_list"].indexOf('<5')!=-1){
		dbus.koolproxyR_portctrl_mode = '1';
	}else{
		dbus.koolproxyR_portctrl_mode = '0';
	}

	// post data
	var id3 = parseInt(Math.random() * 100000000);
	var postData3 = {"id": id3, "method": "KoolProxyR_config.sh", "params":["restart"], "fields": dbus};
	showMsg("msg_warring","正在提交数据！","<b>等待后台运行完毕，请不要刷新本页面！</b>");
	$.ajax({
		url: "/_api/",
		cache:false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData3),
		success: function(response){
			if(response){
				setTimeout("window.location.reload()", 500);
				return true;
			}
		}
	});
	tabSelect("app8");
}

function get_log(){
	$.ajax({
		url: '/_temp/kpr_log.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("_koolproxyR_log");
			if (response.search("XU6J03M6") != -1) {
				retArea.value = response.replace("XU6J03M6", " ");
				retArea.scrollTop = retArea.scrollHeight;
				if (reload == 1){
					setTimeout("window.location.reload()", 1200);
					return true;
				}else{
					return true;
				}
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 1000) {
				tabSelect("app1");
				return false;
			} else {
				setTimeout("get_log();", 200);
			}
			retArea.value = response.replace("XU6J03M6", " ");
			retArea.scrollTop = retArea.scrollHeight;
			_responseLen = response.length;
		}
	});
}
function get_user_txt() {
	$.ajax({
		url: '/_temp/user.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#_koolproxyR_custom_rule').val(res);
		}
	});
}
function kp_cert_0(script, arg){
	tabSelect("app8");
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			console.log("id", id);
			console.log("response", response);
			if (response.result == id){
				if (arg == 3){
					console.log("333");
					var a = document.createElement('A');
					a.href = "/files/ca_0.tar.gz";
					a.download = 'ca_0.tar.gz';
					document.body.appendChild(a);
					a.click();
					document.body.removeChild(a);
				}else if (arg == 2){
					setTimeout("window.location.reload()", 1000);
				}
			}
		}
	});
}
function kp_cert(script, arg){
	tabSelect("app8");
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			console.log("id", id);
			console.log("response", response);
			if (response.result == id){
				if (arg == 1){
					console.log("333");
					var a = document.createElement('A');
					a.href = "/files/koolproxyca.tar.gz";
					a.download = 'koolproxyCA.tar.gz';
					document.body.appendChild(a);
					a.click();
					document.body.removeChild(a);
				}else if (arg == 2){
					setTimeout("window.location.reload()", 1000);
				}
			}
		}
	});
}

function kpr_debug_0(script, arg){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			return true;
		}
	});
	reload = 1;
	tabSelect("app8");
}

function kpr_debug_1(script, arg){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			return true;
		}
	});
	reload = 1;
	tabSelect("app8");
}

function kpr_debug_2(script, arg){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			return true;
		}
	});
	reload = 1;
	tabSelect("app8");
}

function kpr_debug_3(script, arg){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			return true;
		}
	});
	reload = 1;
	tabSelect("app8");
}

function kpr_debug_4(script, arg){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			return true;
		}
	});
	reload = 1;
	tabSelect("app8");
}

function restore_cert(){
	var filename = $("#file").val();
	filename = filename.split('\\');
	filename = filename[filename.length-1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length-1];
	if(filelast !='gz'){
		alert('恢复文件格式不正确！');
		return false;
	}
	var formData = new FormData();
	formData.append('koolproxyCA.tar.gz', $('#file')[0].files[0]);
	$('.popover').html('正在恢复，请稍后……');
	//changeButton(true);
	$.ajax({
		url: '/_upload',
		type: 'POST',
		async: true,
		cache:false,
		data: formData,
		processData: false,
		contentType: false,
		complete:function(res){
			if(res.status==200){
				kp_cert('KoolProxyR_cert.sh', 2);
			}
		}
	});
}

function update_rules_now(arg){
	var	shellscript = 'KoolProxyR_rule_update.sh';
	var id1 = parseInt(Math.random() * 100000000);
	var postData1 = {"id": id1, "method": shellscript, "params":[arg], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData1),
		dataType: "json",
		success: function(response){
			if(response){
				setTimeout("window.location.reload()", 2000);
				return true;
			}
		}
	});
	tabSelect("app8");
}

function set_version() {

	$('#_koolproxyR_version').html('<img src="/res/icon_koolproxyR-v.png">');
}
	
</script>

<div class="box">
<div class="heading">
<span id="_koolproxyR_version"></span>
<a href="#/soft-center.asp" class="btn" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">返回</a>
<a href="https://shaoxia1991.coding.net/p/koolproxyr/d/koolproxyr/git/raw/master/Changelog.txt" target="_blank" class="btn btn-primary" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">更新日志</a>
<!-- <a href="#/Module_koolproxyR_simple.asp" target="_blank" class="btn btn-primary" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">简化版</a> -->
</div>
<div class="content"><span class="col"  style="line-height:30px;width:700px">
	<font color="#808080">KoolProxyR为免费开源软件，追求体验更快、更清洁的网络，屏蔽烦人的广告 ！</font></span>


	
</div>
<div class="box" style="margin-top: 0px;">
<div class="heading">
</div>
<div class="content">
	<div id="koolproxyR_switch_pannel" class="section" style="margin-top: -20px;"></div>
	<script type="text/javascript">
		$('#koolproxyR_switch_pannel').forms([
			{ title: '开启KoolProxyR', name:'koolproxyR_enable',type:'checkbox',value: dbus.koolproxyR_enable == 1 } 
		]);
	</script>
	<hr />
	<fieldset id="koolproxyR_status_pannel">
		<label class="col-sm-3 control-left-label" for="_undefined">KoolProxyR运行状态</label>
		<div class="col-sm-9" style="margin-top:2px">
			<font id="_koolproxyR_status" name="_koolproxyR_status" color="#1bbf35">正在检查运行状态...（推荐使用chrome内核浏览器打开）</font>
		</div>
	</fieldset>
</div>
</div>	
<!-- ------------------ 标签页 --------------------- -->	
<ul class="nav nav-tabs" style="margin-bottom: 20px;">
<li><a href="javascript:void(0);" onclick="tabSelect('app1');" id="app1-server1-jb-tab" class="active"><i class="icon-system"></i> 基本设置</a></li>
<li><a href="javascript:void(0);" onclick="tabSelect('app2');" id="app2-server1-fwlb-tab"><i class="icon-cloud"></i>玩不转？</a></li>		
<li><a href="javascript:void(0);" onclick="tabSelect('app3');" id="app3-server1-kz-tab"><i class="icon-tools"></i> 访问控制</a></li>		
<li><a href="javascript:void(0);" onclick="tabSelect('app4');" id="app4-server1-zdy-tab"><i class="icon-hammer"></i> 自定义规则</a></li>
<li><a href="javascript:void(0);" onclick="tabSelect('app5');" id="app5-server1-zsgl-tab"><i class="icon-lock"></i> 证书管理</a></li>
<li><a href="javascript:void(0);" onclick="tabSelect('app6');" id="app6-server1-gzgl-tab"><i class="icon-cmd"></i> 规则状态</a></li>
<li><a href="javascript:void(0);" onclick="tabSelect('app7');" id="app7-server1-rzz-tap"><i class="icon-wake"></i> 附加设置</a></li>
<li><a href="javascript:void(0);" onclick="tabSelect('app8');" id="app8-server1-rz-tab"><i class="icon-info"></i> 日志信息</a></li>
</ul>
<div class="box boxr1" style="margin-top: 0px;">
<div class="content"></div>
	<div id="identification" class="section"></div>
	<script type="text/javascript">
		$('#identification').forms([
			{ title: '开启进阶模式', name:'koolproxyR_mode_enable',type:'select',options:[['0','关闭'],['1','开启']],value: dbus.koolproxyR_mode_enable || "0",suffix: '<font color="#FF0000">【进阶模式】&nbsp;&nbsp;提供更多设置选项</font>' },
			{ title: '全局默认过滤模式', name:'koolproxyR_base_mode',type:'select',options:[['0','不过滤'],['1','HTTP过滤模式'],['2','黑名单模式']],value: dbus.koolproxyR_base_mode || "1",suffix: '<font color="#FF0000">【开启进阶模式】&nbsp;&nbsp;获得更多选项！</font>' },
			{ title: '进阶默认过滤模式', name:'koolproxyR_mode',type:'select',options:[['0','不过滤'],['1','HTTP过滤模式'],['2','HTTP/HTTPS双过滤模式'],['3','黑名单模式'],['4','HTTP/HTTPS双黑名单模式']],value: dbus.koolproxyR_mode || "1",suffix: '<font color="#FF0000">一般开启HTTP过滤模式即可，去视频广告请在&nbsp;&nbsp;访问控制中给设备指定【HTTP/HTTPS双过滤模式】</font>' },
			{ title: '证书下载', suffix: ' <button id="_download_cert" onclick="download_cert();"style="border-radius: 20px"  class="btn btn-danger">证书下载</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="https_KP();" style="border-radius: 20px" class="btn btn-success">相关教程</button>' },
			{ title: '交流渠道', suffix: ' <button onclick="issues_KP();" style="border-radius: 20px" class="btn btn-danger">建议反馈</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="find_telegram();"style="border-radius: 20px"  class="btn btn-danger">加入TG群</button>'  },
			{ title: '项目信息', suffix: ' <button id="_find_github" onclick="find_github();"style="border-radius: 20px"  class="btn">开源地址</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="update_KPR();"style="border-radius: 20px"  class="btn">更新插件</button>' },

		]);
	</script>
</div>
</div>
<div id="kp_mode_readme" class="box boxr1" style="margin-top: 15px;">
<div class="heading">友情提示<a class="pull-right" data-toggle="tooltip" title="Hide/Show Notes" href="javascript:toggleVisibility('notes');"><span id="sesdivnotesshowhide"><i class="icon-chevron-up"></i></span></a></div>
<div class="section content" id="sesdivnotes">
	<li>不管你多么优秀，请一定注意以下几件事。</li>	
	<li>--------------------------------------------------------------------------</li>	
	<li>一，请不要随意开启全端口模式和黑名单模式，除非你知道你在做什么。</li>		
	<li>二，请给设备正确安装https证书，如果证书不正确，kpr也就废了。</li>
	<li>三，遇到搞不定的事情，请及时到tg群反馈。kpr的tg群。</li>
	<li>--------------------------------------------------------------------------</li>	
</div>
</div>
<div class="box boxr2" style="margin-top: 10px;">
	<div class="heading">开发者带你玩转KoolProxyR：</div>
	<div class="content">
		<fieldset>
			<div class="col-sm-10">
				<ul style="margin-left: 30px;">
					<li><font color="#FF6347"> 问： </font>KoolProxyR的R是日的意思吗？</li>
					<li><font color="#1E90FF"> 答： </font>是的，日死所有广告。</li>	
					<br><hr>	
					<li><font color="#FF6347"> &nbsp;&nbsp;&nbsp;&nbsp;一个新手的标准流程</font></li>
					<li><font color="#1E90FF"> 1， </font>在【基本设置】中默认HTTP过滤模式，此模式表示除【访问控制】以外的机子走的过滤模式。</li>			
					<li><font color="#1E90FF"> 2， </font>在【规则状态】中勾选合适的规则。</li>			
					<li><font color="#1E90FF"> 3， </font>给【HTTP/HTTPS双过滤模式】的机子正确安装证书。（详情请完整阅读本页）</li>			
					<li><font color="#1E90FF"> 4， </font>在【访问控制】中指定【HTTP/HTTPS双过滤模式】过滤的设备。</li>			
					<li><font color="#1E90FF"> 5， </font>善于使用【附加设置】--【开启-AD调试模式 】排除误杀情况，如果比较严重，欢迎提交规则，或者TG群反馈。</li>	
					<li><font color="#1E90FF"> 6， </font>如果您是大佬，可以自行DIY你需要的所有元素，并欢迎提交在github提交Pull requests。</li>					
					<br><hr>
					<li><font color="#FF6347"> 问： </font>这些模式有什么区别？</li>
					<li><font color="#1E90FF"> 答： </font>HTTP过滤模式，只过滤80端口，HTTP/HTTPS过滤80,443端口，全端口模式过滤所有端口，包含80，443。黑名单模式只过滤黑名单内的域名所以不建议使用。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>某些网站我不想去广告，或者某些网站屏蔽了，我的设备无法访问。</li>
					<li><font color="#1E90FF"> 答： </font>请使用&nbsp;&nbsp;@@|&nbsp;&nbsp;或者@@@@|&nbsp;&nbsp;对域名进行放行，http访问的网站@@|http://xxx.yyy.com&nbsp;&nbsp;&nbsp;&nbsp;https访问的网站@@@@|https://drive.google.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;【自定义规则】中进行设置。如果你觉得这个规则影响了更多人，请反馈，或者提交规则到kpr，提交的规则将在KPR主规则中，惠及所有KPR用户。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>HTTPS过滤一定要安装证书吗？</li>
					<li><font color="#1E90FF"> 答： </font>必须安装证书，而且必须正确安装证书。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我想自动升级KoolProxyR版本可以吗？</li>
					<li><font color="#1E90FF"> 答： </font>在【系统】--【计划任务】的末尾回车添加上下面这行的代码保存即可。</li>
					<li>0 4 * * * /koolshare/scripts/KoolProxyR_update_now.sh update_kpr</li>
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我是安卓7.0以上的系统，我安装了证书,开启Https导致部分APP打开提示没有网络了！</li>
					<li><font color="#1E90FF"> 答： </font>请在【证书管理】中下载0.根证书的zip文件，解压出来放入下面的两个地方。PS 如何放入，如何root之类的话题，请在到专业论坛讨论。</li>
					<li>/system/etc/security/cacerts&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/system/etc/security/cacerts_google</li>
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我的安卓手机，刷机后卡开机界面了。谷歌服务哪点一直过不了。</li>
					<li><font color="#1E90FF"> 答： </font>请在【访问控制】中给手机放行，或者，暂时关闭KPR！</li>
					<br><hr>
					<li><font color="#FF6347"> 问： </font>KoolProxyR为什么要重启SS,V2ray，koolgame？</li>
					<li><font color="#1E90FF"> 答： </font>是的，是需要重启来适应kpr的开关，这样才能让流量走kpr，而不会导致代理无效的问题，不需要手动重启代理。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>为什么梅林没有KoolProxyR?开发者歧视梅林吗？</li>
					<li><font color="#1E90FF"> 答： </font>不是的，kpr是为了更强更多规则而存在的，目前除了软路由几乎无解。梅林设备性能没有达标！</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>为什么安装了证书仍然，提示https不安全?</li>
					<li>Windows下面请安装的时候选择安装到&nbsp;&nbsp;[受信任的根证书颁发机构]</li>			
					<li>IOS设备，在设置---通用----关于手机里面信任证书</li>
					<li>MAC, 在 【钥匙串访问】中信任</li>
					<li>安卓7.0以上将.0根证书复制到【/system/etc/security/cacerts】&nbsp;&nbsp;【/system/etc/security/cacerts_google】中</li>
					<li>火狐浏览器用户，请分别在火狐内访问110.110.110.110，和使用其他浏览器访问110.110.110.110,并将证书安装到[受信任的根证书颁发机构]</li>
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我把kp的证书备份下来了kpr可以导入使用吗？</li>
					<li><font color="#1E90FF"> 答： </font>可以的，本来就是同源，可以相互导入导出证书来使用减少重复安装证书的过程。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我的规则更新，和更新插件十分缓慢？有解决办法吗？</li>
					<li><font color="#1E90FF"> 答： </font>你可以将，以下域名加入【LEDE】【SS V2RAY WG等代理软件】的【黑白名单】中【域名黑名单】。</li>			
					<li>raw.githubusercontent.com</li>
					<li>easylist-downloads.adblockplus.org</li>
					<li>secure.fanboy.co.nz</li>
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我开启了fanboy全规则版本，为什么我打开网页没有以前流畅了。</li>
					<li><font color="#1E90FF"> 答： </font>这个版本由于规则太多对不是重度国外网站使用的你来讲，确实不必要勾选，如果常年逛国外网站，又卡，那你只勾选fanboy全规则版本，其他的都取消掉吧！</li>			
					<li>达成成就：成功榨干软路由</li>
					<br><hr>
					<li><font color="#FF6347"> 问： </font>我发现规则上下有重复的地方有影响吗？</li>
					<li><font color="#1E90FF"> 答： </font>没有的，这是因为不知道网站是http的还是https的，所以http与https都需要分别设置一次。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>有隐藏功能吗？</li>
					<li><font color="#1E90FF"> 答： </font>目前有自定义执行shell，和自定义证书名字2个功能。请参考更新日志内的说明。</li>			
					<br><hr>
					<li><font color="#FF6347"> 问： </font>KoolProxyR太棒了，我要捐赠！</li>
					<li><font color="#1E90FF"> 答： </font>谢谢大家好意，请捐赠给生活中其他需要帮助的人吧！或许这更重要！</li>			
					<br><hr>
				</ul>
			</div>
		</fieldset>
	</div>
</div>

<div class="box boxr3">
<div class="heading">访问控制</div>
<div class="content">
	<div class="tabContent">	
		<table class="line-table" cellspacing=1 id="ctrl-grid"></table>
	</div>		
	<br><hr>
	<h4>使用手册</h4>
	<div class="section" id="sesdiv_notes1">
		<li>过滤https站点广告需要为相应设备安装证书，并启用带HTTPS过滤的模式！</li>
		<li>【全端口模式】是包括443和80端口以内的全部端口进行过滤，如果被过滤的设备开启这个，也需要安装证书！</li>
		<li>需要自定义列表内没有的主机时，把【主机别名】留空，填写其它的即可！</li>
		<li>访问控制面板中【ip地址】和【mac地址】至少一个不能为空！只有ip时匹配ip，只有mac时匹配mac，两个都有一起匹配！</li>
		<li>在路由器下的设备，不管是电脑，还是补充，都可以在浏览器中输入<i><b>110.110.110.110</b></i>来下载证书。</i></li>
		<li>如果想在多台装有koolroxy的路由设备上使用一个证书，请用本插件的证书备份功能，并上传到另一台路由。</li>
		<li><font color="red">注意！【全端口模式】一般情况慎重选择，因为kpr支持非标准端口过滤，只要规则上有。</font></li>
		<li><font color="red">注意！【黑名单模式】一般情况下请无论如何都不要选，毕竟黑名单里面的规则不过毛毛雨。</font></li>
	</div>
	<br><hr>
</div>
</div>
<div class="box boxr4">
<div class="heading">自定义规则</div>
<div class="content">
	<div class="tabContent">
	<div class="section user_rule content"></div>
	<script type="text/javascript">
		y = Math.floor(docu.getViewSize().height * 0.75);
		s = 'height:' + ((y > 300) ? y : 300) + 'px;display:block';
		$('.section.user_rule').append('<textarea class="as-script" name="koolproxyR_custom_rule" id="_koolproxyR_custom_rule" wrap="off" style="max-width:100%; min-width: 100%; margin: 0; ' + s + '" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>');
	</script>
</div>
	</div>
</div>
</div>
<div class="box boxr5">
<div class="heading">证书管理</div>
<div class="content">
	<div id="kp_certificate_management" class="section"></div>
	<script type="text/javascript">
		$('#kp_certificate_management').forms([
			{ title: '证书备份', suffix: '<button onclick="kp_cert(\'KoolProxyR_cert.sh\', 1);" style="border-radius: 15px" class="btn btn-success">证书备份 <i class="icon-download"></i></button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="kp_cert_0(\'KoolProxyR_cert.sh\', 3);" style="border-radius: 15px" class="btn btn-success">生成 .0根证书 <i class="icon-download"></i></button><font color="#FF0000">【.0根证书】&nbsp;&nbsp;用于安卓7.0以上的设备安装HTTPS证书，详见教程。</font></lable>' },
			{ title: '证书恢复', suffix: '<input type="file" id="file" size="50">&nbsp;&nbsp;<button id="upload1" type="button"  onclick="restore_cert();" style="border-radius: 15px" class="btn btn-danger">上传并恢复 <i class="icon-cloud"></i></button>' }
		]);
	</script>
</div>
</div>
<div class="box boxr6">
<div class="heading">规则管理</div>
<div class="content">
	<div id="kp_rules_pannel" class="section"></div>
	<script type="text/javascript">
		$('#kp_rules_pannel').forms([
			// { title: '绿坝规则状态', text: '<font id="_koolproxyR_rule_status" name=_koolproxyR_status color="#1bbf35">正在获取规则状态...</font>' },
			{ title: '规则状态', text: '<font id="_koolproxyR_third_rule_status" name=_koolproxyR_status color="#1bbf35">正在获取规则状态...</font>' },	
			// { title: 'KPR  主规则', multi: [
			// 	{ name: 'koolproxyR_easylist_rules',type:'checkbox',value: dbus.koolproxyR_easylist_rules == '1', suffix: '<lable id="_kp_easylist">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;此规则由EasylistChina和CJX sAnnoyance 与KPR自定义规则组成，是KPR的首选规则.。</lable>&nbsp;&nbsp;' },
			// ]},	
			{ title: '主规则', name:'koolproxyR_easylist_rules',type:'select',options:[['1','KoolProxyR主规则'],['2','KoolProxy主规则'],['3','KoolProxy主规则+每日规则'],['4','关闭主规则']],value: dbus.koolproxyR_easylist_rules ||"1",suffix: '<font color="#FF0000">请选择一种你想要的规则</font>' },


			// { title: 'Fanboy规则（国外）', multi: [
			// 	{ name: 'koolproxyR_fanboy_rules',type:'checkbox',value: dbus.koolproxyR_fanboy_rules == '1', suffix: '<lable id="_kp_fanboy">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;此规则由Fanboy发起，针对国外主流令人厌烦的广告过滤。</lable>&nbsp;&nbsp;' }
			// ]},	
			// { title: 'Fanboy全规则版本', multi: [
			// 	{ name: 'koolproxyR_fanboy_all_rules',type:'checkbox',value: dbus.koolproxyR_fanboy_all_rules == '1', suffix: '<lable id="_kp_fanboy_all">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;【开启/关闭选项】--【保存】--【更新规则】就能将fanboy规则更新为最全的版本，低功耗CPU【万万不能开启】！</lable>&nbsp;&nbsp;' }
			// ]},	
			{ title: 'Fanboy主规则', name:'koolproxyR_fanboy_rules',type:'select',options:[['1','Fanboy规则（国外）'],['2','Fanboy全规则版本'],['3','关闭Fanboy规则']],value: dbus.koolproxyR_fanboy_rules ||"1",suffix: '<font color="#FF0000">请选择一种你想要的规则</font>' },
			{ title: '补充规则', multi: [
			{ name: 'koolproxyR_replenish_rules',type:'checkbox',value: dbus.koolproxyR_replenish_rules == '1', suffix: '<lable id="_kp_replenish_rules">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;此规则由vokins/yhosts整理的hosts包含移动设备和TV规则(建议开启)。</lable>&nbsp;&nbsp;' }
			]},
			{ title: '视频规则（加密）', multi: [
				{ name: 'koolproxyR_video_rules',type:'checkbox',value: dbus.koolproxyR_video_rules == '1', suffix: '<lable id="_kp_abx">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;此规则可以屏蔽国内网站的视频广告，需HTTPS模式。</lable>&nbsp;&nbsp;' },
			]},	

			{ title: '规则更新', multi: [
				{ name:'koolproxyR_basic_easylist_update',type:'checkbox',value: dbus.koolproxyR_basic_easylist_update == '1', suffix: '<lable id="_koolproxyR_basic_easylist_update_txt">主规则</lable>&nbsp;&nbsp;' },
				{ name:'koolproxyR_basic_replenish_update',type:'checkbox',value: dbus.koolproxyR_basic_replenish_update == '1', suffix: '<lable id="_koolproxyR_basic_replenish_update_txt">补充规则</lable>&nbsp;&nbsp;' },
				{ name:'koolproxyR_basic_video_update',type:'checkbox',value: dbus.koolproxyR_basic_video_update == '1', suffix: '<lable id="_koolproxyR_basic_video_update_txt">KP视频规则</lable>&nbsp;&nbsp;' },
				{ name:'koolproxyR_basic_fanboy_update',type:'checkbox',value: dbus.koolproxyR_basic_fanboy_update == '1', suffix: '<lable id="_koolproxyR_basic_fanboy_update_txt">Fanboy规则</lable>&nbsp;&nbsp;' },
                { suffix: '<button id="_update_rules_now"style="border-radius: 15px""background-color:#EAADEA"  onclick="update_rules_now(5);" class="btn btn-success">手动更新 <i class="icon-cloud"></i></button>' },

			]},	
			{ title: '为KoolProxyR贡献规则', suffix: '<font color="#FF0000">通过此链接贡献的规则，将服务更多的KPR用户。方便更多人</font>&nbsp;&nbsp;&nbsp;<button onclick="update_KPR_rule();" style="border-radius: 15px" class="btn">提交规则</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="update_KPR_rule_education();" style="border-radius: 15px" class="btn">提交规则教程</button>' }
		]);

	</script>
	<br><hr>
	<h4>规则管理说明</h4>
		<div class="section" id="sesdiv_notes2">
		<li> KoolProxyR请根据自己的实际情况选择使用。</li>
		<li><font color="green"> 【冲突解决】</font>尝试下少勾选部分规则，看看是否好转。。</li>
		<li> 如果遇到问题，或者更好的规则请记得向KPR反馈。</li>
		<li><font color="red"> 规则都是从网上收集，可能更新后会出现问题，不要慌，反馈一下就好了。</font></li>
	</div> 
	<br><hr>			
</div>
</div>
<div class="box boxr7">
<div class="heading">附加功能</div>
<div class="content">
<div id="kpr_debug_management" class="section"></div>
	<script type="text/javascript">
		$('#kpr_debug_management').forms([
		{ title: '', suffix: '<button onclick="kpr_debug_0(\'KoolProxyR_debug.sh\', 0);" style="border-radius: 15px" class="btn btn-success">规则调试模式 </button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="kpr_debug_1(\'KoolProxyR_debug.sh\', 1);" style="border-radius: 15px" class="btn btn-success">开启-INFO调试模式 </button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="kpr_debug_2(\'KoolProxyR_debug.sh\', 2);" style="border-radius: 15px" class="btn btn-success">开启-AD调试模式 </button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="kpr_debug_3(\'KoolProxyR_debug.sh\', 3);" style="border-radius: 15px" class="btn btn-success">开启-全调试模式 </button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="kpr_debug_4(\'KoolProxyR_debug.sh\', 4);" style="border-radius: 15px" class="btn btn-success">关闭调试模式</button></lable>' },
		]);
	</script>
	<br><hr>
	<h4>附加设置功能说明</h4>
		<div class="section" id="sesdiv_notes3">
		<br><hr>
		<li>这是一个抓包，排错，编写规则的辅助工具，强大之人掌握，必能发挥其威力。</li>
		<br><hr>
		<li><font color="green"> 【规则调试模式】</font></li>
		<li><font color="red"> 此模式可以直接使用【WinSCP】等文件管理软件，进行编辑，保存实时生效（仅限/koolshare/koolproxyR/data/rules/user.txt）</font></li>
		<li><font color="red"> 此模式还可以与其他模式混用，极大的提高效率，先启动（info，ad，全调试）再启动本模式即可。</font></li>
		<br><hr>
		<li><font color="green"> 【开启-INFO调试模式】</font></li>
		<li><font color="red"> 此模式下，只将重要信息显示到日志信息中。</font></li>
		<br><hr>
		<li><font color="green"> 【开启-AD调试模式】</font></li>
		<li><font color="red"> 此模式下，通常用来排除误杀。</font></li>
		<br><hr>
		<li><font color="green"> 【开启-全调试模式 】</font></li>
		<li><font color="red"> 更加详细的调试信息，让所有的东西都一览无余。</font></li>
		<br><hr>
		<li><font color="green"> 【关闭调试模式 】</font></li>
		<li><font color="red"> 十分重要的操作，不然一觉起来硬盘爆了。</font></li>
		<br><hr>

	</div> 
	<br><hr>
</div>
</div>
<div class="box boxr8">
<div class="heading">状态日志</div>
<div class="content">
	<div class="section kp_log content">
		<script type="text/javascript">
			y = Math.floor(docu.getViewSize().height * 0.55);
			s = 'height:' + ((y > 300) ? y : 300) + 'px;display:block';
			$('.section.kp_log').append('<textarea class="as-script" name="koolproxyR_log" id="_koolproxyR_log" wrap="off" style="max-width:100%; min-width: 100%; margin: 0; ' + s + '" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>');
		</script>
	</div>
</div>
</div>
<div id="msg_warring" class="alert alert-warning icon" style="display:none;">
</div>
<div id="msg_success" class="alert alert-success icon" style="display:none;">
</div>
<div id="msg_error" class="alert alert-error icon" style="display:none;">
</div>
<button type="button" value="Save" id="save-button" onclick="save()" class="btn btn-primary">保存 <i class="icon-check"></i></button>
<script type="text/javascript">init_kp();</script>
</content>
