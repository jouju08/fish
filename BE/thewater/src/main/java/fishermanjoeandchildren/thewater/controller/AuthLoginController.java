package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.dto.LoginRequest;
import fishermanjoeandchildren.thewater.data.dto.LoginResponse;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginRequest.getLoginId(), loginRequest.getPassword())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            final String jwt = jwtUtil.generateToken(userDetails);
//            return ResponseEntity.ok(new LoginResponse(true, "로그인 성공", jwt));
            return ResponseEntity.ok(new LoginResponse(true, "로그인 성공", jwt));
        } catch (Exception e) {
            return ResponseEntity.status(401).body(new LoginResponse(false, "아이디 또는 비밀번호가 올바르지 않습니다.", null));
        }
    }
}