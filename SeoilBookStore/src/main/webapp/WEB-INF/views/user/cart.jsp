<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>장바구니</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/cart.css">
</head>
<body>
    <h1>장바구니</h1>
    
    <div class="cart-container">
        <c:if test="${empty cartItems}">
            <div class="empty-cart">
                <p>장바구니가 비어 있습니다.</p>
                <a href="${pageContext.request.contextPath}/books" class="continue-shopping">쇼핑 계속하기</a>
            </div>
        </c:if>
        
        <c:if test="${not empty cartItems}">
            <div class="cart-header">
                <div>이미지</div>
                <div>상품명</div>
                <div>가격</div>
                <div>수량</div>
                <div>합계</div>
                <div></div>
            </div>
            
            <c:forEach var="item" items="${cartItems}">
                <div class="cart-item">
                    <div>
                        <img src="${pageContext.request.contextPath}/resources/images/${item.book.image}" alt="${item.book.title}">
                    </div>
                    <div class="item-title">${item.book.title}</div>
                    <div><fmt:formatNumber value="${item.book.price}" pattern="#,###" />원</div>
                    <div class="item-quantity">
                        <form action="${pageContext.request.contextPath}/cart/update" method="post">
                            <input type="hidden" name="bookId" value="${item.book.id}">
                            <button type="submit" name="action" value="decrease" class="quantity-btn">-</button>
                            <input type="text" class="quantity-input" value="${item.quantity}" >
                            <button type="submit" name="action" value="increase" class="quantity-btn">+</button>
                        </form>
                    </div>
                    <div><fmt:formatNumber value="${item.book.price * item.quantity}" pattern="#,###" />원</div>
                    <div>
                        <form action="${pageContext.request.contextPath}/cart/remove" method="post">
                            <input type="hidden" name="bookId" value="${item.book.id}">
                            <button type="submit" class="remove-btn">×</button>
                        </form>
                    </div>
                </div>
            </c:forEach>
            
            <div class="cart-summary">
                <div class="cart-total">총 금액: <fmt:formatNumber value="${totalAmount}" pattern="#,###" />원</div>
            </div>
            
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/books" class="continue-shopping">쇼핑 계속하기</a>
                <form action="${pageContext.request.contextPath}/orders/checkout" method="post">
                    <button type="submit" class="checkout-btn">결제하기</button>
                </form>
            </div>
        </c:if>
    </div>
    <c:if test="${not empty successMsg}">
        <script>
            alert("${successMsg}");
        </script>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <script>
            alert("${errorMsg}");
        </script>
    </c:if>
</body>
</html>