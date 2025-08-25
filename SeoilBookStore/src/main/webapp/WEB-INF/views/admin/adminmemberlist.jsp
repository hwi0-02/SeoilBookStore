<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>관리자 회원 리스트</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/adminlist.css?v=1.0">
  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>

  <style>
    /* 차트 래퍼: 부모 높이 고정(반응형) */
    .chart-wrap {
      position: relative;
      min-height: 320px;
      height: clamp(340px, 42vh, 520px);
    }
    @media (min-width: 992px) {
      .chart-wrap { height: 420px; }
    }
    /* 캔버스는 부모를 가득 채움 */
    #signupChart { width: 100% !important; height: 100% !important; display: block; }
  </style>
</head>

<body>

<c:if test="${empty sessionScope.loginUser or not sessionScope.loginUser.role == 'ADMIN'}">
    <c:redirect url="/books"/>
</c:if>

<header>
  <div class="header-container header-top">
    <div class="logo"><div class="logo-text">SEOIL 서일문고</div></div>
<div class="user-menu">
        <a href="${pageContext.request.contextPath}/books" class="auth-button userpage-button">사용자 페이지</a>
        <a href="${pageContext.request.contextPath}/admin/addbook" class="auth-button add-button">책 추가</a>
        <a href="${pageContext.request.contextPath}/member/logout" class="auth-button logout-button">로그아웃</a>
    </div>
  </div>
</header>

<div class="container-fluid my-2">
  <nav class="menu-nav d-flex justify-content-center flex-wrap gap-2 w-auto mx-auto">
    <a href="<c:url value='/admin/books'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm
              ${page eq 'books' ? 'btn-primary' : 'btn-outline-primary'}">
      📚 책 리스트
    </a>
    <a href="<c:url value='/admin/adminmemberlist'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm
              ${page eq 'members' ? 'btn-primary' : 'btn-outline-primary'}">
      👥 회원 리스트
    </a>
    <a href="<c:url value='/admin/adminorderlist'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm
              ${page eq 'orders' ? 'btn-primary' : 'btn-outline-primary'}">
      🧾 주문 리스트
    </a>
  </nav>
</div>

<!-- =========================
     상단 대시보드: 좌측 그래프 / 우측 필터
     ========================= -->
