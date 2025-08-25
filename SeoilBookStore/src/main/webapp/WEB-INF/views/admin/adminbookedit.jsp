<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${title} - 도서 수정</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/adminedit.css">
</head>
<body>

<div class="container">
    <h2>도서 정보 수정</h2>
    <!-- multipart로 변경 -->
    <form action="${pageContext.request.contextPath}/admin/books/update" method="post" enctype="multipart/form-data">
        
        <div>
        	<input type="hidden" name="id" value="${book.id}">
        </div>
        
        <div>
            <label>도서 제목</label><br>
            <input type="text" name="title" value="${book.title}" required>
        </div>
        
        <div>
            <label>저자</label><br>
            <input type="text" name="author" value="${book.author}" required>
        </div>
		
		<div>
            <label>가격</label><br>
            <input type="number" name="price" value="${book.price}" required>
        </div>
        
        <div>
            <label>재고</label><br>
            <input type="number" name="stock" value="${book.stock}" required>
        </div>
        
        <div>
            <label>도서 설명</label><br>
            <textarea name="description" rows="5">${book.description}</textarea>
        </div>

        <div>
			<label for="image">도서 이미지 업로드</label><br>
	        <input type="file" name="image" accept="images/*"><br>
	        
	        <c:if test="${not empty book.image}">
	            <img src="${pageContext.request.contextPath}/resources/images/${book.image}" alt="도서 이미지" style="max-width:150px;"><br>
	            <small>※ 새 이미지를 선택하지 않으면 기존 이미지가 유지됩니다.</small>
	        </c:if>
	        
		    <!-- 기존 이미지 경로 hidden 필드로 전달 -->
		    <input type="hidden" name="originImage" value="${book.image}">
	    </div>
        
        <div class="buttons">
            <button type="submit">수정 완료</button>
            <a href="${pageContext.request.contextPath}/admin/books/detail?id=${book.id}">취소</a>
        </div>
    </form>
</div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>