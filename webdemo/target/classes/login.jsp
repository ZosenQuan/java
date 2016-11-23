<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>I hope I can fly</title>
<script type="text/javascript" src="js/main.js"></script>
<script type="text/javascript">
	
</script>
<link type="text/css" rel="stylesheet" href="css/main.css" />
<style type="text/css">
</style>
</head>
<body>
	<div id="list">
		<ul id="list_ul">
			<li><img src="image/1.jpg" /></li>
			<li><img src="image/2.jpg" /></li>
			<li><img src="image/3.jpg" /></li>
		</ul>
	</div>
	<div class="dv">
		<h2>登 录</h2>
		<hr />
		<div id="error">
			<c:choose>
				<c:when test="${error == null}"></c:when>
				<c:otherwise>${error}</c:otherwise>
			</c:choose>
		</div>
		<form class="fm" action="check" method="post">
			<input class="ipt" id="username" name="username" placeholder="请输入账号"
				type="text" /> <input class="ipt" id="password" name="password"
				placeholder="请输入密码" type="password" /> <input class="bt"
				type="submit" onclick="return check()" value="登录" />
		</form>
	</div>
	<button onclick="sysnc()">ajax</button>
	<div id="ajax">
		<a href="jump">查看所有数据</a>
	</div>
</body>
</html>