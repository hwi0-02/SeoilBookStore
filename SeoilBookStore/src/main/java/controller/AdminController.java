package controller;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import model.Book;
import model.Member;
import model.Order;
import model.Review;
import model.StatPoint;// ★ (선택) 명시 임포트
import service.AdminService;
import service.BookService;
import service.MemberService;
import service.OrderService;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired private AdminService adminservice;
    @Autowired private MemberService memberservice;
    @Autowired private OrderService orderservice;
    @Autowired private BookService bookservice;

    @RequestMapping("books")
    public ModelAndView adminMainlist(
            ModelAndView mv,
            @RequestParam(value = "keyword",   required = false) String keyword,
            @RequestParam(value = "startDate", required = false) String startDate, // yyyy-MM-dd
            @RequestParam(value = "endDate",   required = false) String endDate,   // yyyy-MM-dd
            @RequestParam(value = "limit",     required = false) Integer limit,    // Top N
            @RequestParam(value = "title",     required = false) String title,
            @RequestParam(value = "author",    required = false) String author,
            @RequestParam(value = "metric",    required = false, defaultValue = "sales") String metric // ★ 추가
    ) {
        // 리스트 조회(기존 로직 유지)
        List<Book> books;
        if ((title != null && !title.trim().isEmpty()) ||
            (author != null && !author.trim().isEmpty())) {
            books = adminservice.searchBooksByTitleAuthor(title, author);
        } else if (keyword != null && !keyword.trim().isEmpty()) {
            books = adminservice.searchBooks(keyword);
        } else {
            books = adminservice.getBookList();
        }
        mv.addObject("books", books);
        mv.addObject("keyword", keyword);

        
        List<StatPoint> chartStats;
        if ("reviews".equalsIgnoreCase(metric)) {
            chartStats = adminservice.getTopBookReviewCount(startDate, endDate, limit, title, author);
        } else {
            chartStats = adminservice.getTopBookSales(startDate, endDate, limit, title, author);
            metric = "sales"; // 방어적 정규화
        }
        // JSP 호환 위해 기존 키 'bookSalesStats' 유지 사용
        mv.addObject("bookSalesStats", chartStats);  
        mv.addObject("chartMetric", metric);         // ← JSP에서 라벨/제목 바꾸고 싶을 때 사용할 수 있음
        mv.addObject("chartMetricLabel", "reviews".equals(metric) ? "리뷰 수" : "판매 수량"); // (옵션)

        // 입력값 유지(기존)
        mv.addObject("paramStartDate", startDate == null ? "" : startDate);
        mv.addObject("paramEndDate",   endDate   == null ? "" : endDate);
        mv.addObject("title", title);
        mv.addObject("author", author);
        mv.addObject("paramMetric", metric);

        if (limit == null) {
            mv.addObject("paramLimit", "");
        } else {
            mv.addObject("paramLimit", limit);
        }

        mv.setViewName("admin/adminbooklist");
        mv.addObject("page", "books");
        return mv;
    }

    @RequestMapping("addbook")
    public String addBook() { return "admin/addbookform"; }

    @PostMapping("save")
    public String save(@RequestParam("title") String title,
                       @RequestParam("author") String author,
                       @RequestParam("price") int price,
                       @RequestParam("description") String description,
                       @RequestParam("image") MultipartFile file,
                       @RequestParam("stock") int stock) {
        Book book = new Book();
        book.setTitle(title);
        book.setAuthor(author);
        book.setDescription(description);
        book.setPrice(price);
        book.setStock(stock);
        adminservice.save(book, file);
        return "redirect:/admin/books";
    }

    @GetMapping("books/detail")
    public ModelAndView showBookDetail(ModelAndView mv, @RequestParam("id") int id) {
        Book book = adminservice.getBook(id);
        mv.addObject("book", book);

        List<Review> reviewList = bookservice.getReviewsByBook(id);
        for (Review r : reviewList) {
            Member m = memberservice.selectById(r.getMemberId());
            r.setMember(m);
        }
        mv.addObject("reviewList", reviewList);

        int reviewCount = bookservice.getCountByBookId(id);
        int reviewSum   = bookservice.getSumByBookId(id);
        float reviewAvg = (reviewCount > 0) ? (float) reviewSum / reviewCount : 0f;
        mv.addObject("reviewCount", reviewCount);
        mv.addObject("reviewAverage", reviewAvg);

        mv.setViewName("admin/adminbookdetail");
        return mv;
    }

    @PostMapping("reviews/delete")
    public String adminDeleteReview(@RequestParam("id") int id,
                                    @RequestParam("bookId") int bookId) {
        bookservice.deleteById(id);
        return "redirect:/admin/books/detail?id=" + bookId;
    }

    @GetMapping("books/edit")
    public ModelAndView showEditForm(ModelAndView mv, int id) {
        mv.addObject("book", adminservice.getBook(id));
        mv.setViewName("admin/adminbookedit");
        return mv;
    }

    @PostMapping("books/update")
    public String processEdit(@RequestParam("id") int id,
                              @RequestParam("title") String title,
                              @RequestParam("author") String author,
                              @RequestParam("price") int price,
                              @RequestParam("description") String description,
                              @RequestParam("image") MultipartFile file,
                              @RequestParam("originImage") String originImage,
                              @RequestParam("stock") int stock) {
        Book book = new Book();
        book.setId(id);
        book.setTitle(title);
        book.setAuthor(author);
        book.setDescription(description);
        book.setPrice(price);
        book.setStock(stock);
        if (file.isEmpty()) {
            book.setImage(originImage);
        }
        adminservice.update(book, file);
        return "redirect:/admin/books/detail?id=" + book.getId();
    }

    @PostMapping("books/delete")
    public String deleteBook(int id) {
        adminservice.delete(id);
        return "redirect:/admin/books";
    }

    // ===== 멤버/주문 이하 기존 그대로 =====

    @RequestMapping("adminmemberlist")
    public ModelAndView adminMemberlist(ModelAndView mv,
            @RequestParam(value = "name",      required = false) String name,
            @RequestParam(value = "userId",    required = false) String userId,
            @RequestParam(value = "startDate", required = false) String startDate,
            @RequestParam(value = "endDate",   required = false) String endDate,
            @RequestParam(value = "period",    required = false, defaultValue = "day") String period) {
        if ((name == null || name.isBlank()) &&
            (userId == null || userId.isBlank()) &&
            (startDate == null || startDate.isBlank()) &&
            (endDate == null || endDate.isBlank())) {
            mv.addObject("members", memberservice.getAllMembers());
        } else {
            mv.addObject("members", memberservice.searchMembersByFilters(name, userId, startDate, endDate));
        }
        mv.addObject("signupStats", memberservice.getSignupStats(startDate, endDate, period));
        mv.addObject("period", period);
        mv.addObject("paramName", name == null ? "" : name);
        mv.addObject("paramUserId", userId == null ? "" : userId);
        mv.addObject("paramStartDate", startDate == null ? "" : startDate);
        mv.addObject("paramEndDate", endDate == null ? "" : endDate);
        mv.addObject("page", "members");
        mv.setViewName("admin/adminmemberlist");
        return mv;
    }

    @RequestMapping("adminmemberlist/edit")
    public ModelAndView adminMemberEdit(ModelAndView mv, String userId) {
        mv.addObject("member", memberservice.selectByUserId(userId));
        mv.setViewName("admin/adminmemberedit");
        return mv;
    }

    @RequestMapping("adminmemberlist/update")
    public String adminMemberUpdate(@RequestParam("id") int id,
                                    @RequestParam("userId") String userId,
                                    @RequestParam("password") String password,
                                    @RequestParam("name") String name,
                                    @RequestParam("phone") String phone,
                                    @RequestParam("address") String address) {
        Member member = new Member();
        member.setId(id);
        member.setUserId(userId);
        member.setPassword(password);
        member.setName(name);
        member.setPhone(phone);
        member.setAddress(address);
        memberservice.modifyById(member);
        return "redirect:/admin/adminmemberlist";
    }

    @RequestMapping("adminmemberlist/delete")
    public String adminMemberDelete(String userId) {
        memberservice.remove(userId);
        return "redirect:/admin/adminmemberlist";
    }

    @RequestMapping("adminorderlist")
    public ModelAndView adminOrderlist(
            ModelAndView mv,
            @RequestParam(value = "transactionId", required = false) String transactionId,
            @RequestParam(value = "memberName",    required = false) String memberName,
            @RequestParam(value = "startDate",     required = false) String startDate,
            @RequestParam(value = "endDate",       required = false) String endDate,
            @RequestParam(value = "period",        required = false, defaultValue = "day") String period) {
        List<Order> orders = orderservice.searchOrdersByFilters(transactionId, memberName, startDate, endDate);
        Map<String, List<Order>> groupedOrders = new LinkedHashMap<>();
        for (Order order : orders) {
            groupedOrders.computeIfAbsent(order.getTransactionId(), k -> new ArrayList<>()).add(order);
        }
        mv.addObject("orderStats", orderservice.getOrderStats(transactionId, memberName, startDate, endDate, period));
        mv.addObject("groupedOrders", groupedOrders);
        mv.addObject("period", period);
        mv.addObject("page", "orders");
        mv.addObject("paramTransactionId", transactionId == null ? "" : transactionId);
        mv.addObject("paramMemberName",    memberName    == null ? "" : memberName);
        mv.addObject("paramStartDate",     startDate     == null ? "" : startDate);
        mv.addObject("paramEndDate",       endDate       == null ? "" : endDate);
        mv.setViewName("admin/adminorderlist");
        return mv;
    }

    @RequestMapping("adminorderlist/detail")
    public ModelAndView adminOrderDetailByTransaction(@RequestParam("transactionId") String transactionId) {
        ModelAndView mv = new ModelAndView();
        List<Order> orders = orderservice.getOrdersByTransactionId(transactionId);
        if (orders == null || orders.isEmpty()) {
            mv.setViewName("redirect:/admin/adminorderlist");
            return mv;
        }
        for (Order order : orders) {
            Book book = bookservice.getBookById(order.getBookId());
            Member member = memberservice.selectById(order.getMemberId());
            order.setBook(book);
            order.setMember(member);
        }
        mv.addObject("orders", orders);
        mv.addObject("transactionId", transactionId);
        mv.setViewName("admin/adminorderdetail");
        return mv;
    }

    @RequestMapping("adminorderlist/delete")
    public String adminOrderDelete(String userId) {
        memberservice.remove(userId);
        return "redirect:/admin/adminorderlist";
    }
}
