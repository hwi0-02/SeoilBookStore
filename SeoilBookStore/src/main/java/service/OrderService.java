package service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import mapper.BookMapper;
import mapper.MemberMapper;
import mapper.OrderMapper;
import model.Book;
import model.Member;
import model.Order;
import model.OrderStat;

@Service
public class OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private BookMapper bookMapper;  // Book 정보를 가져오는 Mapper 추가
    
    @Autowired
    private MemberMapper memberMapper;
    
    @Autowired
    private BookService bookService;

    // 주문 추가
    @Transactional
    public int insertOrder(Order order) {
    	int result = orderMapper.insert(order);
    	bookService.updateStock(order.getBookId(), order.getQuantity());
        return result;
    }

    // 특정 회원의 모든 주문 조회
    public List<Order> getOrdersByMemberId(int memberId) {
    	List<Order> orders = orderMapper.selectByMemberId(memberId);
    	for(Order order : orders) {
    		Book book = bookMapper.selectBookById(order.getBookId());
    		order.setBook(book);
    	}
        return orders;
    }

    public Order getOrderById(int orderId) {
        Order order = orderMapper.selectById(orderId);

        // 책 정보 주입
        Book book = bookMapper.selectBookById(order.getBookId());
        order.setBook(book);

        // 회원 정보 주입
        Member member = memberMapper.selectById(order.getMemberId());
        order.setMember(member);

        return order;
    }
    
    // 모든 주문 조회
    public List<Order> getAllOrders() {
        List<Order> orders = orderMapper.selectAll();
        for (Order order : orders) {
            Book book = bookMapper.selectBookById(order.getBookId());
            Member member = memberMapper.selectById(order.getMemberId());
            order.setBook(book);
            order.setMember(member);
        }
        return orders;
    }
    
    // 주문 검색 (예: 주문번호, 회원명 등 키워드 검색)
    public List<Order> searchOrders(String keyword) {
    	List<Order> orders = orderMapper.search(keyword);	
        for (Order order : orders) {
            Book book = bookMapper.selectBookById(order.getBookId());
            Member member = memberMapper.selectById(order.getMemberId());
            order.setBook(book);
            order.setMember(member);
        }
        return orders;
    }
    
 // [ADD] 관리자 필터 기반 조회
    public List<Order> searchOrdersByFilters(String transactionId, String memberName, String startDate, String endDate) {
        List<Order> orders = orderMapper.selectByFilters(transactionId, memberName, startDate, endDate);

        // 기존 스타일 유지: Book/Member 주입
        for (Order order : orders) {
            Book book = bookMapper.selectBookById(order.getBookId());
            Member member = memberMapper.selectById(order.getMemberId());
            order.setBook(book);
            order.setMember(member);
        }
        return orders;
    }
    
    public List<OrderStat> getOrderStats(String transactionId, String memberName, String startDate, String endDate, String period) {
        switch (period == null ? "day" : period) {
            case "year":
                return orderMapper.selectOrderStatsByYear(transactionId, memberName, startDate, endDate);
            case "month":
                return orderMapper.selectOrderStatsByMonth(transactionId, memberName, startDate, endDate);
            default:
                return orderMapper.selectOrderStatsByDay(transactionId, memberName, startDate, endDate);
        }
    }
    

    public List<Order> getOrdersByTransactionId(String transactionId) {
        return orderMapper.selectByTransactionId(transactionId);
    }

}