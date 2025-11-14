
package service;

import java.util.List;
import java.util.function.Supplier;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import mapper.MemberMapper;
import model.Member;
import model.StatPoint;

@Service
public class MemberService {

    @Autowired
    private MemberMapper memberMapper;

    public Member login(String userId, String password) {
        return authenticate(() -> memberMapper.selectByUserId(userId), password);
    }

    public Member loginById(int id, String password) {
        return authenticate(() -> memberMapper.selectById(id), password);
    }

    public Member selectByUserId(String userId) {
        return memberMapper.selectByUserId(userId);
    }
    
    public Member selectById(int id) {
        return memberMapper.selectById(id);
    }

    public Member selectByPhone(String phone) {
        return memberMapper.selectByHp(phone);
    }

    public List<Member> getAllMembers() {
        return memberMapper.selectAll();
    }

    public List<Member> searchMembers(String keyword) {
        return hasText(keyword) ? memberMapper.searchByKeyword(keyword.trim()) : getAllMembers();
    }
    
    public List<Member> searchMembersByFilters(String name, String userId, String startDate, String endDate) {
        return memberMapper.searchByFilters(
            trimOrNull(name),
            trimOrNull(userId),
            startDate,
            endDate
        );
    }
    
    public List<StatPoint> getSignupStats(String startDate, String endDate, String period) {
        if (period == null || period.isBlank()) period = "day";
        return memberMapper.selectSignupStats(startDate, endDate, period);
    }
    
    public boolean join(Member m) {
        return memberMapper.insert(m) > 0;
    }

    public boolean modify(Member m) {
        return memberMapper.update(m) > 0;
    }

    public boolean modifyById(Member m) {
        return memberMapper.updateById(m) > 0;
    }

    public boolean remove(String userId) {
        return memberMapper.delete(userId) > 0;
    }

    public boolean removeById(int id) {
        return memberMapper.deleteById(id) > 0;
    }

    private Member authenticate(Supplier<Member> finder, String password) {
        Member member = finder.get();
        return (member != null && member.getPassword().equals(password)) ? member : null;
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private String trimOrNull(String value) {
        return hasText(value) ? value.trim() : null;
    }
}
