package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
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

        // 비밀번호 암호화3
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        Aquarium aquarium = new Aquarium();
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

    @Transactional
    public ApiResponse<?> deleteMember(Long memberId) {
        // 회원 정보 조회
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 정보를 찾을 수 없습니다."));

        // 이미 탈퇴한 회원인지 확인
        if (member.getHas_deleted()) {
            return ApiResponse.builder()
                    .status(ResponseStatus.CONFLICT)
                    .message(ResponseMessage.CONFLICT)
                    .data("이미 탈퇴한 회원입니다.")
                    .build();
        }

        // 탈퇴 처리 (논리적 삭제)
        member.setHas_deleted(true);
        memberRepository.save(member);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("회원 탈퇴가 완료되었습니다.")
                .build();
    }

    public MemberDto getUserInfo(Long userId) {
        // 사용자 기본 정보 조회
        Member member = memberRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        return MemberDto.fromEntity(member);
    }
    // 멤버 닉네임 찾기
    public List<MemberDto> searchMembersByNickname(String nickname) {
        List<Member> members = memberRepository.findByNicknameContaining(nickname);
        return members.stream()
                .map(MemberDto::fromEntity)
                .collect(Collectors.toList());
    }

    public List<String> getAllActiveNicknames() {
        return memberRepository.findAllActiveNicknames();
    }

    // 멤버 소개글 바꾸는 API
    @Transactional
    public ApiResponse<?> updateMemberComment(Long userId, String comment) {
        try {
            // 사용자 조회
            Member member = memberRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

            // 코멘트 업데이트
            member.setComment(comment);
            memberRepository.save(member);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data("코멘트가 성공적으로 업데이트되었습니다.")
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.BAD_REQUEST)
                    .message(ResponseMessage.BAD_REQUEST)
                    .data("코멘트 업데이트 실패: " + e.getMessage())
                    .build();
        }
    }
}