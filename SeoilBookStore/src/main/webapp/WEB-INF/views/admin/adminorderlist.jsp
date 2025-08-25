<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>관리자 주문 리스트</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/adminlist.css?v=1.0">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<style>
  .dashboard-row{margin:16px 0 8px;}
  .card{border-radius:12px;box-shadow:0 4px 12px rgba(0,0,0,.05)}
  .card-header{font-weight:600}
  .table-hover tbody tr{cursor:pointer}
  .chart-wrap{position:relative;min-height:320px;height:clamp(340px,42vh,520px)}
  @media(min-width:992px){.chart-wrap{height:420px}}
  #ordersChart{width:100%!important;height:100%!important;display:block}
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
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm ${page eq 'books' ? 'btn-primary' : 'btn-outline-primary'}">📚 책 리스트</a>
    <a href="<c:url value='/admin/adminmemberlist'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm ${page eq 'members' ? 'btn-primary' : 'btn-outline-primary'}">👥 회원 리스트</a>
    <a href="<c:url value='/admin/adminorderlist'/>"
       class="btn rounded-pill px-4 py-2 fw-semibold shadow-sm ${page eq 'orders' ? 'btn-primary' : 'btn-outline-primary'}">🧾 주문 리스트</a>
  </nav>
</div>

<div class="container-fluid">
  <div class="row dashboard-row g-3">
    <!-- 좌측: 그래프 -->
    <div class="col-12 col-lg-8">
      <div class="card">
        <div class="card-header">
          주문 추이 (집계 단위:
          <c:out value="${empty period ? '일' : (period=='year'?'연':(period=='month'?'월':'일'))}" />
          | 지표:
          <c:out value="${param.metric=='amount' ? '총 금액' : '총 수량'}" />)
        </div>
        <div class="card-body">
          <div class="chart-wrap"><canvas id="ordersChart"></canvas></div>

          <script>
          (function () {
            var rawLabels = [
              <c:forEach var="stat" items="${orderStats}" varStatus="s">
                '<c:out value="${stat.label}"/>'<c:if test="${!s.last}">,</c:if>
              </c:forEach>
            ];
            var period = ('${period}' || 'day');

            var labels = rawLabels.map(function(l){
              if(period==='month'){var p=l.split('-'); return p[0]+'-'+parseInt(p[1],10);}
              if(period==='day'){var p=l.split('-'); return p[0]+'-'+parseInt(p[1],10)+'-'+parseInt(p[2],10);}
              return l;
            });

            var qtys = [
              <c:forEach var="stat" items="${orderStats}" varStatus="s">
                <c:out value="${stat.sumQty}"/><c:if test="${!s.last}">,</c:if>
              </c:forEach>
            ].map(Number);

            var amounts = [
              <c:forEach var="stat" items="${orderStats}" varStatus="s">
                <c:out value="${stat.sumAmount}"/><c:if test="${!s.last}">,</c:if>
              </c:forEach>
            ].map(Number);

            var metric = ('${param.metric}' === 'amount') ? 'amount' : 'qty';
            var data   = (metric === 'amount') ? amounts : qtys;
            var yLabel = (metric === 'amount') ? '총 금액(원)' : '총 수량(권)';

            var minV = data.length ? Math.min.apply(null, data) : 0;
            var maxV = data.length ? Math.max.apply(null, data) : 0;

            var ctx = document.getElementById('ordersChart').getContext('2d');
            window.ordersChart = new Chart(ctx, {
              type: 'line',
              data: { labels: labels, datasets: [{ label: yLabel, data: data, tension: .3, fill: false }] },
              options: {
                responsive: true, maintainAspectRatio: false, animation: false,
                plugins: {
                  legend: { display: true },
                  tooltip: { callbacks: { label: (c)=> c.dataset.label+': '+Number(c.parsed.y).toLocaleString() } }
                },
                scales: {
                  x: { title: { display: true, text: '기간' } },
                  y: {
                    title: { display: true, text: yLabel },
                    beginAtZero: false,
                    suggestedMin: (minV>1)?(minV-1):minV,
                    suggestedMax: (maxV>=minV)?(maxV+1):undefined,
                    ticks: { callback: (v)=> Number(v).toLocaleString() }
                  }
                }
              }
            });

            function safeResize(){ if(window.ordersChart){ requestAnimationFrame(()=>window.ordersChart.resize()); } }
            function debounce(f,ms){ var t; return function(){ clearTimeout(t); t=setTimeout(f,ms);} }
            window.addEventListener('resize',debounce(safeResize,120));
            window.addEventListener('focus',safeResize);
            window.addEventListener('pageshow',safeResize);
            document.addEventListener('visibilitychange',function(){ if(!document.hidden) safeResize(); });
            if(window.ResizeObserver){
              var ro=new ResizeObserver(debounce(safeResize,120));
              ['.chart-wrap','.card','.col-12.col-lg-8','.container-fluid'].forEach(function(sel){
                var el=document.querySelector(sel); if(el) ro.observe(el);
              });
            }
            ['shown.bs.collapse','shown.bs.offcanvas','shown.bs.tab','shown.bs.modal'].forEach(function(ev){
              document.addEventListener(ev,safeResize);
            });
          })();
          </script>
        </div>
      </div>
    </div>

    <!-- 우측: 검색/필터 -->
    <div class="col-12 col-lg-4">
      <div class="card">
        <div class="card-header">검색 / 기간 필터</div>
        <div class="card-body">
          <form action="${pageContext.request.contextPath}/admin/adminorderlist" method="get" class="vstack gap-3">
            <div class="row g-2">
              <div class="col-12">
                <label class="form-label">거래 ID</label>
                <input type="text" name="transactionId" class="form-control" value="${param.transactionId}">
              </div>
              <div class="col-12">
                <label class="form-label">회원 이름</label>
                <input type="text" name="memberName" class="form-control" value="${param.memberName}">
              </div>
              <div class="col-6">
                <label class="form-label">시작일</label>
                <input type="date" name="startDate" class="form-control" value="${param.startDate}">
              </div>
              <div class="col-6">
                <label class="form-label">종료일</label>
                <input type="date" name="endDate" class="form-control" value="${param.endDate}">
              </div>
            </div>

            <!-- 집계 단위 -->
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

            <!-- 지표: 총 수량 / 총 금액 (동그라미 체크) -->
            <div class="mt-2">
              <label class="form-label d-block mb-1">그래프 선택</label>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="metric" id="m-qty" value="qty" ${param.metric == 'amount' ? '' : 'checked'}>
                <label class="form-check-label" for="m-qty">총 수량</label>
              </div>
              <div class="form-check form-check-inline">
                <input class="form-check-input" type="radio" name="metric" id="m-amount" value="amount" ${param.metric == 'amount' ? 'checked' : ''}>
                <label class="form-check-label" for="m-amount">총 금액</label>
              </div>
            </div>

            <div class="d-grid mt-2">
              <button type="submit" class="btn btn-primary">검색</button>
              <a href="${pageContext.request.contextPath}/admin/adminorderlist" class="btn btn-outline-secondary mt-2">초기화</a>
            </div>
          </form>
        </div>
      </div>
    </div>

  </div>
</div>

<!-- 주문 리스트 -->
<div class="container-fluid">
  <div class="card">
    <div class="card-header">주문 리스트</div>
    <div class="card-body p-0">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th style="width: 20%">거래 ID</th>
            <th style="width: 40%">회원 이름</th>
            <th style="width: 40%">결제 일시</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="entry" items="${groupedOrders}">
            <c:set var="firstOrder" value="${entry.value[0]}" />
            <tr onclick="location.href='${pageContext.request.contextPath}/admin/adminorderlist/detail?transactionId=${entry.key}'">
              <td>${entry.key}</td>
              <td>${firstOrder.member.name}</td>
              <td><fmt:formatDate value="${firstOrder.orderDate}" pattern="yyyy-MM-dd HH:mm" /></td>
            </tr>
          </c:forEach>
          <c:if test="${empty groupedOrders}">
            <tr><td colspan="3" class="text-center text-muted py-4">조회된 주문이 없습니다.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
