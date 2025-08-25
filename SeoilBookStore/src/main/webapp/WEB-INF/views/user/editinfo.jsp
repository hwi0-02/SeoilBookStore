
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>회원 정보 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/editinfo.css">
</head>
<body>
<div class="info-container">
    <h2>회원 정보 수정</h2>
    
    <!-- 수정 폼 -->
    <form action="${pageContext.request.contextPath}/member/editinfo" method="post">
        <ul>
            <li><strong>아이디:</strong> ${member.userId}</li> <!-- 수정 불가 -->
            <li>
                <strong>이 름:</strong>
                <input type="text" name="name" value="${member.name}" required />
            </li>
            <li>
                <strong>번 호:</strong>
                <input type="text" name="phone" value="${member.phone}" required />
            </li>
            <li>
                <strong>주 소:</strong>
                <input type="text" name="address" value="${member.address}" required />
            </li>
        </ul>

        <div class="btn-group">
            <a href="${pageContext.request.contextPath}/member/info" class="btn-back">← 취소</a>
            <button type="submit" class="btn-editinfo">수정 완료</button>
        </div>
    </form>
</div>
</body>
</html>
