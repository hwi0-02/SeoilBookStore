package controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import model.Member;
import service.MemberService;
import service.OrderService;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;

    @Autowired
    private OrderService orderService;

    @GetMapping("/loginform")
    public String loginForm() {
        return "user/login"; // /WEB-INF/views/user/login.jsp
    }

    @GetMapping("/login")
    public String loginPage() {
        return "user/login"; // /WEB-INF/views/user/login.jsp
    }

    @GetMapping("/registerform")
    public String registerForm() {
        return "user/register"; // /WEB-INF/views/user/register.jsp
    }

    @GetMapping("/info")
    public String memberInfo(HttpSession session, Model model) {
        Member loginUser = (Member) session.getAttribute("loginUser");

        if (loginUser == null) {
            // 로그인되지 않은 경우 로그인 페이지로 리다이렉트
            return "redirect:/member/loginform";
        }
        model.addAttribute("member", loginUser);
        model.addAttribute("orders", orderService.getOrdersByMemberId(loginUser.getId()));
        return "user/info"; // /WEB-INF/views/user/info.jsp
    }

    @PostMapping("/login")
    public String login(@RequestParam("userId") String userId, // [수정] id → userId로 변경
                        @RequestParam("password") String password,
                        HttpSession session, RedirectAttributes redirectAttributes) {

        Member member = memberService.login(userId, password); // [수정] int id → String userId
        if (member != null) {
            session.setAttribute("loginUser", member);
            return "redirect:/books";
        } else {
            redirectAttributes.addFlashAttribute("errorMsg", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "redirect:/member/loginform";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/books";
    }

    @GetMapping("/list")
    @ResponseBody
    public List<Member> list() {
        return memberService.getAllMembers();
    }

    @PostMapping("/join")
    public String join(@RequestParam("userId") String userId,  // 회원가입에서는 문자열 아이디 사용(userId)
                       @RequestParam("password") String password,
                       @RequestParam("name") String name,
                       @RequestParam("phone") String phone,
                       @RequestParam("address") String address,
                       RedirectAttributes redirectAttributes) {
        // 아이디 중복 확인
        if (memberService.selectByUserId(userId) != null) {
            redirectAttributes.addFlashAttribute("idError", "이미 존재하는 아이디입니다.");
            return "redirect:/member/registerform";
        }

        /*
         * // 이메일 중복 확인 if (memberService.selectByEmail(email) != null) {
         * redirectAttributes.addFlashAttribute("emailError", "이미 사용 중인 이메일입니다.");
         * return "redirect:/member/registerform"; }
         */

        // 전화번호 중복 확인
        if (memberService.selectByPhone(phone) != null) {
            redirectAttributes.addFlashAttribute("phoneError", "이미 사용 중인 전화번호입니다.");
            return "redirect:/member/registerform";
        }

        Member member = new Member();
        member.setUserId(userId);
        member.setPassword(password);
        member.setName(name);
        /* member.setEmail(email); */
        member.setPhone(phone);
        member.setAddress(address);

        boolean result = memberService.join(member);

        if (result) {
            return "redirect:/member/loginform";
        } else {
            redirectAttributes.addFlashAttribute("generalError", "회원가입에 실패했습니다. 다시 시도해주세요.");
            return "redirect:/member/registerform";
        }
    }

    @PostMapping("/update")
    @ResponseBody
    public boolean modify(@RequestBody Member m) {
        return memberService.modify(m);
    }

    @PostMapping("/delete")
    @ResponseBody
    public boolean remove(@RequestParam("userId") String userId) {  // [수정] id → userId로 변경
        return memberService.remove(userId); // [수정] int id → String userId
    }
    
    // 수정 폼 보여주기
    @GetMapping("/editinfo")
    public String editInfo(HttpSession session, Model model) {
        Member loginUser = (Member) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/loginform";
        }
        model.addAttribute("member", loginUser);
        return "user/editinfo"; // JSP 페이지 경로
    }
    
    // 폼 제출 처리
    @PostMapping("/editinfo")
    public String update(Member member, HttpSession session, RedirectAttributes redirectAttributes) {
        Member loginUser = (Member) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/loginform";
        }
        member.setUserId(loginUser.getUserId());

        // 기존 비밀번호를 다시 세팅 (폼에서 password를 안 받으므로 null임)
        member.setPassword(loginUser.getPassword());

        boolean success = memberService.modify(member);

        if (success) {
            session.setAttribute("loginUser", memberService.selectByUserId(member.getUserId()));
            redirectAttributes.addFlashAttribute("msg", "회원 정보가 성공적으로 수정되었습니다.");
            return "redirect:/member/info";
        } else {
            redirectAttributes.addFlashAttribute("errorMsg", "회원 정보 수정에 실패했습니다. 다시 시도해주세요.");
            return "redirect:/member/editinfo";
        }
    }
}