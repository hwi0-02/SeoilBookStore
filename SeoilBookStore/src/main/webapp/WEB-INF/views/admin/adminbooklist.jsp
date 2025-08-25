<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>관리자 책 리스트</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/adminlist.css?v=1.0">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <style>
    table.table-hover tbody tr.clickable-row { cursor: pointer; }
    table.table-hover tbody tr.clickable-row:focus { outline: 2px solid #0d6efd33; outline-offset: -2px; }
    .chart-wrap { position: relative; min-height: 320px; height: clamp(340px, 42vh, 520px); }
    @media (min-width: 992px) { .chart-wrap { height: 420px; } }
    #bookChart { width: 100% !important; height: 100% !important; display: block; }
  </style>
</head>
<body>

<c:if test="${empty sessionScope.loginUser or sessionScope.loginUser.role != 'ADMIN'}">
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

<!-- NAV -->
<div class="container-fluid my-2">
  <nav class="menu-nav d-flex justify-content-center flex-wrap gap-2 w-auto mx-auto">
    <a href="<c:url value='/admin/books'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm ${page eq 'books' ? 'btn-primary' : 'btn-outline-primary'}"
       aria-current="${page eq 'books' ? 'page' : ''}">📚 책 리스트</a>
    <a href="<c:url value='/admin/adminmemberlist'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm ${page eq 'members' ? 'btn-primary' : 'btn-outline-primary'}">👥 회원 리스트</a>
    <a href="<c:url value='/admin/adminorderlist'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm ${page eq 'orders' ? 'btn-primary' : 'btn-outline-primary'}">🧾 주문 리스트</a>
  </nav>
</div>

<!-- 상단 대시보드 -->
<div class="container-fluid my-3">
  <div class="row g-3">
    <!-- 좌: 차트 -->
    <div class="col-12 col-lg-8">
      <div class="card">
        <div class="card-header">
          인기 도서 Top <c:out value="${empty paramLimit ? '전체' : paramLimit}"/>
          (
          <c:choose>
            <c:when test="${paramMetric == 'reviews'}">리뷰 수</c:when>
            <c:otherwise>판매량</c:otherwise>
          </c:choose>
          )
        </div>
        <div class="card-body">
          <div class="chart-wrap"><canvas id="bookChart"></canvas></div>

          <script>
          (function(){
            // 서버 데이터(단일 데이터셋: bookSalesStats) → JS 배열로 직렬화
            var labelsRaw = [
              <c:forEach var="s" items="${bookSalesStats}" varStatus="st">
                '<c:out value="${s.label}"/>'<c:if test="${!st.last}">,</c:if>
              </c:forEach>
            ];
            var counts = [
              <c:forEach var="s" items="${bookSalesStats}" varStatus="st">
                <c:out value="${s.count}"/><c:if test="${!st.last}">,</c:if>
              </c:forEach>
            ].map(Number);

            // 현재 지표 (판매량/리뷰수) — 컨트롤러에서 같은 key(bookSalesStats)에 맞춰 집계 결과를 내려주는 구조
            var metric = '<c:out value="${empty paramMetric ? 'sales' : paramMetric}"/>'; // 'sales' | 'reviews'
            var isReviews = metric === 'reviews';

            // 데이터 없으면 안내문
            if (!labelsRaw || !labelsRaw.length) {
              var canvas = document.getElementById('bookChart');
              var info = document.createElement('div');
              info.className = 'text-muted';
              info.innerText = '해당 조건의 데이터가 없습니다.';
              canvas.replaceWith(info);
              return;
            }

            // 라벨 길면 컷
            var labels = labelsRaw.map(function(l){ return l.length > 18 ? l.substring(0, 18) + '…' : l; });

            var minC = Math.min.apply(null, counts);
            var maxC = Math.max.apply(null, counts);

            var ctx = document.getElementById('bookChart').getContext('2d');
            window.bookChart = new Chart(ctx, {
              type: 'bar',
              data: {
                labels: labels,
                datasets: [{ label: isReviews ? '리뷰 수' : '판매 수량', data: counts }]
              },
              options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                animation: false,
                plugins: { legend: { display: true } },
                scales: {
                  x: {
                    title: { display: true, text: isReviews ? '리뷰 수' : '판매 수량' },
                    beginAtZero: false,
                    suggestedMin: (minC > 1) ? (minC - 1) : minC,
                    suggestedMax: (maxC >= minC) ? (maxC + 1) : undefined,
                    ticks: {
                      stepSize: 1,
                      precision: 0,
                      callback: function(v){ return Number.isInteger(v) ? v : ''; }
                    }
                  },
                  y: { title: { display: false } }
                },
                // 바 클릭 → metric/필터 유지한 채 제목으로 검색
                onClick: function(evt, elements, chart) {
                  var pts = chart.getElementsAtEventForMode(evt, 'nearest', { intersect: true }, false);
                  if (!pts || !pts.length) return;
                  var idx = pts[0].index;
                  var title = labelsRaw[idx];
                  var base = '<c:url value="/admin/books"/>';
                  var url = base
                    + '?keyword=' + encodeURIComponent(title)
                    + '&startDate=' + encodeURIComponent('${paramStartDate}')
                    + '&endDate=' + encodeURIComponent('${paramEndDate}')
                    + '&limit=' + encodeURIComponent('${paramLimit}')
                    + '&title=' + encodeURIComponent('${title}')
                    + '&author=' + encodeURIComponent('${author}')
                    + '&metric=' + encodeURIComponent(metric);
                  window.location.href = url;
                }
              }
            });

            // 리사이즈 안정화
            function safeResize(){ if (window.bookChart) requestAnimationFrame(function(){ window.bookChart.resize(); }); }
            function debounce(fn, ms){ var t; return function(){ clearTimeout(t); t=setTimeout(fn, ms); }; }
            window.addEventListener('resize', debounce(safeResize, 120));
            window.addEventListener('focus', safeResize);
            window.addEventListener('pageshow', safeResize);
            document.addEventListener('visibilitychange', function(){ if (!document.hidden) safeResize(); });
            if (window.ResizeObserver) {
              var ro = new ResizeObserver(debounce(safeResize, 120));
              ['.chart-wrap', '.card', '.col-12.col-lg-8', '.container-fluid'].forEach(function(sel){
                var el = document.querySelector(sel);
                if (el) ro.observe(el);
              });
            }
            setTimeout(safeResize, 0);
          })();
          </script>
        </div>
      </div>
    </div>

    <!-- 우: 필터 -->
    <div class="col-12 col-lg-4">
      <div class="card">
        <div class="card-header">판매/리뷰 통계 필터</div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/admin/books" method="get" class="vstack gap-3">
            <div class="row g-2">
              <div class="col-6">
                <label class="form-label">시작일</label>
                <input type="date" name="startDate" class="form-control" value="${paramStartDate}">
              </div>
              <div class="col-6">
                <label class="form-label">종료일</label>
                <input type="date" name="endDate" class="form-control" value="${paramEndDate}">
              </div>
              <div class="col-12">
                <label class="form-label">Top N</label>
                <input type="number" min="3" max="50" step="1" name="limit" class="form-control" value="${paramLimit}">
              </div>
            </div>

            <div class="col-12">
              <label class="form-label">제목</label>
              <input type="text" name="title" class="form-control" value="${title}" placeholder="제목">
            </div>
            <div class="col-12">
              <label class="form-label">작가</label>
              <input type="text" name="author" class="form-control" value="${author}" placeholder="작가">
            </div>

            <!-- 집계 지표 토글 -->
            <div>
              <label class="form-label d-block mb-1">집계 지표</label>
              <div class="btn-group" role="group" aria-label="집계 지표">
                <input type="radio" class="btn-check" name="metric" id="metricSales" value="sales"
                       <c:if test="${paramMetric != 'reviews'}">checked</c:if>>
                <label class="btn btn-outline-primary" for="metricSales">판매량</label>

                <input type="radio" class="btn-check" name="metric" id="metricReviews" value="reviews"
                       <c:if test="${paramMetric == 'reviews'}">checked</c:if>>
                <label class="btn btn-outline-primary" for="metricReviews">리뷰 수</label>
              </div>
            </div>

            <!-- 차트 클릭 후 돌아올 때 보존 -->
            <input type="hidden" name="keyword" value="${keyword}"/>

            <div class="d-grid mt-2">
              <button type="submit" class="btn btn-primary">적용</button>
              <a href="${pageContext.request.contextPath}/admin/books" class="btn btn-outline-secondary mt-2">초기화</a>
            </div>
          </form>
        </div>
      </div>
    </div>

  </div>
