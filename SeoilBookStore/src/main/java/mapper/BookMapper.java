package mapper;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import model.Book;
@Mapper
public interface BookMapper {

    @Select("SELECT id, title, author, price, description, image, stock, sales_volume FROM book WHERE id = #{id}")
    Book selectBookById(int id);

    @Select("SELECT id, title, author, price, description, image, stock, sales_volume FROM book")
    List<Book> selectAllBooks();

    @Select("SELECT id, title, author, price, description, image, stock FROM book WHERE title LIKE '%' || #{keyword} || '%' OR author LIKE '%' || #{keyword} || '%'")
    List<Book> searchBooks(String keyword);

    @Insert("INSERT INTO book (title, author, price, description, image, stock) " +
            "VALUES (#{title}, #{author}, #{price}, #{description}, #{image}, #{stock})")
    int insert(Book book);

    @Update("UPDATE book SET title = #{title}, author = #{author}, price = #{price}, " +
            "description = #{description}, image = #{image}, stock = #{stock} WHERE id = #{id}")
    int update(Book book);

    @Delete("DELETE FROM book WHERE id = #{id}")
    int delete(int id);
    
    @Update("UPDATE book SET stock = stock - #{quantity} WHERE id = #{bookId}")
    int updateStock(@Param("bookId") int bookId, @Param("quantity") int quantity);
    
    @Update("UPDATE book SET sales_volume = #{salesVolume} WHERE id = #{id}")
	int updateSalesVolume(Book book);
    
    @Select(
    		  "SELECT * FROM (" +
    		  "  SELECT b.id AS id, b.title AS title, b.author AS author, b.price AS price, " +
    		  "         b.description AS description, b.image AS image, b.stock AS stock, " +
    		  "         NVL(SUM(o.quantity), 0) AS salesVolume " +
    		  "  FROM book b " +
    		  "  LEFT JOIN orders o ON o.book_id = b.id " +
    		  "  GROUP BY b.id, b.title, b.author, b.price, b.description, b.image, b.stock " +
    		  "  ORDER BY salesVolume DESC" +
    		  ") WHERE ROWNUM <= #{limit}"
    		)
    		List<Book> selectBestsellers(@Param("limit") int limit);
    
    @Select(
    	    "SELECT " +
    	    "  b.id, b.title, b.author, b.price, b.description, b.image, b.stock, b.sales_volume AS salesVolume, " +
    	    "  NVL(COUNT(r.id), 0)  AS reviewCount, " +
    	    "  NVL(AVG(r.score), 0) AS avgScore, " +
    	    "  ( (NVL(COUNT(r.id),0) / (NVL(COUNT(r.id),0) + #{m})) * NVL(AVG(r.score),0) " +
    	    "  + (#{m} / (NVL(COUNT(r.id),0) + #{m})) * #{C} ) AS weightedScore " +
    	    "FROM book b " +
    	    "LEFT JOIN review r ON r.book_id = b.id " +
    	    "GROUP BY b.id, b.title, b.author, b.price, b.description, b.image, b.stock, b.sales_volume " +
    	    "ORDER BY weightedScore DESC, reviewCount DESC, b.sales_volume DESC NULLS LAST, b.id DESC"
    	)
    	List<model.Book> selectRecommended(@org.apache.ibatis.annotations.Param("m") int m,
    	                                            @org.apache.ibatis.annotations.Param("C") double C);

    
    
}
