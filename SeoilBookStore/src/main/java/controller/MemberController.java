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

    @GetMapping({"/loginform", "/login"})
    public String loginForm() {
        return "user/login";
    }

    @GetMapping("/registerform")
    public String registerForm() {
        return "user/register";
    }

    @GetMapping("/info")
    public String memberInfo(HttpSession session, Model model) {
        Member loginUser = getLoginUser(session);
        if (loginUser == null) {
            return redirectToLogin();
        }
        model.addAttribute("member", loginUser);
        model.addAttribute("orders", orderService.getOrdersByMemberId(loginUser.getId()));
        return "user/info";
    }

    @PostMapping("/login")
    public String login(@RequestParam("userId") String userId,
                        @RequestParam("password") String password,
                        HttpSession session, RedirectAttributes redirectAttributes) {

        Member member = memberService.login(userId, password);
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
    public String join(@RequestParam("userId") String userId,
                       @RequestParam("password") String password,
                       @RequestParam("name") String name,
                       @RequestParam("phone") String phone,
                       @RequestParam("address") String address,
                       RedirectAttributes redirectAttributes) {
        if (memberService.selectByUserId(userId) != null) {
            redirectAttributes.addFlashAttribute("idError", "이미 존재하는 아이디입니다.");
            return "redirect:/member/registerform";
        }
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
    public boolean remove(@RequestParam("userId") String userId) {
        return memberService.remove(userId);
    }
    
    @GetMapping("/editinfo")
    public String editInfo(HttpSession session, Model model) {
        Member loginUser = getLoginUser(session);
        if (loginUser == null) {
            return redirectToLogin();
        }
        model.addAttribute("member", loginUser);
        return "user/editinfo";
    }
    
    @PostMapping("/editinfo")
    public String update(Member member, HttpSession session, RedirectAttributes redirectAttributes) {
        Member loginUser = getLoginUser(session);
        if (loginUser == null) {
            return redirectToLogin();
        }
        member.setUserId(loginUser.getUserId());

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

    private Member getLoginUser(HttpSession session) {
        return (Member) session.getAttribute("loginUser");
    }

    private String redirectToLogin() {
        return "redirect:/member/loginform";
    }
}