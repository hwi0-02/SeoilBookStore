package controller;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttribute;

import mapper.ReviewMapper;
import model.Book;
import model.Member;
import model.Review;
import service.AdminService;
import service.BookService;
import service.MemberService;

@Controller
@RequestMapping
public class BookController {

	@Autowired
	private BookService bookService;
	
	@Autowired
	private MemberService memberService;
	
	@Autowired
	private AdminService adminService;
	
	@Autowired
	private ReviewMapper reviewMapper;
	
	@GetMapping({"/", "/books"})
	public String home(@RequestParam(value = "keyword", required = false) String keyword, Model model) {
		List<Book> bookList;
		if (keyword != null && !keyword.trim().isEmpty()) {
			bookList = bookService.searchBooks(keyword);
			model.addAttribute("searchKeyword", keyword);
		} else {
			bookList = bookService.getAllBooks();
		}
		model.addAttribute("bookList", bookList);

		return "user/list";
	}

	@GetMapping("/books/{id}")
	public String viewBook(@PathVariable("id") int id, Model model, HttpSession session) {
		Member loginUser = (Member)session.getAttribute("loginUser");
		model.addAttribute("loginUser", loginUser);
		
		Book book = bookService.getBookById(id);
		List<Review> reviewList = bookService.getReviewsByBook(id);  
		for (Review review : reviewList) {
		    Member member = memberService.selectById(review.getMemberId());
		    review.setMember(member);
		}
		int reviewCount = bookService.getCountByBookId(id);
		int reviewSum = bookService.getSumByBookId(id);
		float reviewAverage = 0.0f;
		
		if (reviewCount > 0) {
		    reviewAverage = (float) reviewSum / (float) reviewCount;
		}
		
		int fullStars = (int) reviewAverage;
		boolean halfStar = (reviewAverage - fullStars) >= 0.5;

		model.addAttribute("fullStars", fullStars);
		model.addAttribute("halfStar", halfStar);
		model.addAttribute("emptyStars", 5 - fullStars - (halfStar ? 1 : 0));
		
		model.addAttribute("book", book);
		model.addAttribute("reviewList", reviewList);        
		model.addAttribute("reviewCount", reviewCount);
		model.addAttribute("reviewAverage", reviewAverage);
		return "user/bookDetail";
	}
	
	@GetMapping("/bestsellers")
	public String bestsellers(Model model) {
	    List<Book> bestsellers = bookService.getBestsellers(5);

	    if (!bestsellers.isEmpty()) {
	        Book top1 = bestsellers.get(0); // 1위 책
	        int reviewCount = reviewMapper.countByBookId(top1.getId());
	        int sumScore = reviewMapper.sumScoreByBookId(top1.getId());
	        double avgScore = reviewCount > 0 ? (double) sumScore / reviewCount : 0.0;

	        // VO에 넣지 않고 Model에 따로 추가
	        model.addAttribute("top1", top1); 
	        model.addAttribute("top1ReviewCount", reviewCount);
	        model.addAttribute("top1AvgScore", avgScore);
	    }

	    model.addAttribute("bestsellers", bestsellers);
	    return "user/bestsellers";
	}


	@PostMapping("review/add")
	public String addReview(@RequestParam("rating") int rating,
	                        @RequestParam("content") String content,
	                        @RequestParam(value = "bookId", required = false) Integer bookId,
	                        @RequestParam(value = "id", required = false) Integer legacyId, // 구 폼 호환
	                        javax.servlet.http.HttpSession session,
	                        org.springframework.web.servlet.mvc.support.RedirectAttributes ra) {

	    Integer finalBookId = (bookId != null) ? bookId : legacyId;
	    if (finalBookId == null) {
	        ra.addFlashAttribute("successMsg", "요청에 bookId가 없습니다.");
	        return "redirect:/books";
	    }

	    // [CHANGED] 세션에서 직접 꺼내서 null 방어
	    Member loginUser = (Member) session.getAttribute("loginUser");
	    if (loginUser == null) {
	        ra.addFlashAttribute("successMsg", "로그인이 필요합니다.");
	        return "redirect:/books/" + finalBookId;
	    }

	    if (rating < 1 || rating > 5) {
	        ra.addFlashAttribute("successMsg", "별점을 선택해 주세요.");
	        return "redirect:/books/" + finalBookId;
	    }

	    Review review = new Review();
	    review.setBookId(finalBookId);
	    review.setScore(rating);
	    review.setContent(content);
	    review.setMemberId(loginUser.getId());

	    bookService.save(review);
	    return "redirect:/books/" + finalBookId;
	}
	
