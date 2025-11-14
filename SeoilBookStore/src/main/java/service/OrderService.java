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
    private BookMapper bookMapper;
    
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
        enrichOrders(orders, false);
        return orders;
    }

    public Order getOrderById(int orderId) {
        Order order = orderMapper.selectById(orderId);
        enrichOrder(order, true);
        return order;
    }
    
    // 모든 주문 조회
    public List<Order> getAllOrders() {
        List<Order> orders = orderMapper.selectAll();
        enrichOrders(orders, true);
        return orders;
    }
    
    // 주문 검색 (예: 주문번호, 회원명 등 키워드 검색)
    public List<Order> searchOrders(String keyword) {
        List<Order> orders = orderMapper.search(keyword);	
        enrichOrders(orders, true);
        return orders;
    }
    
    // 관리자 필터 기반 주문 검색
    public List<Order> searchOrdersByFilters(String transactionId, String memberName, String startDate, String endDate) {
        List<Order> orders = orderMapper.selectByFilters(transactionId, memberName, startDate, endDate);
        enrichOrders(orders, true);
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
        List<Order> orders = orderMapper.selectByTransactionId(transactionId);
        enrichOrders(orders, true);
        return orders;
    }

    private void enrichOrders(List<Order> orders, boolean includeMember) {
        if (orders == null) return;
        for (Order order : orders) {
            enrichOrder(order, includeMember);
        }
    }

    private void enrichOrder(Order order, boolean includeMember) {
        if (order == null) return;
        Book book = bookMapper.selectBookById(order.getBookId());
        order.setBook(book);
        if (includeMember) {
            Member member = memberMapper.selectById(order.getMemberId());
            order.setMember(member);
        }
    }

}