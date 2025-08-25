	package model;
	
	import java.util.Date;

import org.springframework.stereotype.Component;

import lombok.Data;
import lombok.ToString;
	
	@Component
	@Data
	@ToString
	public class Order {
	    private int id;
	    private int memberId;
	    private int bookId;
	    private int quantity;
	    private int totalPrice;
	    private Date orderDate;
	    private String transactionId;
	    private Book book;
	    private Member member;
	}