function check() {
	var usr = document.getElementById("username").value;
	var pwd = document.getElementById("password").value;
	if (usr.length == 0 || pwd.length == 0) {
		alert("用户名或密码不能为空");
		return false;
	}
	return true;
}

function sysnc() {
	ajax("post", "/ajax", true);
}
function ajax(method, url, async) {
	var xmlhttp;
	if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp = new XMLHttpRequest();
	} else {// code for IE6, IE5
		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlhttp.open(method, url, async);
	xmlhttp.send();
	xmlhttp.onreadystatechange = stateChange;
	function stateChange() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			document.getElementById("ajax").innerHTML = xmlhttp.responseText;
		}
	}
}
/*
 * var s = function() { var arr = new Array(); arr[0] = "image/1.jpg";//放图片地址
 * arr[1] = "image/2.jpg"; arr[2] = "image/3.jpg"; idsrc =
 * document.getElementById("id1"); idsrc.src = arr[0]; var num = 0;
 * setInterval(turnpic, 2000); //每隔4秒转换图片 function turnpic() { if (num ==
 * arr.length - 1) num = 0; else num += 1; idsrc.src = arr[num]; } }
 * window.onload = s;
 */

var s1 = function() {
	list_ul = document.getElementById("list_ul");
	var num = 0;
	setInterval(turnpic, 4000); // 每隔4秒转换图片
	function turnpic() {
		if (num == 2)
			num = 0;
		else
			num += 1;
		list_ul.style.left = -num * 310 + "px";
	}
}
window.onload = s1;