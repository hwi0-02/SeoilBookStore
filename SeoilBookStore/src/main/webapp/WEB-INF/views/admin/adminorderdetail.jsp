<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>관리자 주문 상세보기</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/adminlist.css?v=1.0">
  <style>
    .book-info img {
      width: 60px;
      height: auto;
      border-radius: 4px;
    }
    .book-title {
      font-weight: 600;
    }
    .total-box {
      font-size: 1.1rem;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="container my-5">
    <h3 class="mb-4">📦 관리자 주문 상세</h3>

    <c:choose>
      <c:when test="${empty orders}">
        <div class="alert alert-danger">해당 주문 정보가 없습니다.</div>
      </c:when>
      <c:otherwise>
        <div class="card shadow-sm">
          <div class="card-body">
            <!-- 주문 정보 -->
            <div class="mb-3">
              <div class="row gy-2">
                <div class="col-md-auto"><strong>🕒 주문 일시:</strong> <fmt:formatDate value="${orders[0].orderDate}" pattern="yyyy-MM-dd HH:mm" /></div>
                <div class="col-md-auto"><strong>💳 거래 ID:</strong> ${transactionId}</div>
                <div class="col-md-auto"><strong>👤 회원명:</strong> ${orders[0].member.name}</div>
              </div>
            </div>

            <!-- 책 리스트 -->
            <div class="table-responsive">
              <table class="table table-bordered align-middle">
                <thead class="table-light">
                  <tr>
                    <th>책 정보</th>
                    <th>수량</th>
                    <th>개별 금액</th>
                    <th>총 금액</th>
                  </tr>
                </thead>
                <tbody>
                  <c:set var="totalGroupPrice" value="0" />
                  <c:forEach var="order" items="${orders}">
                    <tr>
                      <td>
                        <div class="d-flex align-items-center gap-3">
                          <img src="${pageContext.request.contextPath}/resources/images/${order.book.image}" alt="${order.book.title}" />
                          <div>
                            <div class="book-title">${order.book.title}</div>
                            <div class="text-muted small">${order.book.author}</div>
                          </div>
                        </div>
                      </td>
                      <td>${order.quantity}</td>
                      <td><fmt:formatNumber value="${order.totalPrice / order.quantity}" pattern="#,###" /> 원</td>
                      <td><fmt:formatNumber value="${order.totalPrice}" pattern="#,###" /> 원</td>
                    </tr>
                    <c:set var="totalGroupPrice" value="${totalGroupPrice + order.totalPrice}" />
                  </c:forEach>
                </tbody>
              </table>
            </div>

            <!-- 총 금액 -->
            <div class="text-end mt-3 total-box">
              총 결제 금액: <span class="text-primary"><fmt:formatNumber value="${totalGroupPrice}" pattern="#,###" /> 원</span>
            </div>

            <!-- 돌아가기 -->
            <div class="text-end mt-4">
              <a href="${pageContext.request.contextPath}/admin/adminorderlist" class="btn btn-secondary">← 주문 목록으로</a>
            </div>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
