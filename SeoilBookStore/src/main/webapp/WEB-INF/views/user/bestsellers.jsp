<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>베스트셀러 Top 5 - SEOIL 서일문고</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/list.css">
</head>

<body>
<div class="top-banner">서일 문고에 오신 것을 환영합니다.</div>

<header>
 
 <div class="header-container header-top">
    <div class="logo">
      <div class="logo-text" onclick="location.href='${pageContext.request.contextPath}/books'">SEOIL 서일문고</div>
    </div>
    <form action="${pageContext.request.contextPath}/books" method="get" class="search-box">
      <input type="text" name="keyword" placeholder="도서를 검색해보세요" value="${searchKeyword}">
      <button type="submit"><i class="fas fa-search"></i></button>
    </form>

    <div class="user-menu">
      <c:choose>
        <c:when test="${empty sessionScope.loginUser}">
          <a href="${pageContext.request.contextPath}/member/registerform" class="auth-button register-button">회원가입</a>
          <a href="${pageContext.request.contextPath}/member/loginform" class="auth-button login-button">로그인</a>
 
       </c:when>
        <c:otherwise>
          <a href="${pageContext.request.contextPath}/member/info" class="welcome-text">안녕하세요, ${sessionScope.loginUser.name}님!</a>
          <a href="${pageContext.request.contextPath}/cart" class="auth-button cart-button">장바구니</a>
          <a href="${pageContext.request.contextPath}/member/logout" class="auth-button logout-button">로그아웃</a>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</header>

<nav class="main-nav">
  <div class="nav-container">
    <ul class="category-menu">
      <li><a href="${pageContext.request.contextPath}/books">도서</a></li>
      <li class="active"><a href="${pageContext.request.contextPath}/bestsellers">베스트셀러</a></li>
  
    <li><a href="${pageContext.request.contextPath}/recommended">추천 도서</a></li>
      <c:if test="${sessionScope.loginUser.role == 'ADMIN'}">
        <li class="admin-menu">
          <a href="#">관리자 페이지 ▼</a>
          <div class="mega-menu">
            <div class="mega-menu-column">
              <a href="/admin/books">📚 도서 관리</a>
              <a href="/admin/adminmemberlist">👤 회원 관리</a>
     
         <a href="/admin/adminorderlist">🛒 주문 관리</a>
            </div>
          </div>
        </li>
      </c:if>
    </ul>
    <div class="right-menu">
      <a href="#">회원혜택</a>
      <a href="${pageContext.request.contextPath}/member/info">회원정보</a>
      <a href="${pageContext.request.contextPath}/orders/member/orderlist">주문배송</a>
      <a href="${pageContext.request.contextPath}/faq">고객센터</a>
    </div>
  </div>
</nav>

<main class="content">
  <div class="page-title">
    <h1>베스트셀러 Top 5</h1>
    <span class="sub">누적 판매량 기준</span>
  </div>

  <c:if test="${empty bestsellers}">
    <p>베스트셀러 데이터가 없습니다.</p>
  </c:if>

  <c:if test="${not empty bestsellers}">
    <c:forEach var="b" items="${bestsellers}" varStatus="st">
      <c:if test="${st.index == 0}">
        <div class="best-hero">
          <div class="badge">서일문고 Best 1</div>
          <a href="${pageContext.request.contextPath}/books/${b.id}" class="cover">
            <img src="${pageContext.request.contextPath}/resources/images/${b.image}"
                 alt="${b.title}"
                 onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/resources/images/default_cover.jpg';">
          </a>
          <div class="detail">
            <h2>${b.title}</h2>
            <div class="author">${b.author}</div>
            <div class="meta">
              <div class="price"><fmt:formatNumber value="${b.price}" pattern="#,###"/>원</div>
				<div class="review">
				  <span class="stars">★</span> 
				  <strong><fmt:formatNumber value="${empty top1AvgScore ? 0 : top1AvgScore}" pattern="0.0"/></strong>
				  (${empty top1ReviewCount ? 0 : top1ReviewCount}개)
				</div>
            </div>

            <div class="description">${b.description}</div>
          </div>
          <div class="cta">
              <form action="${pageContext.request.contextPath}/cart/add" method="post">
                  <input type="hidden" name="bookId" value="${b.id}">
                  <button type="submit" class="cart">장바구니</button>
              </form>
              <form action="${pageContext.request.contextPath}/orders/buyNow" method="post">
                  <input type="hidden" name="bookId" value="${b.id}">
                  <input type="hidden" name="quantity" value="1">
                  <button type="submit" class="buy-now">바로구매</button>
              </form>
              <form action="${pageContext.request.contextPath}/books/${b.id}" method="get">
	              <input type="hidden" name="bookId" value="${b.id}">
	              <button type="submit" class="detail-button">상세보기</button>
              </form>
          </div>
        </div>
      </c:if>
    </c:forEach>
  </c:if>

  <c:if test="${not empty bestsellers}">
    <div class="bests-grid">
      <c:forEach var="b" items="${bestsellers}" varStatus="st">
        <c:if test="${st.index > 0 && st.index < 5}">
          <div class="bests-card">
            <div class="rank-badge">Best ${st.index + 1}</div>
            <a href="${pageContext.request.contextPath}/books/${b.id}" class="thumb">
              <img src="${pageContext.request.contextPath}/resources/images/${b.image}"
                   alt="${b.title}"
                   onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/resources/images/default_cover.jpg';">
            </a>
            <div class="info">
              <div class="title">${b.title}</div>
              <div class="author">${b.author}</div>
              <div class="foot">
                <div class="price"><fmt:formatNumber value="${b.price}" pattern="#,###"/>원</div>
              </div>
            </div>
          </div>
        </c:if>
      </c:forEach>
    </div>
  </c:if>
</main>

<footer class="site-footer">
  <div class="footer-container">
    <p>회사명: 서일문고 | 주소: 서울특별시 면목역 | 전화: 02-1234-1234</p>
    <p>© 2025 SEOIL 문고.</p>
  </div>
</footer>

</body>
</html>
