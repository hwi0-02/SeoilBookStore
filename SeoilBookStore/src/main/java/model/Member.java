package model;

import java.sql.Date;

import org.springframework.stereotype.Component;

import lombok.Data;
import lombok.ToString;

@Component
@Data
@ToString
public class Member {
	private int id;
    private String userId;
    private String password;
    private String name;
    private String phone;
    private String address;
    private Date createdAt;
    private String role;
}
