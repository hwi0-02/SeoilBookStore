package service;

import java.io.File;
import java.util.List;

import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import mapper.AdminMapper;
import mapper.OrderMapper;
import mapper.ReviewMapper;          
import model.Book;
import model.StatPoint;

@Service
public class AdminService {

    @Autowired
    private AdminMapper adminMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private ReviewMapper reviewMapper;   

    @Autowired
    private ServletContext servletContext;

    public List<Book> getBookList() {
        return adminMapper.getBookList();
    }

    public List<Book> searchBooks(String keyword) {
        return adminMapper.searchBooks(keyword);
    }

    public void save(Book book, MultipartFile file) {
        handleImageUpload(book, file, null);
        adminMapper.save(book);
    }

    public Book getBook(int id) {
        return adminMapper.getBook(id);
    }

    public void update(Book book, MultipartFile file) {
        handleImageUpload(book, file, book.getImage());
        adminMapper.update(book);
    }

    public void delete(int id) {
        // orderMapper.deleteOrderItemsByBookId(id);
        adminMapper.delete(id);
    }

    public List<StatPoint> getTopBookSales(String startDate, String endDate, Integer limit, String title, String author) {
        return orderMapper.selectTopBookSales(startDate, endDate, limit, title, author);
    }

    // 리뷰 수 기준 Top N 도서 집계
    public List<StatPoint> getTopBookReviewCount(String startDate, String endDate, Integer limit, String title, String author) {
        return reviewMapper.selectTopBookReviewCount(startDate, endDate, limit, title, author);
    }

    public List<Book> searchBooksByTitleAuthor(String title, String author) {
        return adminMapper.searchBooksByTitleAuthor(title, author);
    }

    private void handleImageUpload(Book book, MultipartFile file, String fallbackImage) {
        if (file == null || file.isEmpty()) {
            if (fallbackImage != null) {
                book.setImage(fallbackImage);
            }
            return;
        }

        String path = servletContext.getRealPath("/resources/images/");
        String filename = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        book.setImage(filename);
        File uploadDir = new File(path);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        File destination = new File(path + File.separator + filename);
        try {
            file.transferTo(destination);
        } catch (Exception e) {
            throw new IllegalStateException("이미지 업로드에 실패했습니다.", e);
        }
    }
}
