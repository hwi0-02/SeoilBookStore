package service;

import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import mapper.BookMapper;
import mapper.ReviewMapper;
import model.Book;
import model.Review;

@Service
public class BookService {

    @Autowired
    private BookMapper bookMapper;

    @Autowired
    private ReviewMapper reviewMapper;

    public Book getBookById(int id) {
        return bookMapper.selectBookById(id);
    }

    public List<Book> getAllBooks() {
        return bookMapper.selectAllBooks();
    }

    public List<Book> searchBooks(String keyword) {
        return bookMapper.searchBooks(keyword);
    }

    public void updateStock(int bookId, int quantity) {
        bookMapper.updateStock(bookId, quantity);
    }

    // 리뷰 INSERT
    public int save(Review review) {
        return reviewMapper.save(review);
    }

    public List<Review> getReviewsByBook(int id) {
        return reviewMapper.selectByBookId(id);
    }

    public int deleteById(int id) {
        return reviewMapper.deleteById(id);
    }

    public Review getReviewById(int id) {
        return reviewMapper.selectById(id);
    }

    /**
     * 리뷰 UPDATE (인라인 수정용)
     * - 수정 가능 필드: content(필수), score(옵션)
     * - 소유자(member_id)와 매칭되는 경우에만 1행 업데이트
     * - 반환: 1(성공) / 0(권한없음 또는 대상없음)
     */
    public int update(Review review) {
        // DB에서 원본을 읽어 정체성 컬럼/기본값을 신뢰
        Review origin = reviewMapper.selectById(review.getId());
        if (origin == null) return 0;

        // content는 반드시 갱신(널이면 원본 유지)
        String newContent = (review.getContent() != null) ? review.getContent() : origin.getContent();

        // score는 들어오지 않으면 원본 유지(0을 "미지정"으로 취급)
        int newScore = (review.getScore() != 0) ? review.getScore() : origin.getScore();

        // DB 레벨 권한검증을 위해 memberId 세팅
        Review toUpdate = new Review();
        toUpdate.setId(origin.getId());
        toUpdate.setMemberId(origin.getMemberId());  // 소유자 고정
        toUpdate.setContent(newContent);
        toUpdate.setScore(newScore);

        // book_id / wrote_on 등은 절대 SET하지 않음
        return reviewMapper.updateByOwner(toUpdate);
    }

    public int getCountByBookId(int bookId) {
        return reviewMapper.countByBookId(bookId);
    }

    public int getSumByBookId(int bookId) {
        return reviewMapper.sumScoreByBookId(bookId);
    }

    public int updateSalesVolume(Book book) {
        return bookMapper.updateSalesVolume(book);
    }
    
    public int updateByOwner(Review review) {
        return reviewMapper.updateByOwner(review); // WHERE id AND member_id
    }
    
    public List<Book> getBestsellers(int limit) {
        return bookMapper.selectBestsellers(limit);
    }

    public List<Book> getRecommendedTopN(int n) {
        double C = reviewMapper.selectGlobalAvgScore(); // 전체 평균 평점
        int m = 5;                                      // 최소 리뷰수 가중치(5~10 추천)
        List<Book> all = bookMapper.selectRecommended(m, C);
        if (all == null) return Collections.emptyList();
        return all.size() > n ? all.subList(0, n) : all;
    }

}
