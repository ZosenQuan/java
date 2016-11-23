<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>jump</title>
<style type="text/css">
table {
	border-collapse: collapse;
}

td {
	border: 1px solid black;
}
</style>
</head>
<body>
	<p>我真的不知道这是什么</p>
	<table>
		<tr>
			<td>id</td>
			<td>用户名</td>
			<td>密码</td>
		</tr>
		<c:choose>
			<c:when test="${empty resList}">
				<tr>
					<td>无记录</td>
				</tr>
			</c:when>
			<c:otherwise>
				<c:forEach items="${resList}" var="user">
					<tr>
						<td>${user.id}</td>
						<td>${user.username}</td>
						<td>${user.password}</td>
					</tr>
				</c:forEach>
			</c:otherwise>
		</c:choose>
	</table>
</body>
</html>