<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>고객센터 | SEOIL 서일문고</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/faq.css">
</head>
<body>

<div class="top-banner">서일 문고에 오신 것을 환영합니다.</div>

<header>
  <div class="header-container header-top">
    <div class="logo">
      <a href="${pageContext.request.contextPath}/books" class="logo-text">SEOIL 서일문고</a>
    </div>
    <form action="${pageContext.request.contextPath}/books" method="get" class="search-box">
      <input type="text" name="keyword" placeholder="도서를 검색해보세요" value="${param.keyword}">
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
      <li class="active"><a href="${pageContext.request.contextPath}/books">도서</a></li>
      <li><a href="${pageContext.request.contextPath}/bestsellers">베스트셀러</a></li>
      <li><a href="${pageContext.request.contextPath}/newbooks">신간</a></li>
      <li><a href="${pageContext.request.contextPath}/newbooks">이벤트</a></li>
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
            <a href="${pageContext.request.contextPath}/orders/member/orderlist">주문내역</a>
            <a href="${pageContext.request.contextPath}/faq">고객센터</a>
        </div>
  </div>
</nav>

<main class="support-container">
  <!-- 제목과 검색창 -->
  <div class="title-search" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
    <h2 class="section-title">고객센터</h2>
    
  </div>

  <!-- FAQ와 연락처 -->
  <div class="support-grid">
    <!-- FAQ 카드 -->
    <section class="card">
      <h3><i class="fa-regular fa-circle-question"></i> 자주 묻는 질문(FAQ)</h3>
      <div class="faq">
        <details open>
          <summary>주문 후 배송은 얼마나 걸리나요?</summary>
          <p>평균 1~3 영업일이 소요됩니다. 도서지역 및 예약상품은 기간이 추가될 수 있습니다.</p>
        </details>
        <details>
          <summary>교환/반품은 어떻게 하나요?</summary>
          <p>상품 수령 후 7일 이내 마이페이지 주문내역에서 교환/반품 신청이 가능합니다.</p>
        </details>
        <details>
          <summary>전자영수증 발급이 가능한가요?</summary>
          <p>주문 상세 페이지에서 즉시 발급하실 수 있습니다. 기업 고객은 사업자정보를 먼저 등록해주세요.</p>
        </details>
      </div>
    </section>

    <!-- 연락처 카드 -->
    <aside class="card">
      <h3><i class="fa-solid fa-headset"></i> 연락처 & 운영시간</h3>
      <ul class="contact-list">
        <li><i class="fa-solid fa-phone"></i> 02-1234-1234</li>
        <li><i class="fa-regular fa-envelope"></i> seoilbook@daewoo.co.kr</li>
        <li><i class="fa-solid fa-location-dot"></i> 서울특별시 서울특별시 면목역</li>
      </ul>
      <p class="notice">평일 09:00 ~ 18:00 (점심 12:00 ~ 13:00), 주말/공휴일 휴무</p>
    </aside>
  </div>
  
  <footer class="site-footer">
    <div class="footer-container">
        <p>회사명: 서일문고 | 주소: 서울특별시 면목역 | 전화: 02-1234-1234</p>
        <p>© 2025 SEOIL 문고.</p>
    </div>
</footer>
  
</main>

<script>

</script>

</body>
</html>