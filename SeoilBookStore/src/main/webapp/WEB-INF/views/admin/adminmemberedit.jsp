<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${member.name} - 회원 정보 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/adminedit.css">
</head>
<body>

<div class="container">
    <h2>회원 정보 수정</h2>
    <form action="${pageContext.request.contextPath}/admin/adminmemberlist/update" method="post">
        <div>
        	<input type="hidden" name="id" value="${member.id}">
        </div>
        
        <div>
            <label>아이디</label><br>
            <input type="text" name="userId" value="${member.userId}" readonly>
        </div>
        
        <div>
            <label>비밀번호</label><br>
            <input type="text" name="password" value="${member.password}" required>
        </div>
		
		<div>
            <label>이름</label><br>
            <input type="text" name="name" value="${member.name}" required>
        </div>
        
        <div>
            <label>전화번호</label><br>
            <input type="text" name="phone" value="${member.phone}" required>
        </div>
        
        <div>
            <label>주소</label><br>
            <textarea name="address" rows="3">${member.address}</textarea>
        </div>
        
       	<div>
            <label>가입 날짜</label><br>
            <input type="text" name="createdAt" value="${member.createdAt}" readonly>
        </div>
        
        <div class="buttons">
            <button type="submit">수정 완료</button>
            <a href="${pageContext.request.contextPath}/admin/adminmemberlist">취소</a>
        </div>
    </form>
</div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>