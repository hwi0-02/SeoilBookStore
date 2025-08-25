<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>책 상세페이지</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bookDetail.css">
  <style>
    /* 인라인 편집 보조 스타일 */
    .edit-comment { display:none; width:100%; box-sizing:border-box; }
    .review-item.editing .comment-content { display:none; }
    .review-item.editing .edit-comment { display:inline-block; }

    /* 보기/편집 별 토글 */
    .review-stars-view { color:#e53935; }              /* 보기용 별 - 빨간색 */
    .review-stars-edit { display:none; user-select:none; }
    .review-item.editing .review-stars-view { display:none; }
    .review-item.editing .review-stars-edit { display:inline-block; cursor:pointer; }

    /* 편집용 별 모양 */
    .review-stars-edit .star { font-size:1.05rem; color:#cccccc; padding:0 2px; }
    .review-stars-edit .star.filled { color:#e53935; } /* 선택/하이라이트 시 빨간색 */
  </style>
  <!-- (선택) Spring Security CSRF 사용 중이면 meta 추가
  <meta name="_csrf" content="${_csrf.token}">
  <meta name="_csrf_header" content="${_csrf.headerName}">
  -->
</head>
<body>
	<a href="${pageContext.request.contextPath}/books" class="back-button-fixed">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <line x1="19" y1="12" x2="5" y2="12"></line>
      <polyline points="12 19 5 12 12 5"></polyline>
    </svg>
  </a>
    
  <c:if test="${book == null}">
    <script>
      alert("찾으시는 책 정보가 없습니다.");
      window.location.href = "${pageContext.request.contextPath}/books";
    </script>
  </c:if>

  <c:if test="${book != null}">
  <div class="book-container">
    <div class="cover">
      <img src="${pageContext.request.contextPath}/resources/images/${book.image}" alt="${book.title}" onerror="this.src='${pageContext.request.contextPath}/resources/images/default_cover.jpg'; this.onerror=null;"/>
    </div>
    <div class="info">
      <h1>${book.title}</h1>
      <p class="author">저자 : ${book.author}</p>
      <p class="price"><fmt:formatNumber value="${book.price}" pattern="#,###" />원</p>
      
	  <div class="rating-section">
		<span class="stars">
		    <c:forEach begin="1" end="${fullStars}">★</c:forEach>
		    <c:if test="${halfStar}">⯨</c:if>
		    <c:forEach begin="1" end="${emptyStars}">☆</c:forEach>
		</span>
	    <span class="rating-text">
	        (<fmt:formatNumber value="${reviewAverage}" pattern="0.0" />) 리뷰 ${reviewCount}개
	    </span>
	  </div>
     
      <div class="buttons">
        <c:choose>
          <c:when test="${book.stock > 0}">
            <form action="${pageContext.request.contextPath}/cart/add" method="post">
              <input type="hidden" name="bookId" value="${book.id}">
              <button type="submit" class="add-to-cart">장바구니</button>
            </form>
            <form action="${pageContext.request.contextPath}/orders/buyNow" method="post">
                <input type="hidden" name="bookId" value="${book.id}">
                <input type="hidden" name="quantity" value="1">
                <button type="submit" class="buy-now">바로 구매</button>
            </form>
          </c:when>
          <c:otherwise>
            <button type="button" class="out-of-stock" disabled>품절</button>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
  
  <div class="book-description">
	  <h2>책 내용</h2>
	  <p class="description"><c:out value="${book.description}"/></p>
  </div>
 
<div class="review-container">
  <div><h2>리뷰(${reviewCount})</h2></div>
	
<c:if test="${not empty loginUser}">
  <div class="review-form">
      <form action="${pageContext.request.contextPath}/review/add" method="post">
	  	  <input type="hidden" name="bookId" value="${book.id}">
          <div class="form-group">
			  <label>별점</label>
			  <div class="star-rating">
			      <span data-value="1"></span>
			      <span data-value="2"></span>
			      <span data-value="3"></span>
			      <span data-value="4"></span>
			      <span data-value="5"></span>
			  </div>
			  <input type="hidden" name="rating" id="rating-value">
		  </div>
          <div class="form-group">
              <textarea name="content" placeholder="리뷰를 작성하세요(100자 내외)" rows="3" required></textarea>
          </div>
          <div class="form-group btn-right">
          	<button type="submit" class="btn-submit">등록</button>
          </div>
      </form>
  </div>
</c:if>
 
<div class="review-list">
  <c:forEach var="review" items="${reviewList}">
  <!-- data-id: 리뷰 PK, data-score: 현재 점수 -->
  <div class="review-item" id="review-${review.id}" data-id="${review.id}" data-score="${review.score}">
    <div class="review-header">
        <!-- 보기용 별 (빨간색) -->
        <div class="review-stars-view">
          <c:forEach begin="1" end="${review.score}">★</c:forEach>
          <c:forEach begin="1" end="${5 - review.score}">☆</c:forEach>
        </div>
        <!-- 편집용 별 (처음엔 숨김) -->
        <div class="review-stars-edit">
          <span class="star" data-value="1">★</span>
          <span class="star" data-value="2">★</span>
          <span class="star" data-value="3">★</span>
          <span class="star" data-value="4">★</span>
          <span class="star" data-value="5">★</span>
        </div>

        <c:if test="${not empty loginUser and loginUser.id == review.member.id}">
          <div class="review-actions">
            <button type="button" class="btn-edit">수정</button>
            <form action="${pageContext.request.contextPath}/review/delete" method="post" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
              <input type="hidden" name="bookId" value="${book.id}">
              <input type="hidden" name="id" value="${review.id}">
              <button type="submit" class="btn-delete">삭제</button>
            </form>
          </div>
        </c:if>
    </div>

	<div class="review-body">
	  <span class="comment-content"><c:out value="${review.content}"/></span>
	  <input type="text" class="edit-comment" value="<c:out value='${review.content}'/>">
	</div>

	<div class="review-meta">
	    ${review.member.name} | <fmt:formatDate value="${review.wroteOn}" pattern="yyyy-MM-dd HH:mm"/>
	</div>
  </div>
  </c:forEach>
</div>

  <a href="${pageContext.request.contextPath}/books" class="back-button">목록으로</a>
  </c:if>

  <script>
    // 이미지 로딩 처리
    document.addEventListener('DOMContentLoaded', function() {
        const contextPath = '${pageContext.request.contextPath}';
        const coverImg = document.querySelector('.cover img');
        if(coverImg) {
            coverImg.classList.add('loading');
            coverImg.onload = function() { this.classList.remove('loading'); };
            coverImg.onerror = function() {
                this.onerror = null;
                this.src = contextPath + '/resources/images/default_cover.jpg';
                this.classList.remove('loading');
            };
        }
    });
  </script>

<c:if test="${not empty successMsg}">
    <script>alert("${successMsg}");</script>
</c:if>

<!-- 등록 폼 별점 위젯 -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    const stars = document.querySelectorAll('.star-rating span');
    const ratingInput = document.getElementById('rating-value');

    function highlightStars(value) {
        stars.forEach(star => {
            if (parseInt(star.getAttribute('data-value')) <= value) {
                star.classList.add('filled');
            } else {
                star.classList.remove('filled');
            }
        });
    }

    stars.forEach(star => {
        star.addEventListener('mouseover', function() {
            const value = parseInt(this.getAttribute('data-value'));
            highlightStars(value);
        });
        star.addEventListener('mouseout', function() {
            const value = parseInt(ratingInput.value) || 0;
            highlightStars(value);
        });
        star.addEventListener('click', function() {
            const value = parseInt(this.getAttribute('data-value'));
            ratingInput.value = value;
            highlightStars(value);
        });
    });
});
</script>

<!-- 인라인 수정: 내용+별점 저장(AJAX) -->
<script>
document.addEventListener('DOMContentLoaded', function(){
  const ctx = '${pageContext.request.contextPath}';
  const list = document.querySelector('.review-list');

  // (선택) CSRF 사용 시 meta에서 읽기
  const csrfToken  = (document.querySelector('meta[name="_csrf"]') || {}).content;
  const csrfHeader = (document.querySelector('meta[name="_csrf_header"]') || {}).content;

  // 보기용 별 갱신
  function renderViewStars(container, score){
    const s = Math.max(0, Math.min(5, parseInt(score,10) || 0));
    const filled = '★'.repeat(s);
    const empty  = '☆'.repeat(5 - s);
    container.textContent = filled + empty;
  }

  // 편집용 별 하이라이트
  function highlightEditStars(editBox, value){
    editBox.querySelectorAll('.star').forEach(st => {
      const v = parseInt(st.getAttribute('data-value'), 10);
      st.classList.toggle('filled', v <= value);
    });
  }

  // 편집용 별 바인딩
  function bindStarEditor(item){
    const editBox = item.querySelector('.review-stars-edit');
    if (!editBox) return;
    const now = parseInt(item.dataset.score || '0', 10) || 0;
    item.dataset.editScore = now;
    highlightEditStars(editBox, now);

    editBox.onmousemove = function(e){
      const star = e.target.closest('.star');
      if (!star) return;
      highlightEditStars(editBox, parseInt(star.dataset.value,10));
    };
    editBox.onmouseleave = function(){
      highlightEditStars(editBox, parseInt(item.dataset.editScore||'0',10));
    };
    editBox.onclick = function(e){
      const star = e.target.closest('.star');
      if (!star) return;
      const val = parseInt(star.dataset.value,10);
      item.dataset.editScore = val;
      highlightEditStars(editBox, val);
    };
  }

  list && list.addEventListener('click', function(e){
    const btn = e.target.closest('.btn-edit');
    if (!btn) return;

    const item  = btn.closest('.review-item');
    const span  = item.querySelector('.comment-content');
    const input = item.querySelector('.edit-comment');
    const id    = item.dataset.id;

    // 저장
    if (item.classList.contains('editing')) {
      const newText  = (input.value || '').trim();
      const newScore = parseInt(item.dataset.editScore || item.dataset.score || '0', 10) || 0;
      if (!newText) { alert('내용을 입력하세요.'); return; }
      if (!(newScore >= 1 && newScore <= 5)) { alert('별점을 선택하세요.'); return; }

      const xhr = new XMLHttpRequest();
      xhr.open('POST', ctx + '/review/update.json', true);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
      if (csrfToken && csrfHeader) xhr.setRequestHeader(csrfHeader, csrfToken);

      const payload = 'id=' + encodeURIComponent(id)
                    + '&content=' + encodeURIComponent(newText)
                    + '&score=' + encodeURIComponent(newScore);

      xhr.onload = function(){
        let res = {};
        try { res = JSON.parse(xhr.responseText || '{}'); } catch(_) {}
        if (xhr.status === 200 && res.ok) {
          // 내용/별점 뷰 갱신
          span.textContent = newText;
          const viewStars = item.querySelector('.review-stars-view');
          if (viewStars) renderViewStars(viewStars, newScore);
          item.dataset.score = String(newScore);

          // 편집 종료
          item.classList.remove('editing');
          btn.textContent = '수정';
        } else {
          alert(res.message || '수정에 실패했습니다.');
        }
      };
      xhr.onerror = function(){ alert('네트워크 오류'); };
      xhr.send(payload);
      return;
    }

    // 편집 모드 진입
    input.value = span.textContent.trim();
    item.classList.add('editing');
    btn.textContent = '수정 완료';
    bindStarEditor(item);

    input.focus();
    input.setSelectionRange(input.value.length, input.value.length);

    // Enter 저장 / Esc 취소
    const keyHandler = function(ev){
      if (ev.key === 'Enter') { btn.click(); }
      if (ev.key === 'Escape') {
        item.classList.remove('editing');
        btn.textContent = '수정';
        input.removeEventListener('keydown', keyHandler);
      }
    };
    input.addEventListener('keydown', keyHandler);
  }, true);
});
</script>

</body>
</html>