</div>

<!-- 책 리스트 -->
<div class="container-fluid">
  <div class="card">
    <div class="card-header">책 리스트</div>
    <div class="card-body p-0">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th style="width: 10%">도서 ID</th>
            <th style="width: 40%">제목</th>
            <th style="width: 25%">저자</th>
            <th style="width: 15%">가격</th>
            <th style="width: 10%">재고</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="book" items="${books}">
            <tr class="clickable-row"
                data-href="<c:url value='/admin/books/detail'><c:param name='id' value='${book.id}'/></c:url>"
                tabindex="0" role="button" aria-label="도서 상세로 이동: ${book.title}">
              <td>${book.id}</td>
              <td>${book.title}</td>
              <td>${book.author}</td>
              <td><fmt:formatNumber value="${book.price}" type="number" pattern="#,###" /> 원</td>
              <td>
                ${book.stock}
                <c:if test="${book.stock <= 5}">
                  <span class="badge text-bg-danger ms-1">낮음</span>
                </c:if>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty books}">
            <tr><td colspan="5" class="text-center text-muted py-4">조회된 도서가 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
(function(){
  var rows = document.querySelectorAll('tr.clickable-row');
  rows.forEach(function (tr) {
    tr.addEventListener('click', function (e) {
      if (e.target && e.target.closest && e.target.closest('a,button,input,label,select,textarea')) return;
      var href = tr.getAttribute('data-href');
      if (href) window.location.href = href;
    });
    tr.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        var href = tr.getAttribute('data-href');
        if (href) window.location.href = href;
      }
    });
  });
})();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
