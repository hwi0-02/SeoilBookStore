<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/register.css">
</head>
<body>
    <div class="register-container">
        <h2>회원가입</h2>
        
        <form id="registerForm" method="post" action="${pageContext.request.contextPath}/member/join">
            <div class="form-group">
                <label for="userId">아이디</label>
                <input type="text" id="userId" name="userId" required>
                <div id="idError" class="error-message">
                    <c:if test="${not empty idError}">${idError}</c:if>
                </div>
            </div>
            
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" required>
                <div id="passwordError" class="error-message">
                    <c:if test="${not empty passwordError}">${passwordError}</c:if>
                </div>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">비밀번호 확인</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required>
                <div id="confirmPasswordError" class="error-message"></div>
            </div>
            
            <div class="form-group">
                <label for="name">이름</label>
                <input type="text" id="name" name="name" required>
                <div id="nameError" class="error-message">
                    <c:if test="${not empty nameError}">${nameError}</c:if>
                </div>
            </div>
            
            <div class="form-group">
                <label for="phone">전화번호</label>
                <input type="text" id="phone" name="phone" required>
                <div id="phoneError" class="error-message">
                    <c:if test="${not empty phoneError}">${phoneError}</c:if>
                </div>
            </div>
            
            <div class="form-group">
                <label for="address">주소</label>
                <input type="text" id="address" name="address" required>
                <div id="addressError" class="error-message">
                    <c:if test="${not empty addressError}">${addressError}</c:if>
                </div>
            </div>
            
            <button type="submit">회원가입</button>
        </form>
        
        <div class="login-link">
            이미 계정이 있으신가요? <a href="${pageContext.request.contextPath}/member/loginform">로그인</a>
        </div>
        
        <div class="back-link">
            <a href="${pageContext.request.contextPath}/books">← 메인 페이지로 돌아가기</a>
        </div>
    </div>
    
    <script>
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const confirmPasswordError = document.getElementById('confirmPasswordError');
            
            if (password !== confirmPassword) {
                e.preventDefault();
                confirmPasswordError.textContent = '비밀번호가 일치하지 않습니다.';
            } else {
                confirmPasswordError.textContent = '';
            }
        });
    </script>
</body>
</html>