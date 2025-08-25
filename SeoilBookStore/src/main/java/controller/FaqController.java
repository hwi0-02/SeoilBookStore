package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller("/")
public class FaqController {

    @GetMapping("faq")
    public String faqPage() {
        // /WEB-INF/views/faq.jsp 로 이동
        return "user/faq";
    }
}