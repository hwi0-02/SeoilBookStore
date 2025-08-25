package model;

import java.util.List;

import org.springframework.stereotype.Component;

import lombok.Data;
import lombok.ToString;

@Component
@Data
@ToString
public class Book {
    private int id;
    private String title;
    private String author;
    private int price;
    private String description;	
    private String image;
    private int stock; 
    private int salesVolume;
    private Member member;
    private List<Review> reviewList;
    
    private int reviewCount;       // v
    private double avgScore;       // R
    private double weightedScore;  // WR = 가중평점
}
