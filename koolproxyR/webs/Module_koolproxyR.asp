<!--
Tomato GUI
Copyright (C) 2006-2010 Jonathan Zarate
http://www.polarcloud.com/tomato/
For use with Tomato Firmware only.
No part of this file may be used without permission.
-->
<title>KoolProxyR</title>
<!-- <style>
	ul.nav-tabs{
	overflow :hidden ;
	}
	ul.nav-tabs li{
	width:12％;
	}
</style> -->
<content>
<script type="text/javascript" src="/js/jquery.min.js"></script>
<script type="text/javascript" src="/js/tomato.js"></script>
<script type="text/javascript" src="/js/advancedtomato.js"></script>
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
				return [ "【" + data[0] + "】", data[1], data[2], ['不过滤', 'HTTP全局模式', '带HTTPS的全局模式', '黑名单模式', '带HTTPS的黑名单模式', 'HTTP全端口模式'][data[3]] ];
			}else{
				if (data[1]){
					return [ "【" + data[1] + "】", data[1], data[2], ['不过滤', 'HTTP全局模式', '带HTTPS的全局模式', '黑名单模式', '带HTTPS的黑名单模式', 'HTTP全端口模式'][data[3]] ];
				}else{
					if (data[2]){
						return [ "【" + data[2] + "】", data[1], data[2], ['不过滤', 'HTTP全局模式', '带HTTPS的全局模式', '黑名单模式', '带HTTPS的黑名单模式', 'HTTP全端口模式'][data[3]] ];
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
			{ type: 'select',maxlen:20,options:[['0', '不过滤'], ['1', 'HTTP全局模式'], ['2', '带HTTPS的全局模式'], ['3', '黑名单模式'], ['4', '带HTTPS的黑名单模式'], ['5', 'HTTP全端口模式']], value: '1' }
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
					document.getElementById("_koolproxyR_rule_status").innerHTML = response.result.split("@@")[1];
					setTimeout("get_run_status();", 2000);
				},
				error: function(){
					if(softcenter == 1){
						return false;
					}
					document.getElementById("_koolproxyR_status").innerHTML = "获取运行状态失败！";
					document.getElementById("_koolproxyR_rule_status").innerHTML = "获取规则状态失败！";
					setTimeout("get_run_status();", 2000);
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
			// let data_version = '';
			// $.ajax({
			// 	url: "https://raw.githubusercontent.com/user1121114685/koolproxyR/master/version",
			// 	method: 'GET',
			// 	async: true,
			// 	cache: false,
			// 	success: (resp) => {
			// 		let data_version = resp.split('\n');
			// 		var kpr_installing_md5 = data_version[0];
			// 		var kpr_installing_version = data_version[1];
			// 		var postData = {"id":2, "method":"ks_app_install.sh", "params":[], "fields":{"softcenter_home_url":"https://raw.githubusercontent.com/user1121114685/koolproxyR/master","softcenter_installing_todo":"koolproxyR","softcenter_installing_tar_url":"koolproxyR.tar.gz","softcenter_installing_md5": kpr_installing_md5,"softcenter_installing_version": kpr_installing_version,"koolss_title":"koolproxyR"}};
			// 		$.ajax({
			// 			type: "POST",
			// 			url: "/_api/",
			// 			async: true,
			// 			cache:false,
			// 			data: JSON.stringify(postData),
			// 			dataType: "json",
			// 			success: function(response){
			// 				if(response){
			// 					setTimeout("window.location.reload()", 500);
			// 					return true;
			// 				}
			// 			}
			// 		});

			// 	}
			// });
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
			tabSelect("app7");

		}
		function issues_KP(){
			window.open("https://github.com/user1121114685/koolproxyR/issues/new");
		}
		function verifyFields(){
			var a = E('_koolproxyR_enable').checked;
//			var f = (E('_koolproxyR_reboot').value == '1');
//			var g = (E('_koolproxyR_reboot').value == '2');
//			var h = (E('_koolproxyR_mode').value == '2');
			var h = (E('_koolproxyR_mode_enable').value == '0');
			var s = (E('_koolproxyR_mode_enable').value == '1');
			var x = (E('_koolproxyR_port').value == '1');
//			var o = (E('_koolproxyR_mode').value == '5');
			var p = (E('_koolproxyR_bp_port').value);
			E('_koolproxyR_mode_enable').disabled = !a;
			E('_koolproxyR_port').disabled = !a;			
			E('_koolproxyR_mode').disabled = !a;
			E('_koolproxyR_base_mode').disabled = !a;		
//			E('_koolproxyR_bp_port').disabled = !a;
//			E('_koolproxyR_reboot').disabled = !a;
			E('_download_cert').disabled = !a;
			elem.display(PR('_koolproxyR_mode'), s);
			elem.display(PR('_koolproxyR_base_mode'), h);
//			elem.display('_koolproxyR_reboot_hour', a && f);
//			elem.display('koolproxyR_reboot_hour_suf', a && f);
//			elem.display('koolproxyR_reboot_hour_pre', a && f);
//			elem.display('_koolproxyR_reboot_inter_hour', a && g);
//			elem.display('koolproxyR_reboot_inter_hour_suf', a && g);
//			elem.display('koolproxyR_reboot_inter_hour_pre', a && g);
			elem.display('readme_port', x);
//			elem.display(PR('_koolproxyR_host'), h);
			if (dbus["koolproxyR_portctrl_mode"]=="1"){
				var z = true;
			}else{
				var z = false;
				x = false;
			}
			elem.display(PR('_koolproxyR_port'), z);
			elem.display(PR('_koolproxyR_bp_port'), x);
		}

		function tabSelect(obj){
			var tableX = ['app1-server1-jb-tab','app2-server1-fwlb-tab','app3-server1-kz-tab','app4-server1-zdy-tab','app5-server1-zsgl-tab','app6-server1-gzgl-tab','app7-server1-rz-tab'];
			var boxX = ['boxr1','boxr2','boxr3','boxr4','boxr5','boxr6','boxr7'];
			var appX = ['app1','app2','app3','app4','app5','app6','app7'];
			for (var i = 0; i < tableX.length; i++){
				if(obj == appX[i]){
					$('#'+tableX[i]).addClass('active');
					$('.'+boxX[i]).show();
				}else{
					$('#'+tableX[i]).removeClass('active');
					$('.'+boxX[i]).hide();
				}
			}
			if(obj=='app7'){
				setTimeout("get_log();", 400);
				elem.display('save-button', false);
			}else{
				elem.display('save-button', true);
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
			var KP = document.getElementById('_koolproxyR_enable').checked==false;			
			var R1 = document.getElementById('_koolproxyR_oline_rules').checked==false;
			var R2 = document.getElementById('_koolproxyR_easylist_rules').checked==false;
			var R3 = document.getElementById('_koolproxyR_abx_rules').checked==false;
			var R4 = document.getElementById('_koolproxyR_fanboy_rules').checked==false;
			var R5 = document.getElementById('_koolproxyR_video_rules').checked==false;

			if (KP){
				
			}else if(R1 && R2 && R3 && R4 && R5){
				alert("请到【规则管理】勾选规则！");
				return false;
			}
			verifyFields();
			// collect basic data
			dbus.koolproxyR_enable = E('_koolproxyR_enable').checked ? '1':'0';
			dbus.koolproxyR_mode_enable = E('_koolproxyR_mode_enable').value;			
//			dbus.koolproxyR_host = E('_koolproxyR_host').checked ? '1':'0';
			dbus.koolproxyR_base_mode = E('_koolproxyR_base_mode').value;			
			dbus.koolproxyR_mode = E('_koolproxyR_mode').value;
			dbus.koolproxyR_port = E('_koolproxyR_port').value;
			dbus.koolproxyR_bp_port = E('_koolproxyR_bp_port').value;
//			dbus.koolproxyR_reboot = E('_koolproxyR_reboot').value;
//			dbus.koolproxyR_reboot_hour = E('_koolproxyR_reboot_hour').value;
//			dbus.koolproxyR_reboot_inter_hour = E('_koolproxyR_reboot_inter_hour').value;
			dbus.koolproxyR_oline_rules = E("_koolproxyR_oline_rules").checked ? "1" : "0";
			dbus.koolproxyR_video_rules = E("_koolproxyR_video_rules").checked ? "1" : "0";
			dbus.koolproxyR_easylist_rules = E("_koolproxyR_easylist_rules").checked ? "1" : "0";
			dbus.koolproxyR_abx_rules = E("_koolproxyR_abx_rules").checked ? "1" : "0";
			dbus.koolproxyR_fanboy_rules = E("_koolproxyR_fanboy_rules").checked ? "1" : "0";
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
			tabSelect("app7");
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
			tabSelect("app7");
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
							a.href = "/files/ca_0.zip";
							a.download = 'ca_0.zip';
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
			tabSelect("app7");
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
						kp_cert('KoolproxyR_cert.sh', 2);
					}
				}
			});
		}
		
		function update_rules_now(arg){
			if (arg == 5){
				shellscript = 'KoolProxyR_rule_update.sh';
			}
			var id1 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id1, "method": shellscript, "params":[], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				async: true,
				cache:false,
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if(response){
						setTimeout("window.location.reload()", 500);
						return true;
					}
				}
			});
			tabSelect("app7");
		}


		function set_version() {
			$('#_koolproxyR_version').html('<font color="#1bbf35">KoolProxyR</font>');
		}

	</script>

	<div class="box">
		<div class="heading">
		<span id="_koolproxyR_version"></span>
		<a href="#/soft-center.asp" class="btn" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">返回</a>
		</div>
		<div class="content">
			<span id="msg" class="col-sm-12" style="margin-top:10px;width:700px">koolproxyR具有全部的koolproxy功能，并且不断增加新的功能。是koolproxy的重制版本，请和KP二选一。</span>
		</div>	
		<div class="content">
			<span id="msg1" class="col-sm-12" style="margin-top:10px;width:700px">责任申明：koolproxy二进制文件及koolproxy官方规则归koolproxy官方所有。</span>
		</div>	
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
					<font id="_koolproxyR_status" name="_koolproxyR_status" color="#1bbf35">正在检查运行状态...</font>
				</div>
			</fieldset>
		</div>
	</div>	
	<!-- ------------------ 标签页 --------------------- -->	
	<ul class="nav nav-tabs" style="margin-bottom: 20px;">
		<li><a href="javascript:void(0);" onclick="tabSelect('app1');" id="app1-server1-jb-tab" class="active"><i class="icon-system"></i> 基本设置</a></li>
		<!-- <li><a href="javascript:void(0);" onclick="tabSelect('app2');" id="app2-server1-fwlb-tab"><i class="icon-cloud"></i>订阅规则</a></li>		 -->
		<li><a href="javascript:void(0);" onclick="tabSelect('app3');" id="app3-server1-kz-tab"><i class="icon-tools"></i> 访问控制</a></li>		
		<li><a href="javascript:void(0);" onclick="tabSelect('app4');" id="app4-server1-zdy-tab"><i class="icon-hammer"></i> 自定义规则</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app5');" id="app5-server1-zsgl-tab"><i class="icon-lock"></i> 证书管理</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app6');" id="app6-server1-gzgl-tab"><i class="icon-cmd"></i> 规则状态</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app7');" id="app7-server1-rz-tab"><i class="icon-info"></i> 日志信息</a></li>
	</ul>
	<br/>
	<div class="box boxr1" style="margin-top: 0px;">
		<div class="content">
			<div id="identification" class="section"></div>
			<script type="text/javascript">
				$('#identification').forms([
//					{ title: '开启Koolproxy', name:'koolproxyR_enable',type:'checkbox',value: dbus.koolproxyR_enable == 1 },
//					{ title: 'Koolproxy运行状态', text: '<font id="_koolproxyR_status" name=_koolproxyR_status color="#1bbf35">正在获取运行状态...</font>' },
//					{ title: 'Koolproxy规则状态', text: '<font id="_koolproxyR_rule_status" name=_koolproxyR_status color="#1bbf35">正在获取规则状态...</font>' },
					{ title: '开启进阶模式', name:'koolproxyR_mode_enable',type:'select',options:[['0','关闭'],['1','开启']],value: dbus.koolproxyR_mode_enable || "0",suffix: '<font color="#FF0000">【进阶模式】&nbsp;&nbsp;提供更多设置选项</font></lable>' },
					{ title: '过滤模式', name:'koolproxyR_base_mode',type:'select',options:[['0','不过滤'],['1','HTTP全局模式'],['2','黑名单模式']],value: dbus.koolproxyR_base_mode || "1",suffix: '<font color="#FF0000">【开启进阶模式】&nbsp;&nbsp;获得更多选项！</font></lable>' },
					{ title: '过滤模式', name:'koolproxyR_mode',type:'select',options:[['0','不过滤'],['1','HTTP全局模式'],['2','带HTTPS的全局模式'],['3','黑名单模式'],['4','带HTTPS的黑名单模式']],value: dbus.koolproxyR_mode || "1",suffix: '<font color="#FF0000">全端口模式是HTTP的，去视频广告请在&nbsp;&nbsp;访问控制中给设备指定【HTTPS全局模式】</font></lable>' },
					{ title: '端口控制', name:'koolproxyR_port',type:'select',options:[['0','关闭'],['1','开启']],value: dbus.koolproxyR_port || "0",suffix: '<lable id="readme_port"><font color="#FF0000">【端口控制】&nbsp;&nbsp;只有全端口模式下才生效</font></lable>'},
					{ title: '例外端口', name:'koolproxyR_bp_port',type:'text',style:'input_style', maxlen:50, value:dbus.koolproxyR_bp_port ,suffix: '<font color="#FF0000">例：</font><font color="#FF0000">【单端口】：80【多端口】：80,443</font>'},
//					{ title: '开启Adblock Plus Host', name:'koolproxyR_host',type:'checkbox',value: dbus.koolproxyR_host == 1, suffix: '<lable id="_koolproxyR_host_nu"></lable>' },
//					{ title: '插件自动重启', multi: [
//						{ name:'koolproxyR_reboot',type:'select',options:[['1','定时'],['2','间隔'],['0','关闭']],value: dbus.koolproxyR_reboot || "0", suffix: ' &nbsp;&nbsp;' },
//						{ name: 'koolproxyR_reboot_hour', type: 'select', options: option_reboot_hour, value: dbus.koolproxyR_reboot_hour || "", suffix: '<lable id="koolproxyR_reboot_hour_suf">重启</lable>', prefix: '<span id="koolproxyR_reboot_hour_pre" class="help-block"><lable>每天</lable></span>' },
//						{ name: 'koolproxyR_reboot_inter_hour', type: 'select', options: option_reboot_inter, value: dbus.koolproxyR_reboot_inter_hour || "", suffix: '<lable id="koolproxyR_reboot_inter_hour_suf">重启</lable>', prefix: '<span id="koolproxyR_reboot_inter_hour_pre" class="help-block"><lable>每隔</lable></span>' }
//					] },
					{ title: '证书下载', suffix: ' <button id="_download_cert" onclick="download_cert();" class="btn btn-danger">证书下载</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="https_KP();" class="btn btn-success">相关教程</button>' },
					{ title: '项目信息', suffix: ' <button id="_find_github" onclick="find_github();" class="btn">开源地址</button>&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="update_KPR();" class="btn">更新插件</button>' },
					{ title: '交流渠道', suffix: ' <button onclick="issues_KP();" class="btn btn-danger">建议及反馈</button>&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="find_telegram();" class="btn btn-danger">加入TG群</button>' },
//					{ title: 'KoolProxy官方链接', suffix: ' <button id="_findkp_github" onclick="findkp_github();" class="btn">KoolProxy</button>&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="KP_KP();" class="btn">KoolProxy官网</button>' }

				]);
			</script>
		</div>
	</div>
	<div id="kp_mode_readme" class="box boxr1" style="margin-top: 15px;">
	<div class="heading">贡献者列表（排名不分先后）： <a class="pull-right" data-toggle="tooltip" title="Hide/Show Notes" href="javascript:toggleVisibility('notes');"><span id="sesdivnotesshowhide"><i class="icon-chevron-up"></i></span></a></div>
	<div class="section content" id="sesdivnotes">
			<li>【本插件修改自】https://github.com/koolshare/ledesoft/tree/master/koolproxy</li>	
			<li>【KoolProxy官网】https://koolproxy.io</li>	
			<li>--------------------------------------------------------------------------</li>	
			<li>【HouZi】感谢猴子对koolproxy及koolproxy规则所做的贡献。</li>		
			<li>【XiaoBao】感谢小宝对koolproxy二进制文件所做的贡献。</li>
			<li>【Fw867】感谢Fw867对Openwrt X64软件中心所做的贡献。</li>
			<li>--------------------------------------------------------------------------</li>	
	</div>
	</div>
	<!-- <div class="box boxr2" id="v2ray_server_tab" style="margin-top: 0px;">
	<div class="heading">自建服务器列表</div>
		<div class="content">
			<div class="tabContent">
				<table class="line-table" cellspacing=1 id="v2ray_server_pannel"></table>
			</div>
			<br><hr>
			<button type="button" value="Save" id="save-server-node" onclick="manipulate_conf('v2ray_config.sh', 9)" class="btn btn-primary">保存服务器列表 <i class="icon-check"></i></button>
		</div>
	</div>
	<div class="box boxr2" id="v2ray_node_urladd" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content">
			<div id="v2ray_node_urladd_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_node_urladd_pannel').forms([
					{ title: '通过vmess链接添加节点</br></br><font color="#B2B2B2"># 可一次添加多个vmess://链接<br /># 每个链接以空格分隔</font>', name: 'v2ray_base64_links',type:'textarea', value: dbus.v2ray_base64_links, style: 'width: 100%; height:100px;' }
				]);
			</script>
			<button type="button" value="Save" id="update-addurl-node" onclick="node_sub('v2ray_sub.sh', 4)" class="btn btn-primary" style="float:right;margin-right:20px;">添加节点 <i class="icon-check"></i></button>
		</div>
	</div>
	<div class="box boxr2" id="v2ray_node_subscribe" style="margin-top: 0px;">
		<div class="heading">节点订阅</div>
		<div class="content">
			<div id="v2ray_node_subscribe_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_node_subscribe_pannel').forms([
					{ title: '订阅配置', multi: [
						{ suffix: ' 开启定时更新' },
						{ name: 'v2ray_basic_node_update',type: 'checkbox',value: dbus.v2ray_basic_node_update == 1 ,suffix: ' &nbsp;&nbsp;' },
						{ name: 'v2ray_basic_node_update_day',type: 'select', options:option_day_time, value: dbus.v2ray_basic_node_update_day || '7' ,suffix: ' &nbsp;' },
						{ name: 'v2ray_basic_node_update_hr',type: 'select', options:option_time_hour, value: dbus.v2ray_basic_node_update_hr || '3' ,suffix: ' &nbsp;&nbsp;通过V2ray代理更新节点信息' },
						{ name: 'v2ray_basic_suburl_socks',type: 'checkbox',value: dbus.v2ray_basic_suburl_socks == 1 },
						{ suffix: '<button id="_remove_sub_node" onclick="node_sub(\'v2ray_sub.sh\', 2 ,\'订阅节点\');" class="btn btn-success">删除订阅节点 <i class="icon-cancel"></i></button>' },
						{ suffix: '<button id="_remove_all_node" onclick="node_sub(\'v2ray_sub.sh\', 1 ,\'所有节点\');" class="btn btn-success">清空所有节点 <i class="icon-disable"></i></button>' },
					]},
					{ title: '订阅地址', name: 'v2ray_basic_suburl',type:'text',size: 100, value: Base64.decode(dbus.v2ray_basic_suburl) }
				]);
			</script>
			<button type="button" value="Save" id="update-subscribe-node" onclick="node_sub('v2ray_sub.sh', 3)" class="btn btn-primary" style="float:right;margin-right:20px;">保存设置并更新订阅 <i class="icon-check"></i></button>
		</div>
	</div>	 -->
	<div class="box boxr3">
		<div class="heading">访问控制</div>
		<div class="content">
			<div class="tabContent">	
				<table class="line-table" cellspacing=1 id="ctrl-grid"></table>
			</div>		
			<br><hr>
			<h4>使用手册</h4>
			<div class="section" id="sesdiv_notes2">
				<li>过滤https站点广告需要为相应设备安装证书，并启用带HTTPS过滤的模式！</li>
				<li>【全端口模式】是包括443和80端口以内的全部端口进行过滤，如果被过滤的设备开启这个，也需要安装证书！</li>
				<li>需要自定义列表内没有的主机时，把【主机别名】留空，填写其它的即可！</li>
				<li>访问控制面板中【ip地址】和【mac地址】至少一个不能为空！只有ip时匹配ip，只有mac时匹配mac，两个都有一起匹配！</li>
				<li>在路由器下的设备，不管是电脑，还是移动设备，都可以在浏览器中输入<i><b>110.110.110.110</b></i>来下载证书。</i></li>
				<li>如果想在多台装有koolroxy的路由设备上使用一个证书，请用本插件的证书备份功能，并上传到另一台路由。</li>
				<li><font color="red">注意！【全端口模式】过滤效果牛逼和覆盖的范围更广，但却对设备的性能有非常高的要求，请根据自己的设备的情况进行选择！</font></li>
				<li><font color="red">注意！如果使用全端口模式过滤导致一些端口出现问题，可以开启端口控制，进行例外端口排除！</font></li>
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
					{ title: '证书备份', suffix: '<button onclick="kp_cert(\'KoolproxyR_cert.sh\', 1);" class="btn btn-success">证书备份 <i class="icon-download"></i></button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="kp_cert_0(\'KoolproxyR_cert.sh\', 3);" class="btn btn-success">生成.0根证书 <i class="icon-download"></i></button><font color="#FF0000">【.0根证书】&nbsp;&nbsp;用于安卓7.0以上的设备安装HTTPS证书，详见教程。</font></lable>' },
					{ title: '证书恢复', suffix: '<input type="file" id="file" size="50">&nbsp;&nbsp;<button id="upload1" type="button"  onclick="restore_cert();" class="btn btn-danger">上传并恢复 <i class="icon-cloud"></i></button>' }
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
					{ title: '绿坝规则状态', text: '<font id="_koolproxyR_rule_status" name=_koolproxyR_status color="#1bbf35">正在获取规则状态...</font>' },
					{ title: '第三方规则状态', text: '<font id="_koolproxyR_third_rule_status" name=_koolproxyR_status color="#1bbf35">正在获取规则状态...</font>' },	
					{ title: '默认规则订阅', multi: [
					{ name: 'koolproxyR_oline_rules',type:'checkbox',value: dbus.koolproxyR_oline_rules == '1', suffix: '<lable id="_kp_oline_rules">绿坝规则（KP官方规则）</lable>&nbsp;&nbsp;' }
					]},
					{ title: '规则不是越多越好', multi: [
						{ name: 'koolproxyR_video_rules',type:'checkbox',value: dbus.koolproxyR_video_rules == '1', suffix: '<lable id="_kp_video_rules">视频规则(KP官方规则)</lable>&nbsp;&nbsp;' },						
						{ name: 'koolproxyR_easylist_rules',type:'checkbox',value: dbus.koolproxyR_easylist_rules == '1', suffix: '<lable id="_kp_easylist">ABP规则(与绿坝规则重复)</lable>&nbsp;&nbsp;' },
						{ name: 'koolproxyR_abx_rules',type:'checkbox',value: dbus.koolproxyR_abx_rules == '1', suffix: '<lable id="_kp_abx">乘风规则（卡饭规则）</lable>&nbsp;&nbsp;' },
						{ name: 'koolproxyR_fanboy_rules',type:'checkbox',value: dbus.koolproxyR_fanboy_rules == '1', suffix: '<lable id="_kp_fanboy">Fanboy规则（主打国外）</lable>&nbsp;&nbsp;' }
					]},	
					{ title: '订阅规则更新', multi: [
//						{ name: 'koolproxyR_basic_rule_update',type: 'select', options:[['0', '禁用'], ['1', '开启']], value: dbus.koolproxyR_basic_rule_update || "1", suffix: ' &nbsp;&nbsp;' },
//						{ name: 'koolproxyR_basic_rule_update_day', type: 'select', options:option_day_time, value: dbus.koolproxyR_basic_rule_update_day || "7",suffix: ' &nbsp;&nbsp;' },
//						{ name: 'koolproxyR_basic_rule_update_hr', type: 'select', options:option_hour_time, value: dbus.koolproxyR_basic_rule_update_hr || "3",suffix: ' &nbsp;&nbsp;' },
						{ name:'koolproxyR_basic_koolproxyR_update',type:'checkbox',value: dbus.koolproxyR_basic_koolproxyR_update != 0, suffix: '<lable id="_koolproxyR_basic_koolproxyR_update_txt">KP官方规则</lable>&nbsp;&nbsp;' },
						{ name:'koolproxyR_basic_easylist_update',type:'checkbox',value: dbus.koolproxyR_basic_easylist_update != 0, suffix: '<lable id="_koolproxyR_basic_easylist_update_txt">ABP规则</lable>&nbsp;&nbsp;' },
						{ name:'koolproxyR_basic_abx_update',type:'checkbox',value: dbus.koolproxyR_basic_abx_update != 0, suffix: '<lable id="_koolproxyR_basic_abx_update_txt">乘风规则</lable>&nbsp;&nbsp;' },
						{ name:'koolproxyR_basic_fanboy_update',type:'checkbox',value: dbus.koolproxyR_basic_fanboy_update != 0, suffix: '<lable id="_koolproxyR_basic_fanboy_update_txt">Fanboy规则</lable>&nbsp;&nbsp;' },
						{ suffix: '<button id="_update_rules_now" style="margin-top:5px;" onclick="update_rules_now(5);" class="btn btn-success">手动更新 <i class="icon-cloud"></i></button>' }
					]}	
				]);
			</script>
			<br><hr>
			<h4>规则管理说明</h4>
				<div class="section" id="sesdiv_notes2">
				<li> KoolProxy推荐使用默认规则即可满足屏蔽的效果。</li>
				<li><font color="green"> 【绿坝规则】</font>经过KoolProxy审核并通过兼容性测试的。</li>
				<li> 第三方规则是由一些爱好者编写的，兼容性很难保证。</li>
				<li><font color="red"> 注意！规则加载的越多产生冲突且不兼容的问题就会大大增加。</font></li>		
				<li><font color="red"> 注意！我们无法去保证所有规则都能完美地在KoolProxy上面运行。</font></li>
				<li><font color="red"> 注意！规则不是越多越好，建议第三方规则根据自己需要勾选一种即可。</font></li>
				<li><font color="red"> 如果用户在选择规则上出现的风险，将由用户去承担，KoolProxy不承担任何责任。</font></li>
			</div>
			<br><hr>			
		</div>
	</div>
	<div class="box boxr7">
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
