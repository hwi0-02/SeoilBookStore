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
public interface AdminMapper {
    
	@Select("select * from book")
	public List<Book> getBookList();	
	
	@Select("SELECT * FROM book WHERE title LIKE '%' || #{keyword} || '%' OR author LIKE '%' || #{keyword} || '%'")
	List<Book> searchBooks(String keyword);
	
	@Insert("insert into book (id, title, author, description, price, image, stock) "
			+ "values (book_seq.NEXTVAL, #{title}, #{author}, #{description}, #{price}, #{image}, #{stock})")
	public int save(Book book);
	
	@Select("select * from book where id = #{id}")
	public Book getBook(int id);
	
	@Update("update book set title=#{title}, author=#{author}, description=#{description}, "
			+ "price=#{price}, image=#{image}, stock=#{stock} where id=#{id}")
	public void update(Book book);
	
	@Delete("delete from book where id=#{id}")
	public void delete(int id);

	@Select({
	  "<script>",
	  "SELECT * FROM book",
	  "WHERE 1=1",
	  "  <if test='title != null and title.trim() != \"\"'>",
	  "    AND LOWER(title) LIKE '%' || LOWER(#{title}) || '%'",
	  "  </if>",
	  "  <if test='author != null and author.trim() != \"\"'>",
	  "    AND LOWER(author) LIKE '%' || LOWER(#{author}) || '%'",
	  "  </if>",
	  "</script>"
	})
	List<Book> searchBooksByTitleAuthor(
	    @Param("title") String title,
	    @Param("author") String author
	);
	
	
}
