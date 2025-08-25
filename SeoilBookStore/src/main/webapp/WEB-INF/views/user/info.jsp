<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>회원 정보</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/info.css">
</head>

<body>
<div class="info-container">
    <h2>${member.name}님의 회원 정보</h2>
    <ul>
        <li><strong>아이디:</strong> ${member.userId}</li>
        <li><strong>이 름:</strong> ${member.name}</li>
        <li><strong>번 호:</strong> ${member.phone}</li>
        <li><strong>주 소:</strong> ${member.address}</li>
    </ul>

    <div class="btn-group">
        <a href="${pageContext.request.contextPath}/books" class="btn-back">← 메인으로 돌아가기</a>
        <a href="${pageContext.request.contextPath}/member/editinfo" class="btn-editinfo">회원정보 수정 →</a>
    </div>
</div>
</body>
</html>