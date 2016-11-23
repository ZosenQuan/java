<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>show</title>
<script type="text/javascript">
	function jump() {
		window.location.href = "/jump";
	}
</script>
<style type="text/css">
</style>
</head>
<body>
	<p>添加的数据为：</p>
	<table>
		<tr>
			<td>用户名</td>
			<td>密码</td>
		</tr>
		<tr>
			<td>${user.username}</td>
			<td>${user.password}</td>
		</tr>
	</table>
	<button type="button" onclick="jump()">确定</button>
</body>
</html>