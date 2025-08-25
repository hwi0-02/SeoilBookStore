<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/login.css">
</head>
<body>
    <div class="login-container">
        <h2>로그인</h2>
        
        <form method="post" action="${pageContext.request.contextPath}/member/login">
            <div class="form-group">
                <label for="userId">아이디</label>
                <input type="text" name="userId" id="userId" required />
            </div>
            
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" name="password" id="password" required />
            </div>
            
            <button type="submit">로그인</button>
        </form>
        
        <c:if test="${not empty errorMsg}">
            <p class="error-message">${errorMsg}</p>
        </c:if>
        
        <div class="register-link">
            계정이 없으신가요? <a href="${pageContext.request.contextPath}/member/registerform">회원가입</a>
        </div>
        
        <div class="back-link">
            <a href="${pageContext.request.contextPath}/books">← 메인 페이지로 돌아가기</a>
        </div>
    </div>
</body>
</html>