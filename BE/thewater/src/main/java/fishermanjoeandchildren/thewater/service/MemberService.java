package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.dto.*;
import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.Fish;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final AquariumRepository aquariumRepository;
    private final EmailService emailService;

    @Autowired
    public MemberService(MemberRepository memberRepository,
                         PasswordEncoder passwordEncoder,
                         AquariumRepository aquariumRepository,
                         EmailService emailService) {
        this.memberRepository = memberRepository;
        this.passwordEncoder = passwordEncoder;
        this.aquariumRepository = aquariumRepository;
        this.emailService = emailService;
    }

    public boolean checkLoginIdDuplicate(String login_id) {
        return memberRepository.existsByLoginId(login_id);
    }

    public boolean checkEmailDuplicate(String email) {
        return memberRepository.existsByEmail(email);
    }

    public boolean checkNicknameDuplicate(String nickname) {
        return memberRepository.existsByNickname(nickname);
    }

    @Transactional
    public SignupResponse signup(SignupRequest request) {
        // 중복 검사
        if (checkLoginIdDuplicate(request.getLoginId())) {
            throw new RuntimeException("이미 존재하는 아이디입니다.");
        }
        if (checkEmailDuplicate(request.getEmail())) {
            throw new RuntimeException("이미 존재하는 이메일입니다.");
        }
        if (checkNicknameDuplicate(request.getNickname())) {
            throw new RuntimeException("이미 존재하는 닉네임입니다.");
        }
        // 이메일 인증 여부 확인
        if (!emailService.isEmailVerified(request.getEmail())) {
            throw new RuntimeException("이메일 인증이 필요합니다.");
        }

        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // 어항 생성 (기본 어항)
        Aquarium aquarium = Aquarium.builder()
                .visitorCnt(0)
                .likeCnt(0)
                .fishCnt(0)
                .totalPrice(0)
                .build();

        aquariumRepository.save(aquarium);

        // Member 객체 생성
        Member member = Member.builder()
                .loginId(request.getLoginId())
                .password(encodedPassword)
                .email(request.getEmail())
                .nickname(request.getNickname())
                .birthday(request.getBirthday())
                .loginType(request.getLoginType())
                .has_deleted(false)
                .aquarium(aquarium)
                .build();

        memberRepository.save(member);

        return new SignupResponse(true, "회원가입이 완료되었습니다.", member.getId());
    }

    public Map<String, Object> getFullUserInfo(Long userId) {
        // 사용자 기본 정보 조회
        Member member = memberRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 어항 정보 조회
        Aquarium aquarium = member.getAquarium();

        // 물고기 카드 정보 조회
        List<FishCard> fishCards = member.getCard();

        // 응답 객체 구성
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("user", MemberDto.fromEntity(member));
        userInfo.put("aquarium", aquarium != null ? AquariumDto.fromEntity(aquarium, userId) : null);
        userInfo.put("fish_cards", fishCards != null ?
                fishCards.stream().map(FishCardDto::fromEntity).collect(Collectors.toList()) :
                Collections.emptyList());

        return userInfo;
    }
}