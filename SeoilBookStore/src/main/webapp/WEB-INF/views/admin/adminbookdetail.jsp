<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>책 상세 페이지(관리자)</title>
  <!-- [CHANGED] CSS 통일: 사용자 상세와 동일 CSS 재사용 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bookDetail.css">

  <!-- [ADDED] 관리자 전용 소폭 보정 -->
  <style>
    .book-container { margin-bottom: 24px; }
    .book-description .description { white-space: pre-line; }
    .review-stars { color:#e53935; } /* 빨간 별 */
    .btn-delete { background:#e53935; color:#fff; border:0; padding:6px 10px; border-radius:6px; cursor:pointer; }
    .btn-delete:hover { opacity:.9; }
    .buttons form { display:inline; margin-right:8px; }
    .review-actions form { display:inline; }
  </style>
</head>
<body>
  <a href="${pageContext.request.contextPath}/admin/books" class="back-button-fixed">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="19" y1="12" x2="5" y2="12"></line>
      <polyline points="12 19 5 12 12 5"></polyline>
    </svg>
  </a>

  <c:if test="${book == null}">
    <script>
      alert("찾으시는 책 정보가 없습니다.");
      window.location.href = "${pageContext.request.contextPath}/admin/books";
    </script>
  </c:if>

  <c:if test="${book != null}">
    <div class="book-container">
      <div class="cover">
        <img src="${pageContext.request.contextPath}/resources/images/${book.image}" alt="${book.title}"
             onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/resources/images/default_cover.jpg';"/>
      </div>

      <div class="info">
        <h1><c:out value="${book.title}"/></h1>
        <p class="author">저자 : <c:out value="${book.author}"/></p>
        <p class="price"><fmt:formatNumber value="${book.price}" pattern="#,###" />원</p>
        <p class="stock">재고 : <c:out value="${book.stock}"/></p>

        <div class="buttons">
          <form action="${pageContext.request.contextPath}/admin/books/edit" method="get">
            <input type="hidden" name="id" value="${book.id}">
            <button type="submit" class="add-to-cart">수정하기</button> <!-- 사용자쪽 버튼 톤 재사용 -->
          </form>
          <form action="${pageContext.request.contextPath}/admin/books/delete" method="post"
                onsubmit="return confirm('정말 삭제하시겠습니까?');">
            <input type="hidden" name="id" value="${book.id}">
            <button type="submit" class="buy-now">삭제하기</button> <!-- 톤 통일 -->
          </form>
        </div>
      </div>
    </div>

    <!-- [CHANGED] 책 내용 섹션: 사용자와 동일 구조/클래스 -->
    <div class="book-description">
      <h2>책 내용</h2>
      <p class="description"><c:out value="${book.description}"/></p>
    </div>

    <!-- [CHANGED] 리뷰 섹션: 사용자와 동일 구조/클래스 -->
    <div class="review-container" style="margin-top:24px;">
      <div>
        <h2>리뷰(<c:out value="${fn:length(reviewList)}"/>개)</h2>
      </div>

      <div class="review-list">
        <c:choose>
          <c:when test="${not empty reviewList}">
            <c:forEach var="review" items="${reviewList}">
              <div class="review-item" id="review-${review.id}">
                <div class="review-header">
                  <div class="review-stars">
                    <c:forEach begin="1" end="${review.score}">★</c:forEach>
                    <c:forEach begin="1" end="${5 - review.score}">☆</c:forEach>
                  </div>
                  <div class="review-actions">
                    <!-- [CHANGED] 관리자: 누구의 리뷰든 삭제 가능 -->
                    <form action="${pageContext.request.contextPath}/admin/reviews/delete"
                          method="post"
                          onsubmit="return confirm('이 리뷰를 삭제하시겠습니까?');">
                      <input type="hidden" name="bookId" value="${book.id}">
                      <input type="hidden" name="id" value="${review.id}">
                      <button type="submit" class="btn-delete">리뷰 삭제</button>
                    </form>
                  </div>
                </div>

                <div class="review-content"><c:out value="${review.content}"/></div>
                <div class="review-meta">
                  작성자: <c:out value="${review.member != null ? review.member.name : '탈퇴회원/미상'}"/>
                  &nbsp;|&nbsp; 작성일: <fmt:formatDate value="${review.wroteOn}" pattern="yyyy-MM-dd HH:mm"/>
                  &nbsp;|&nbsp; 리뷰 ID: ${review.id}
                </div>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div class="review-item">
              <div class="review-content">등록된 리뷰가 없습니다.</div>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <a href="${pageContext.request.contextPath}/admin/books" class="back-button">목록으로</a>
  </c:if>

  <script>
    // 표지 이미지 로딩 보완(옵션)
    document.addEventListener('DOMContentLoaded', function(){
      const img = document.querySelector('.cover img');
      if (!img) return;
      img.addEventListener('error', function(){
        this.onerror = null;
        this.src='${pageContext.request.contextPath}/resources/images/default_cover.jpg';
      });
    });
  </script>
</body>
</html>
