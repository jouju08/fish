package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.SignupRequest;
import fishermanjoeandchildren.thewater.data.dto.SignupResponse;
import fishermanjoeandchildren.thewater.service.MemberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class MemberController {

    private final MemberService memberService;

    @Autowired
    public MemberController(MemberService memberService) {
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

    // 이메일 중복 확인
    @GetMapping("/check-email")
    public ApiResponse<?> checkEmailDuplicate(@RequestParam String email) {
        boolean isDuplicate = memberService.checkEmailDuplicate(email);
        if (isDuplicate) {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data("이미 사용중인 이메일입니다.").build();
        }
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseStatus.SUCCESS)
                .data("사용 가능한 이메일입니다.").build();
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