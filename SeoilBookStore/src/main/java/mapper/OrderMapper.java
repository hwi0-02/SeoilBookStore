package mapper;

import java.util.List;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;

import model.Order;
import model.StatPoint;

public interface OrderMapper {

    @Select("SELECT * FROM ORDERS WHERE member_id = #{memberId} ORDER BY order_date DESC")
    public List<Order> selectByMemberId(int memberId);

    @Select("SELECT * FROM ORDERS ORDER BY order_date desc")
    List<Order> selectAll();

    @Select("SELECT * FROM ORDERS WHERE transaction_id = #{transactionId}")
    List<Order> selectByTransactionId(String transactionId);

    @Insert({
        "<script>",
        "INSERT INTO ORDERS (id, member_id, book_id, quantity, total_price, order_date, transaction_id)",
        "VALUES (",
        "  ORDERS_SEQ.NEXTVAL,",
        "  #{memberId}, #{bookId}, #{quantity}, #{totalPrice},",
        "  NVL(#{orderDate,jdbcType=TIMESTAMP}, CURRENT_DATE),",
        "  #{transactionId}",
        ")",
        "</script>"
    })
    int insert(Order order);

    @Select("SELECT * FROM ORDERS WHERE id = #{orderId}")
    Order selectById(int orderId);

    @Select({
        "SELECT o.id, o.member_id AS memberId, ",
        "       o.book_id AS bookId, o.quantity, o.total_price AS totalPrice, o.order_date AS orderDate, ",
        "       b.id AS b_id, b.title AS b_title,",
        "       m.id AS m_id, m.name AS m_name ",
        "FROM ORDERS o ",
        "JOIN BOOK b ON o.book_id = b.id ",
        "JOIN MEMBER m ON o.member_id = m.id ",
        "WHERE TO_CHAR(o.id) LIKE '%' || #{keyword} || '%' ",
        "   OR LOWER(b.title) LIKE '%' || #{keyword} || '%' ",
        "   OR LOWER(m.name)  LIKE '%' || #{keyword} || '%' ",
        "ORDER BY o.id DESC"
    })
    @Results({
        @Result(property="id", column="id"),
        @Result(property="memberId", column="memberId"),
        @Result(property="bookId", column="bookId"),
        @Result(property="quantity", column="quantity"),
        @Result(property="totalPrice", column="totalPrice"),
        @Result(property="orderDate", column="orderDate"),
        @Result(property="book.id", column="b_id"),
        @Result(property="book.title", column="b_title"),
        @Result(property="member.id", column="m_id"),
        @Result(property="member.name", column="m_name")
    })
    List<Order> search(String keyword);

    // =========================
    // 관리자 필터 조회
    // =========================
    @Select({
        "<script>",
        "SELECT",
        "  o.id,",
        "  o.member_id      AS memberId,",
        "  o.book_id        AS bookId,",
        "  o.quantity       AS quantity,",
        "  o.total_price    AS totalPrice,",
        "  o.order_date     AS orderDate,",
        "  o.transaction_id AS transactionId",
        "FROM ORDERS o",
        "JOIN MEMBER m ON m.id = o.member_id",
        "<where>",
        "  <if test='transactionId != null and transactionId != \"\"'>",
        "    AND UPPER(o.transaction_id) LIKE '%' || UPPER(#{transactionId}) || '%'",
        "  </if>",
        "  <if test='memberName != null and memberName != \"\"'>",
        "    AND (UPPER(m.name) LIKE '%' || UPPER(#{memberName}) || '%' ",
        "         OR UPPER(m.user_id) LIKE '%' || UPPER(#{memberName}) || '%')",
        "  </if>",
        "  <if test='startDate != null and startDate != \"\"'>",
        "    AND o.order_date &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
        "  </if>",
        "  <if test='endDate != null and endDate != \"\"'>",
        "    AND o.order_date &lt;  TO_DATE(#{endDate}, 'YYYY-MM-DD') + 1",
        "  </if>",
        "</where>",
        "ORDER BY o.order_date DESC",
        "</script>"
    })
    List<Order> selectByFilters(
        @Param("transactionId") String transactionId,
        @Param("memberName")    String memberName,
        @Param("startDate")     String startDate,
        @Param("endDate")       String endDate
    );

    // ===== 통계: 일 단위 (라벨, 건수, 총수량, 총금액) =====
    @Select({
        "<script>",
        "SELECT TO_CHAR(o.order_date,'YYYY-MM-DD') AS label,",
        "       COUNT(DISTINCT o.transaction_id)   AS count,",
        "       SUM(o.quantity)                    AS sumQty,",
        "       SUM(o.total_price)                 AS sumAmount",
        "FROM ORDERS o JOIN MEMBER m ON m.id = o.member_id",
        "<where>",
        "  <if test='transactionId != null and transactionId != \"\"'>",
        "    AND UPPER(o.transaction_id) LIKE '%' || UPPER(#{transactionId}) || '%'",
        "  </if>",
        "  <if test='memberName != null and memberName != \"\"'>",
        "    AND (UPPER(m.name) LIKE '%' || UPPER(#{memberName}) || '%' ",
        "         OR UPPER(m.user_id) LIKE '%' || UPPER(#{memberName}) || '%')",
        "  </if>",
        "  <if test='startDate != null and startDate != \"\"'>",
        "    AND o.order_date &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
        "  </if>",
        "  <if test='endDate != null and endDate != \"\"'>",
        "    AND o.order_date &lt;  TO_DATE(#{endDate}, 'YYYY-MM-DD') + 1",
        "  </if>",
        "</where>",
        "GROUP BY TO_CHAR(o.order_date,'YYYY-MM-DD')",
        "ORDER BY label",
        "</script>"
    })
    List<model.OrderStat> selectOrderStatsByDay(
        @Param("transactionId") String transactionId,
        @Param("memberName")    String memberName,
        @Param("startDate")     String startDate,
        @Param("endDate")       String endDate
    );

