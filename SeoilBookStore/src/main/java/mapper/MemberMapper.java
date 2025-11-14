package mapper;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import model.Member;

@Mapper
public interface MemberMapper {

	@Select("SELECT * FROM member WHERE id = #{id}")
  Member selectById(int id);

	@Select("SELECT * FROM member WHERE user_id = #{userId}")
	Member selectByUserId(String userId);

	@Select("SELECT * FROM member ORDER BY created_At DESC")
	List<Member> selectAll();

	@Insert("INSERT INTO member (id, user_id, password, name, phone, address, created_at, role) "
			+ "VALUES (MEMBER_SEQ.NEXTVAL, #{userId}, #{password}, #{name}, #{phone}, #{address}, CURRENT_DATE, 'USER')")
	int insert(Member member);

	@Update("UPDATE member SET password = #{password}, "
			+ "name = #{name}, phone = #{phone}, address = #{address} WHERE user_id = #{userId}")
	int update(Member member);

	@Update("UPDATE member SET password = #{password}, name = #{name}, phone = #{phone}, address = #{address} WHERE id = #{id}")
	int updateById(Member member);

	@Delete("DELETE FROM member WHERE user_id = #{userId}")
  int delete(String userId);

	@Delete("DELETE FROM member WHERE id = #{id}")
	int deleteById(int id);

	@Select("SELECT * FROM member WHERE phone = #{phone}")
	Member selectByHp(String phone);

    @Select("SELECT * FROM MEMBER " +
            "WHERE name LIKE '%' || #{keyword} || '%' " +
            "   OR user_id LIKE '%' || #{keyword} || '%'")
    List<Member> searchByKeyword(String keyword);
    
	// 이름, 아이디, 가입 기간 조건 검색
    @Select({
      "<script>",
      "SELECT *",
      "  FROM MEMBER",
      " WHERE 1=1",
      // 이름 LIKE (대소문자 무시)
      " <if test='name != null and name.trim() != \"\"'>",
      "   AND LOWER(name) LIKE '%' || LOWER(#{name}) || '%'",
      " </if>",
      // 아이디 LIKE (대소문자 무시)
      " <if test='userId != null and userId.trim() != \"\"'>",
      "   AND LOWER(user_id) LIKE '%' || LOWER(#{userId}) || '%'",
      " </if>",
      // 가입 시작일 (이상)
      " <if test='startDate != null and startDate.trim() != \"\"'>",
      "   AND created_at &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
      " </if>",
      // 가입 종료일 (이하) — 종일 포함을 위해 + 1일 미만
      " <if test='endDate != null and endDate.trim() != \"\"'>",
      "   AND created_at &lt; TO_DATE(#{endDate}, 'YYYY-MM-DD') + 1",
      " </if>",
      " ORDER BY created_at DESC",
      "</script>"
    })
    List<Member> searchByFilters(
      @Param("name") String name,
      @Param("userId") String userId,
      @Param("startDate") String startDate,  // yyyy-MM-dd
      @Param("endDate") String endDate       // yyyy-MM-dd
    );
    
	// 가입자 통계를 연·월·일 단위로 집계
    @Select({
      "<script>",
      "SELECT label, COUNT(*) AS count",
      "FROM (",
      "  SELECT CASE",
      "    WHEN #{period} = 'year'  THEN TO_CHAR(created_at, 'YYYY')",
      "    WHEN #{period} = 'month' THEN TO_CHAR(created_at, 'YYYY-MM')",
      "    ELSE TO_CHAR(created_at, 'YYYY-MM-DD')",
      "  END AS label",
      "  FROM MEMBER",
      "  WHERE 1=1",
      "  <if test='startDate != null and startDate.trim() != \"\"'>",
      "    AND created_at &gt;= TO_DATE(#{startDate}, 'YYYY-MM-DD')",
      "  </if>",
      "  <if test='endDate != null and endDate.trim() != \"\"'>",
      "    AND created_at &lt;  TO_DATE(#{endDate},   'YYYY-MM-DD') + 1",
      "  </if>",
      ")",
      "GROUP BY label",
      "ORDER BY label",
      "</script>"
    })
    List<model.StatPoint> selectSignupStats(
      @Param("startDate") String startDate,  // yyyy-MM-dd
      @Param("endDate")   String endDate,    // yyyy-MM-dd
      @Param("period")    String period      // year | month | day
    );

    
}