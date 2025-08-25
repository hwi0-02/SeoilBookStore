package mapper;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;   
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import model.Review;
import model.StatPoint;                      

@Mapper
public interface ReviewMapper {

    // INSERT
    @Insert({
        "INSERT INTO review (id, book_id, member_id, score, content, wrote_on)",
        "VALUES (review_seq.nextval, #{bookId}, #{memberId}, #{score}, #{content}, sysdate)"
    })
    int save(Review review);

    // SELECT
    @Select("SELECT * FROM review WHERE id = #{id}")
    Review selectById(int id);

    @Select("SELECT * FROM review WHERE book_id = #{bookId} ORDER BY id DESC")
    List<Review> selectByBookId(int bookId);

    @Select("SELECT * FROM review WHERE member_id = #{memberId} ORDER BY id DESC")
    List<Review> selectByMemberId(int memberId);

    @Select("SELECT COUNT(*) FROM review WHERE book_id = #{bookId}")
    int countByBookId(int bookId);

    @Select("SELECT NVL(SUM(score), 0) FROM review WHERE book_id = #{bookId}")
    int sumScoreByBookId(int bookId);

    // UPDATE (안전: 본인만, 내용/별점만)
    @Update({
        "UPDATE review",
        "   SET score = #{score},",
        "       content = #{content}",
        " WHERE id = #{id}",
        "   AND member_id = #{memberId}"
    })
    int updateByOwner(Review review);

    // DELETE
    @Delete("DELETE FROM review WHERE id = #{id}")
    int deleteById(int id);

    @Delete("DELETE FROM review WHERE book_id = #{bookId}")
    int deleteByBookId(int bookId);

    @Delete("DELETE FROM review WHERE member_id = #{memberId}")
    int deleteByMemberId(int memberId);

    @Select("SELECT NVL(AVG(score), 0) FROM review")
    double selectGlobalAvgScore();

    // ★ 추가: 리뷰 수 Top N (기간/제목/저자 필터)
    @Select({
        "<script>",
        "SELECT * FROM (",
        "  SELECT b.title AS label, COUNT(r.id) AS count",
        "  FROM review r",
        "  JOIN book b ON b.id = r.book_id",
        "  WHERE 1=1",
        "  <if test=\"startDate != null and startDate != ''\">",
        "    AND r.wrote_on &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
        "  </if>",
        "  <if test=\"endDate != null and endDate != ''\">",
        "    AND r.wrote_on &lt;  TO_DATE(#{endDate},   'YYYY-MM-DD') + 1",
        "  </if>",
        "  <if test=\"title != null and title != ''\">",
        "    AND b.title  LIKE '%' || #{title}  || '%'",
        "  </if>",
        "  <if test=\"author != null and author != ''\">",
        "    AND b.author LIKE '%' || #{author} || '%'",
        "  </if>",
        "  GROUP BY b.title",
        "  ORDER BY COUNT(r.id) DESC, MIN(r.id) ASC",
        ")",
        " <if test=\"limit != null\"> WHERE ROWNUM &lt;= #{limit} </if>",
        "</script>"
    })
    List<StatPoint> selectTopBookReviewCount(
        @Param("startDate") String startDate,
        @Param("endDate")   String endDate,
        @Param("limit")     Integer limit,
        @Param("title")     String title,
        @Param("author")    String author
    );
}