    // ===== 통계: 월 단위 =====
    @Select({
        "<script>",
        "SELECT TO_CHAR(o.order_date,'YYYY-MM')    AS label,",
        "       COUNT(DISTINCT o.transaction_id)   AS count,",
        "       SUM(o.quantity)                    AS sumQty,",
        "       SUM(o.total_price)                 AS sumAmount",
        "FROM ORDERS o JOIN MEMBER m ON m.id = o.member_id",
        "<where>",
        "  <if test='transactionId != null and transactionId != \"\"'>",
        "    AND UPPER(o.transaction_id) LIKE '%' || UPPER(#{transactionId}) || '%'",
        "  </if>",
        "  <if test='memberName != null and memberName != \"\"'>",
        "    AND (UPPER(m.name) LIKE '%' || UPPER(#{memberName}) || '%' ",
        "         OR UPPER(m.user_id) LIKE '%' || UPPER(#{memberName}) || '%')",
        "  </if>",
        "  <if test='startDate != null and startDate != \"\"'>",
        "    AND o.order_date &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
        "  </if>",
        "  <if test='endDate != null and endDate != \"\"'>",
        "    AND o.order_date &lt;  TO_DATE(#{endDate}, 'YYYY-MM-DD') + 1",
        "  </if>",
        "</where>",
        "GROUP BY TO_CHAR(o.order_date,'YYYY-MM')",
        "ORDER BY label",
        "</script>"
    })
    List<model.OrderStat> selectOrderStatsByMonth(
        @Param("transactionId") String transactionId,
        @Param("memberName")    String memberName,
        @Param("startDate")     String startDate,
        @Param("endDate")       String endDate
    );

    // ===== 통계: 연 단위 =====
    @Select({
        "<script>",
        "SELECT TO_CHAR(o.order_date,'YYYY')       AS label,",
        "       COUNT(DISTINCT o.transaction_id)   AS count,",
        "       SUM(o.quantity)                    AS sumQty,",
        "       SUM(o.total_price)                 AS sumAmount",
        "FROM ORDERS o JOIN MEMBER m ON m.id = o.member_id",
        "<where>",
        "  <if test='transactionId != null and transactionId != \"\"'>",
        "    AND UPPER(o.transaction_id) LIKE '%' || UPPER(#{transactionId}) || '%'",
        "  </if>",
        "  <if test='memberName != null and memberName != \"\"'>",
        "    AND (UPPER(m.name) LIKE '%' || UPPER(#{memberName}) || '%' ",
        "         OR UPPER(m.user_id) LIKE '%' || UPPER(#{memberName}) || '%')",
        "  </if>",
        "  <if test='startDate != null and startDate != \"\"'>",
        "    AND o.order_date &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
        "  </if>",
        "  <if test='endDate != null and endDate != \"\"'>",
        "    AND o.order_date &lt;  TO_DATE(#{endDate}, 'YYYY-MM-DD') + 1",
        "  </if>",
        "</where>",
        "GROUP BY TO_CHAR(o.order_date,'YYYY')",
        "ORDER BY label",
        "</script>"
    })
    List<model.OrderStat> selectOrderStatsByYear(
        @Param("transactionId") String transactionId,
        @Param("memberName")    String memberName,
        @Param("startDate")     String startDate,
        @Param("endDate")       String endDate
    );

    // ===== 인기 도서 Top-N (기간 필터) =====
    @Select({
        "<script>",
        "SELECT * FROM (",
        "  SELECT",
        "    MAX(b.title) AS label,",
        "    SUM(o.quantity) AS count",
        "  FROM ORDERS o",
        "  JOIN BOOK b ON b.id = o.book_id",
        "  <where>",
        "    <if test='startDate != null and startDate.trim() != \"\"'>",
        "      AND o.order_date &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
        "    </if>",
        "    <if test='endDate != null and endDate.trim() != \"\"'>",
        "      AND o.order_date &lt; TO_DATE(#{endDate}, 'YYYY-MM-DD') + 1",
        "    </if>",
        "    <if test='title != null and title.trim() != \"\"'>",
        "      AND LOWER(b.title) LIKE '%' || LOWER(#{title}) || '%'",
        "    </if>",
        "    <if test='author != null and author.trim() != \"\"'>",
        "      AND LOWER(b.author) LIKE '%' || LOWER(#{author}) || '%'",
        "    </if>",
        "  </where>",
        "  GROUP BY b.id",
        "  ORDER BY SUM(o.quantity) DESC",
        ")",
        "<if test='limit != null and limit > 0'>",
        " WHERE ROWNUM &lt;= #{limit}",
        "</if>",
        "</script>"
    })
    List<StatPoint> selectTopBookSales(
        @Param("startDate") String startDate,
        @Param("endDate")   String endDate,
        @Param("limit")     Integer limit,
        @Param("title")     String title,
        @Param("author")    String author
    );
}
