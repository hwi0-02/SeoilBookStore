package controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import model.Book;
import model.CartItem;
import model.Member;
import model.Order;
import service.BookService;
import service.OrderService;

@Controller
@RequestMapping("/orders")
public class OrderController {

	@Autowired
	private OrderService orderService;

	@Autowired
	private BookService bookService;

	// ✅ [1] 특정 회원 주문 내역 조회
	@GetMapping("/member/orderlist")
	public String getOrdersByMemberId(HttpSession session, Model model) {
		Member loginUser = (Member) session.getAttribute("loginUser");
        if (loginUser == null) {
            // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
            return "redirect:/member/loginform";
        }
		List<Order> orderList = orderService.getOrdersByMemberId(loginUser.getId());
		Map<String, List<Order>> groupedOrders = orderList.stream()
			    .collect(Collectors.groupingBy(
			        Order::getTransactionId,
			        LinkedHashMap::new,
			        Collectors.toList()
			    )); // 주문을 최신순으로 정렬하기 위함.
		model.addAttribute("groupedOrders", groupedOrders);
		return "user/member_orders"; // → /WEB-INF/views/order/member_orders.jsp
	}

	// ✅ [3] 주문 등록 처리
	@PostMapping("/insert")
	public String insertOrder(@ModelAttribute Order order) {
		orderService.insertOrder(order);
		return "redirect:/orders/member/" + order.getMemberId(); // 등록 후 내 주문 내역으로 이동
	}

	@PostMapping("/buyNow")
	public String buyNow(@RequestParam("bookId") int bookId, @RequestParam("quantity") int quantity,
			HttpSession session, RedirectAttributes redirectAttributes) {
		Member loginUser = (Member) session.getAttribute("loginUser");
		if (loginUser == null) {
			return "redirect:/member/loginform";
		}

		Book book = bookService.getBookById(bookId);
		if (book == null) {
			redirectAttributes.addFlashAttribute("errorMsg", "책 정보를 찾을 수 없습니다.");
			return "redirect:/books";
		}
		
		// 재고 확인
		if (book.getStock() < quantity) {
			redirectAttributes.addFlashAttribute("errorMsg", "재고가 부족합니다.");
			return "redirect:/books/" + bookId;
		}
		
		Order order = new Order();
		order.setBookId(book.getId());
		order.setQuantity(quantity);
		order.setBook(book);
		order.setMemberId(loginUser.getId());
		order.setTotalPrice(book.getPrice() * quantity);
		order.setBook(book);
		order.setOrderDate(new Date());
		
		String transactionId = loginUser.getId() + "_" + System.currentTimeMillis();
	    order.setTransactionId(transactionId);
		
		session.setAttribute("order", order);
		return "redirect:/orders/payment"; 
	}

	@PostMapping("/checkout")
	public String checkout(HttpSession session, RedirectAttributes redirectAttributes) {
		Member loginUser = (Member) session.getAttribute("loginUser");
		if (loginUser == null) {
			return "redirect:/member/loginform";
		}

		Map<Integer, CartItem> cartMap = (Map<Integer, CartItem>) session.getAttribute("cart");
		if (cartMap == null || cartMap.isEmpty()) {
			redirectAttributes.addFlashAttribute("errorMsg", "장바구니가 비어있습니다.");
			return "redirect:/cart";
		}

		List<Order> orders = new ArrayList<>();
		for (CartItem cartItem : cartMap.values()) {
			Order order = new Order();
			order.setBookId(cartItem.getBook().getId());
			order.setQuantity(cartItem.getQuantity());
			order.setOrderDate(new Date());
			order.setBook(cartItem.getBook());
			order.setTotalPrice(cartItem.getQuantity() * cartItem.getBook().getPrice());
			order.setMemberId(loginUser.getId());
			orders.add(order);
		}
		
		session.setAttribute("orders", orders);

//		session.removeAttribute("cart"); 
		return "redirect:/orders/payment";
	}
	
	@GetMapping("/payment")
	public String showPaymentPage(HttpSession session, Model model, RedirectAttributes redirectAttributes) {
		Order order = (Order) session.getAttribute("order");
		List<Order> orders = (List<Order>) session.getAttribute("orders");
		Member loginUser = (Member) session.getAttribute("loginUser");

		if ((order == null && (orders == null || orders.isEmpty())) || loginUser == null) {
			redirectAttributes.addFlashAttribute("errorMsg", "주문 또는 사용자 정보가 없습니다.");
			return "redirect:/cart";
		}

		if (order != null) {
			model.addAttribute("order", order);
		}

		if (orders != null && !orders.isEmpty()) {
			model.addAttribute("orders", orders);
			int totalAmount = 0;
			for (Order o : orders) {
				totalAmount += o.getTotalPrice();
			}
			model.addAttribute("totalAmount", totalAmount);
		}

		model.addAttribute("loginUser", loginUser);
		return "user/payment";
	}

	@PostMapping("/confirm")
	public String confirmOrder(HttpSession session, RedirectAttributes redirectAttributes) {
		Member loginUser = (Member) session.getAttribute("loginUser");
		if (loginUser == null) {
			return "redirect:/member/loginform";
		}
		
		Order singleOrder = (Order) session.getAttribute("order");
		List<Order> orderList = (List<Order>) session.getAttribute("orders");

		if (singleOrder == null && (orderList == null || orderList.isEmpty())) {
			redirectAttributes.addFlashAttribute("errorMsg", "주문 정보가 없습니다.");
			return "redirect:/cart";
		}

		if (singleOrder != null) {
			// 최종 재고 확인
			Book book = bookService.getBookById(singleOrder.getBookId());
			if(book.getStock() < singleOrder.getQuantity()) {
				redirectAttributes.addFlashAttribute("errorMsg", "재고가 부족하여 주문을 완료할 수 없습니다. (상품: " + book.getTitle() + ")");
				return "redirect:/cart";
			}
			
			// 단일 주문에도 고유한 transactionId 부여
            String transactionId =loginUser.getId() + "_" + System.currentTimeMillis();
            singleOrder.setTransactionId(transactionId);
            
            // 판매량(salesVolume) 누적
            book.setSalesVolume(book.getSalesVolume() + singleOrder.getQuantity());
            bookService.updateSalesVolume(book); // salesVolumn 업데이트
            
			orderService.insertOrder(singleOrder);
		}

		if (orderList != null && !orderList.isEmpty()) {
			// 장바구니 주문은 동일한 transactionId 부여
            String transactionId = loginUser.getId() + "_" + System.currentTimeMillis();
			for (Order order : orderList) {
				// 최종 재고 확인
				Book book = bookService.getBookById(order.getBookId());
				if(book.getStock() < order.getQuantity()) {
					redirectAttributes.addFlashAttribute("errorMsg", "재고가 부족하여 주문을 완료할 수 없습니다. (상품: " + book.getTitle() + ")");
					return "redirect:/cart";
				}
                order.setTransactionId(transactionId);
                
                // 판매량(salesVolumn) 누적
                book.setSalesVolume(book.getSalesVolume() + order.getQuantity());
                bookService.updateSalesVolume(book); // salesVolumn 업데이트
                
				orderService.insertOrder(order);
			}
		}

		session.removeAttribute("order");
		session.removeAttribute("orders");
		session.removeAttribute("cart");

		redirectAttributes.addFlashAttribute("successMsg", "결제 되었습니다.");
		return "redirect:/orders/member/orderlist";
	}
	
	 @PostMapping("/cancel")
     public void cancelOrder(HttpSession session) {
        session.removeAttribute("order");
        session.removeAttribute("orders");
     }
}