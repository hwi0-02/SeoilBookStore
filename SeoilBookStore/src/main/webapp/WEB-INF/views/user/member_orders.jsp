<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>내 주문 내역</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/memberorders.css">
</head>
<body>
	<a href="${pageContext.request.contextPath}/books" class="back-button-fixed">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
    </a>

    <div class="orders-container">
        <h2>📦 내 주문 내역</h2>
        <c:choose>
            <c:when test="${empty groupedOrders}">
                <p class="empty-orders">주문 내역이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="entry" items="${groupedOrders}">
                    <div class="order-group">
                        <div class="order-group-header">
                            <span class="order-date">
                                <fmt:formatDate value="${entry.value[0].orderDate}" pattern="yyyy-MM-dd"/>
                            </span>
                            <span class="order-transaction-id">주문번호: ${entry.key}</span>
                        </div>
                        <table class="order-items-table">
                            <thead>
                                <tr>
                                    <th class="item-info-header">상품 정보</th>
                                    <th>수량</th>
                                    <th>주문 금액</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="totalGroupPrice" value="${0}" />
                                <c:forEach var="order" items="${entry.value}">
                                    <tr>
                                        <td class="item-info">
                                            <img src="${pageContext.request.contextPath}/resources/images/${order.book.image}" alt="${order.book.title}">
                                            <div class="item-details">
                                                <span class="item-title">${order.book.title}</span>
                                                <span class="item-author">${order.book.author}</span>
                                            </div>
                                        </td>
                                        <td>${order.quantity}개</td>
                                        <td><fmt:formatNumber value="${order.totalPrice}" pattern="#,###" />원</td>
                                    </tr>
                                    <c:set var="totalGroupPrice" value="${totalGroupPrice + order.totalPrice}" />
                                </c:forEach>
                            </tbody>
                        </table>
                        <div class="order-group-footer">
                            <span>총 결제 금액</span>
                            <span class="total-price"><fmt:formatNumber value="${totalGroupPrice}" pattern="#,###" />원</span>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>