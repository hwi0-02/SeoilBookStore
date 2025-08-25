package model;

import java.sql.Date;

import org.springframework.stereotype.Component;

import lombok.Data;
import lombok.ToString;

@Component
@Data
@ToString
public class CartItem {
    private int id;
    private int memberId;
    private int bookId;
    private int quantity;
    private Date addedAt;
    private Book book;
}
