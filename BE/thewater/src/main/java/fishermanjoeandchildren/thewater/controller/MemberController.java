package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.dto.*;
import fishermanjoeandchildren.thewater.service.EmailService;
import fishermanjoeandchildren.thewater.service.MemberService;
import jakarta.mail.MessagingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class MemberController {

    private final MemberService memberService;
    private EmailService emailService;

    @Autowired

    public MemberController(MemberService memberService,
                            EmailService emailService) {
        this.emailService = emailService;
        this.memberService = memberService;
    }

    // 아이디 중복 확인
    @GetMapping("/check-id")
    public ApiResponse<?> checkLoginIdDuplicate(@RequestParam String login_id) {
        boolean isDuplicate = memberService.checkLoginIdDuplicate(login_id);
        if (isDuplicate) {
            return ApiResponse.builder().
                    status(ResponseStatus.VALIDATION_FAILED).
                    message(ResponseMessage.VALIDATION_FAILED).
                    data("이미 사용중인 아이디입니다.").build();
// 방법 2
//            return ResponseEntity.status(409).body(
//                    Map.of("available", false, "message", "이미 사용중인 아이디입니다.")
        }

        return ApiResponse.builder().
                status(ResponseStatus.SUCCESS).
                message(ResponseMessage.SUCCESS).
                data("사용 가능한 아이디입니다.").build();
// 방법 2
//        return ResponseEntity.ok(
//                Map.of("available", true, "message", "사용 가능한 아이디입니다.")
    }

    // 이메일 인증 코드 요청
    @PostMapping("/request-verification")
    public ApiResponse<?> requestVerification(@RequestBody EmailVerificationRequest request) {
        try {
            // 이미 가입된 이메일인지 확인
            if (memberService.checkEmailDuplicate(request.getEmail())) {
                return ApiResponse.builder()
                        .status(ResponseStatus.VALIDATION_FAILED)
                        .message(ResponseMessage.VALIDATION_FAILED)
                        .data("이미 가입된 이메일입니다.")
                        .build();
            }

            // 인증 이메일 발송
            emailService.sendVerificationEmail(request.getEmail());

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(Map.of(
                            "success", true,
                            "message", "인증번호가 이메일로 전송되었습니다.",
                            "expires_in", 300  // 5분(초 단위)
                    ))
                    .build();
        } catch (MessagingException e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.SERVER_ERROR)
                    .message(ResponseMessage.SERVER_ERROR)
                    .data("이메일 전송 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
        }
    }

    // 인증 코드 확인
    @PostMapping("/verify-code")
    public ApiResponse<?> verifyCode(@RequestBody VerifyCodeRequest request) {
        boolean isValid = emailService.verifyCode(request.getEmail(), request.getCode());

        if (isValid) {
            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(Map.of(
                            "success", true,
                            "message", "이메일 인증이 완료되었습니다."
                    ))
                    .build();
        } else {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data(Map.of(
                            "success", false,
                            "message", "인증번호가 올바르지 않거나 만료되었습니다."
                    ))
                    .build();
        }
    }

    // 닉네임 중복 확인
    @GetMapping("/check-nickname")
    public ApiResponse<?> checkNicknameDuplicate(@RequestParam String nickname) {
        boolean isDuplicate = memberService.checkNicknameDuplicate(nickname);
        if (isDuplicate) {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data("이미 사용중인 닉네임입니다.").build();
        }
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("사용 가능한 닉네임입니다.").build();
    }

    // 회원가입
    @PostMapping("/signup")
    public ApiResponse<?> signup(@RequestBody SignupRequest request) {
        try {
            SignupResponse response = memberService.signup(request);
            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(response).build();
        } catch (RuntimeException e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data(new SignupResponse(false, e.getMessage(), null)).build();
        }
    }
}