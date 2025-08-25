
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>주문/결제</title>
<link href="<c:url value='/resources/css/payment.css'/>" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>주문/결제</h1>

        <h2 class="section-title">주문 상품 정보</h2>
        <table class="order-items-table">
            <thead>
                <tr>
                    <th style="width:50%;">상품 정보</th>
                    <th style="width:15%;">수량</th>
                    <th style="width:15%;">상품 금액</th>
                    <th style="width:20%;">합계</th>
                </tr>
            </thead>
            <tbody>
                <%-- buyNow (단일 상품)의 경우 --%>
                <c:if test="${not empty order}">
                    <tr>
                        <td class="item-info">
                            <img src="<c:url value='/resources/images/${order.book.image}'/>" alt="${order.book.title}">
                            <div>
                                <strong>${order.book.title}</strong><br>
                                <small>${order.book.author}</small>
                            </div>
                        </td>
            			<td>${order.quantity}</td>
                        <td><fmt:formatNumber value="${order.book.price}" type="number" />원</td>
                        <td><fmt:formatNumber value="${order.totalPrice}" type="number" />원</td>
                    </tr>
                </c:if>
                <%-- checkout (장바구니)의 경우 --%>
                <c:if test="${not empty orders}">
                    <c:forEach var="o" items="${orders}">
                        <tr>
                            <td class="item-info">
                                <img src="<c:url value='/resources/images/${o.book.image}'/>" alt="${o.book.title}">
                                <div>
                                    <strong>${o.book.title}</strong><br>
                                    <small>${o.book.author}</small>
                                </div>
                            </td>
                            <td>${o.quantity}</td>
                            <td><fmt:formatNumber value="${o.book.price}" type="number" />원</td>
                            <td><fmt:formatNumber value="${o.totalPrice}" type="number" />원</td>
                        </tr>
                    </c:forEach>
                </c:if>
            </tbody>
        </table>

        <h2 class="section-title">주문자 정보</h2>
        <table class="info-table">
            <tr>
                <th>이름</th>
                <td>${loginUser.name}</td>
            </tr>
        </table>

        <h2 class="section-title">배송 정보</h2>
        <table class="info-table">
            <tr>
                <th>받는 분</th>
                <td><input type="text" value="${loginUser.name}" style="width: 200px;"></td>
            </tr>
            <tr>
                <th>주소</th>
                <td><input type="text" value="${loginUser.address}" style="width: 400px;"></td>
            </tr>
             <tr>
                <th>휴대전화</th>
                <td><input type="text" value="${loginUser.phone}" style="width: 200px;"></td>
            </tr>
            <tr>
                <th>배송 요청사항</th>
                <td><input type="text" placeholder="예: 부재 시 경비실에 맡겨주세요." style="width: 400px;"></td>
            </tr>
        </table>

        <div class="payment-summary">
            <div class="summary-box">
                <div class="summary-item">
                    <div class="label">총 상품 금액</div>
                    <div class="value">
                        <c:if test="${not empty order}"><fmt:formatNumber value="${order.totalPrice}" type="number" />원</c:if>
                        <c:if test="${not empty totalAmount}"><fmt:formatNumber value="${totalAmount}" type="number" />원</c:if>
                    </div>
                </div>
                <div class="summary-item">
                    <div class="label">배송비</div>
                    <div class="value">0원</div>
                </div>
                <div class="summary-item final-amount">
                    <div class="label">최종 결제 금액</div>
                    <div class="value">
                        <c:if test="${not empty order}"><fmt:formatNumber value="${order.totalPrice}" type="number" />원</c:if>
                        <c:if test="${not empty totalAmount}"><fmt:formatNumber value="${totalAmount}" type="number" />원</c:if>
                    </div>
                </div>
            </div>
        </div>

        <div class="payment-actions">
            <a href="javascript:history.back()" class="btn-back">뒤로가기</a>
            <form action="<c:url value='/orders/confirm'/>" method="post" style="display: inline;">
                <button type="submit" class="btn-payment">결제하기</button>
            </form>
        </div>
    </div>
    
    <script>
         // '결제하기' 버튼 클릭 여부를 추적하는 플래그
         let isCompletingPayment = false;
    
         document.querySelector('.btn-payment').addEventListener('click', function() {
             // '결제하기' 버튼을 누르면 플래그를 true로 설정
             isCompletingPayment = true;
         });
   
        window.addEventListener('beforeunload', function(event) {
            // '결제하기' 버튼을 통한 정상적인 제출이 아닐 경우에만 세션 정리 요청
            if (!isCompletingPayment) {
                navigator.sendBeacon('<c:url value="/orders/cancel"/>');
            }
        });
        </script>
</body>
</html>
