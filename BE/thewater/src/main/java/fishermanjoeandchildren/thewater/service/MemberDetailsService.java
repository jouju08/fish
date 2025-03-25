package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class MemberDetailsService implements UserDetailsService {

    @Autowired
    private MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String loginId) throws UsernameNotFoundException {
        Member member = memberRepository.findByLoginId(loginId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with login id: " + loginId));

        return new User(member.getLoginId(), member.getPassword(), new ArrayList<>());
    }
}