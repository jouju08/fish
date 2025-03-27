package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.FishCardService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/")
@RequiredArgsConstructor
public class FishCardController {
    private final FishCardService fishCardService;
    private final JwtUtil jwtUtil;
    @GetMapping("myfish/all")
    public ApiResponse<List<FishCardDto>>getMyFishAll(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        List<FishCardDto> allFishCards=fishCardService.getAllFishCards(memberId);
        return ApiResponse.<List<FishCardDto>>builder()
                .data(allFishCards).build();
    }

    @PostMapping("collection/add")
    public ApiResponse<FishCard> addFishCard(@RequestBody FishCardDto fishCardDto, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        FishCard fishCard=fishCardService.addFishCard(fishCardDto, memberId);
        return ApiResponse.<FishCard>builder()
                .data(fishCard)
                .message(ResponseMessage.SUCCESS)
                .status(ResponseStatus.SUCCESS)
                .build();
    }
}
