package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.LoginRequest;
import fishermanjoeandchildren.thewater.data.dto.LoginResponse;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class AuthLoginController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ApiResponse<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginRequest.getLoginId(), loginRequest.getPassword())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            final String jwt = jwtUtil.generateToken(userDetails);

            LoginResponse loginResponse = new LoginResponse(true, "로그인 성공", jwt);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(loginResponse)
                    .build();
        } catch (Exception e) {
            LoginResponse errorResponse = new LoginResponse(false, "아이디 또는 비밀번호가 올바르지 않습니다.", null);

            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)  // 인증 실패에 적합한 상태 코드
                    .message(ResponseMessage.AUTHROIZATION_FAILED)  // 인증 실패에 적합한 메시지
                    .data(errorResponse)
                    .build();
        }
    }
}