<div class="container-fluid my-3">
  <div class="row g-3">
    <!-- 좌: 가입자 추이 차트 -->
    <div class="col-12 col-lg-8">
      <div class="card">
        <div class="card-header">
          가입자 추이 (집계 단위:
          <c:out value="${empty period ? '일' : (period=='year'?'연':(period=='month'?'월':'일'))}"/>)</div>
        <div class="card-body">
          <div class="chart-wrap">
            <canvas id="signupChart"></canvas>
          </div>
          <script>
            (function(){
              var rawLabels = [
                <c:forEach var="p" items="${signupStats}" varStatus="s">
                  '<c:out value="${p.label}"/>'<c:if test="${!s.last}">,</c:if>
                </c:forEach>
              ];
              var counts = [
                <c:forEach var="p" items="${signupStats}" varStatus="s">
                  <c:out value="${p.count}"/><c:if test="${!s.last}">,</c:if>
                </c:forEach>
              ].map(Number);

              if (!rawLabels.length) {
                var canvas = document.getElementById('signupChart');
                var info = document.createElement('div');
                info.className = 'text-muted';
                info.innerText = '해당 조건의 데이터가 없습니다.';
                canvas.replaceWith(info);
                return;
              }

              var period = ('${period}' || 'day');
              // 0패딩 제거 (가독성)
              var labels = rawLabels.map(function(l){
                if (period === 'month') {
                  var m = l.split('-');      // [YYYY, MM]
                  return m[0] + '-' + parseInt(m[1], 10);
                } else if (period === 'day') {
                  var d = l.split('-');      // [YYYY, MM, DD]
                  return d[0] + '-' + parseInt(d[1], 10) + '-' + parseInt(d[2], 10);
                }
                return l; // year
              });

              var ctx = document.getElementById('signupChart').getContext('2d');
              window.signupChart = new Chart(ctx, {
                type: 'line',
                data: {
                  labels: labels,
                  datasets: [{ label: '가입 수', data: counts, tension: 0.3, fill: false }]
                },
                options: {
                  responsive: true,
                  maintainAspectRatio: false, // 부모(.chart-wrap) 높이 채움
                  animation: false,
                  plugins: { legend: { display: true } },
                  scales: {
                    x: { title: { display: true, text: '기간' } },
                    y: {
                      title: { display: true, text: '건수' },
                      beginAtZero: true,
                      min: 0,
                      ticks: {
                        stepSize: 1,
                        callback: function(v){ return Number.isInteger(v) ? v : ''; }
                      }
                    }
                  }
                }
              });

              // ===== 리사이즈 안정화 처리 =====
              function safeResize() {
                if (window.signupChart) {
                  requestAnimationFrame(function () { window.signupChart.resize(); });
                }
              }
              function debounce(fn, ms){ var t; return function(){ clearTimeout(t); t=setTimeout(fn, ms); }; }

              window.addEventListener('resize', debounce(safeResize, 120));
              window.addEventListener('focus', safeResize);
              window.addEventListener('pageshow', safeResize);
              document.addEventListener('visibilitychange', function(){
                if (!document.hidden) safeResize();
              });

              if (window.ResizeObserver) {
                var ro = new ResizeObserver(debounce(safeResize, 120));
                ['.chart-wrap', '.card', '.col-12.col-lg-8', '.container-fluid'].forEach(function(sel){
                  var el = document.querySelector(sel);
                  if (el) ro.observe(el);
                });
              }

              ['shown.bs.collapse','shown.bs.offcanvas','shown.bs.tab','shown.bs.modal'].forEach(function(ev){
                document.addEventListener(ev, safeResize);
              });
            })();
          </script>
        </div>
      </div>
    </div>

    <!-- 우: 회원 검색/필터 -->
    <div class="col-12 col-lg-4">
      <div class="card">
        <div class="card-header">회원 검색 / 필터</div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/admin/adminmemberlist" method="get" class="vstack gap-3">
            <div class="row g-2">
              <div class="col-6">
                <label class="form-label">이름</label>
                <input type="text" name="name" class="form-control" value="${paramName}">
              </div>
              <div class="col-6">
                <label class="form-label">아이디</label>
                <input type="text" name="userId" class="form-control" value="${paramUserId}">
              </div>
              <div class="col-6">
                <label class="form-label">시작일</label>
                <input type="date" name="startDate" class="form-control" value="${paramStartDate}">
              </div>
              <div class="col-6">
                <label class="form-label">종료일</label>
                <input type="date" name="endDate" class="form-control" value="${paramEndDate}">
              </div>
            </div>

            <div class="mt-2">
              <label class="form-label d-block mb-1">집계 단위</label>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="period" id="p-year" value="year" ${period=='year'?'checked':''}>
                <label class="form-check-label" for="p-year">연</label>
              </div>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="period" id="p-month" value="month" ${period=='month'?'checked':''}>
                <label class="form-check-label" for="p-month">월</label>
              </div>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="period" id="p-day" value="day" ${(empty period || period=='day')?'checked':''}>
                <label class="form-check-label" for="p-day">일</label>
              </div>
            </div>

            <div class="d-grid mt-2">
              <button type="submit" class="btn btn-primary">검색</button>
              <a href="${pageContext.request.contextPath}/admin/adminmemberlist" class="btn btn-outline-secondary mt-2">초기화</a>
            </div>
          </form>
        </div>
      </div>
    </div>

  </div>
</div>

<!-- 회원 리스트 -->
<div class="container-fluid">
  <div class="card">
    <div class="card-header">회원 리스트</div>
    <div class="card-body p-0">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>이름</th>
            <th>아이디</th>
            <th>전화번호</th>
            <th>주소</th>
            <th>가입 날짜</th>
            <th>비고</th>
          </tr>
        </thead>

        <tbody>
          <c:forEach var="member" items="${members}">
            <tr>
              <td>${member.name}</td>
              <td>${member.userId}</td>
              <td>${member.phone}</td>
              <td>${member.address}</td>
              <td>
                <c:remove var="createdAtFormatErr"/>
                <c:catch var="createdAtFormatErr">
                  <fmt:formatDate value="${member.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                </c:catch>
                <c:if test="${not empty createdAtFormatErr}">
                  <c:out value="${member.createdAt}"/>
                </c:if>
              </td>
              <td>
                <form action="<c:url value='/admin/adminmemberlist/edit'/>" method="get" style="display:inline;">
                  <input type="hidden" name="userId" value="${member.userId}" />
                  <button type="submit" class="action-btn edit-btn btn btn-sm btn-success">수정</button>
                </form>
                <form action="<c:url value='/admin/adminmemberlist/delete'/>" method="post" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                  <input type="hidden" name="userId" value="${member.userId}" />
                  <button type="submit" class="action-btn delete-btn btn btn-sm btn-outline-danger">삭제</button>
                </form>
              </td>
            </tr>
          </c:forEach>

          <c:if test="${empty members}">
            <tr><td colspan="6" class="text-center text-muted py-4">조회된 회원이 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