	@GetMapping("/recommended")
	public String recommended(org.springframework.ui.Model model,
	                          javax.servlet.http.HttpSession session) {
	    Member loginUser = (Member) session.getAttribute("loginUser");
	    model.addAttribute("loginUser", loginUser);

	    List<Book> top5 = bookService.getRecommendedTopN(5);
	    model.addAttribute("top1", top5.isEmpty() ? null : top5.get(0));
	    model.addAttribute("others", top5.size() > 1 ? top5.subList(1, top5.size()) : Collections.emptyList());
	    return "user/recommended"; // 추천 전용 JSP
	}

	
	@PostMapping("review/delete")
	public String deleteReview(@RequestParam int id, @RequestParam int bookId) {
		bookService.deleteById(id);
		return "redirect:/books/"+bookId;
	}


	@PostMapping("review/update")
	public String update(@ModelAttribute Review review,
	                     javax.servlet.http.HttpSession session,
	                     org.springframework.web.servlet.mvc.support.RedirectAttributes ra) {

	    Member loginUser = (Member) session.getAttribute("loginUser");
	    if (loginUser == null) {
	        ra.addFlashAttribute("successMsg", "로그인이 필요합니다.");
	        return (review.getBookId() != 0) ? "redirect:/books/" + review.getBookId() : "redirect:/books";
	    }

	    Review origin = bookService.getReviewById(review.getId());
	    if (origin == null) {
	        ra.addFlashAttribute("successMsg", "리뷰를 찾을 수 없습니다.");
	        return (review.getBookId() != 0) ? "redirect:/books/" + review.getBookId() : "redirect:/books";
	    }
	    if (origin.getMemberId() != loginUser.getId()) {
	        ra.addFlashAttribute("successMsg", "수정 권한이 없습니다.");
	        return "redirect:/books/" + origin.getBookId();
	    }

	    // 내용만 반영(별점도 바꿀 거면 조건부로)
	    origin.setContent(review.getContent());
	    if (review.getScore() != 0) origin.setScore(review.getScore());

	    int rows = bookService.update(origin); // 서비스에서 updateByOwner 사용 권장
	    if (rows == 0) ra.addFlashAttribute("successMsg", "수정에 실패했습니다.");

	    return "redirect:/books/" + origin.getBookId();
	}
	
	@PostMapping("/review/update.json")
	@ResponseBody
	public Map<String,Object> updateJson(
	        @RequestParam int id,
	        @RequestParam String content,
	        @RequestParam int score,
	        HttpSession session) {

	    Map<String,Object> res = new HashMap<>();
	    try {
	        Member loginUser = (Member) session.getAttribute("loginUser");
	        if (loginUser == null) throw new RuntimeException("로그인이 필요합니다.");

	        Review origin = bookService.getReviewById(id);
	        if (origin == null) throw new RuntimeException("리뷰를 찾을 수 없습니다.");
	        if (origin.getMemberId() != loginUser.getId()) throw new RuntimeException("수정 권한이 없습니다.");

	        origin.setContent(content);
	        origin.setScore(score);

	        int updated = bookService.update(origin);
	        if (updated == 0) throw new RuntimeException("수정 실패");

	        res.put("ok", true);
	    } catch(Exception e) {
	        res.put("ok", false);
	        res.put("message", e.getMessage());
	    }
	    return res;
	}
	
}