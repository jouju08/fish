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
@RequestMapping("/api/collection")
@RequiredArgsConstructor
public class FishCardController {
    private final FishCardService fishCardService;
    private final JwtUtil jwtUtil;
    @GetMapping("/myfish/all")
    public ApiResponse<List<FishCardDto>>getMyFishAll(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        List<FishCardDto> allFishCards=fishCardService.getAllFishCards(memberId);
        return ApiResponse.<List<FishCardDto>>builder()
                .data(allFishCards).build();
    }


    @PostMapping("/myfish/add")
    public ApiResponse<FishCardDto> addFishCard(@RequestBody FishCardDto fishCardDto, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        FishCardDto savedFishCardDto =fishCardService.addFishCard(fishCardDto,memberId);
        return ApiResponse.<FishCardDto>builder()
                .data(savedFishCardDto)
                .message(ResponseMessage.SUCCESS)
                .status(ResponseStatus.SUCCESS)
                .build();
    }

    @DeleteMapping("/myfish/delete/{fishcard_id}")
    public ApiResponse<?> deleteFishCard(@PathVariable("fishcard_id") Long fishCardId, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        String status = fishCardService.deleteFishCard(fishCardId, memberId);

        switch (status){
            case ResponseStatus.SUCCESS:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SUCCESS)
                        .data("물고기 카드 삭제 완료")
                        .build();
            case ResponseStatus.NOT_FOUND:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.NOT_FOUND)
                        .data("삭제할 물고기 카드를 찾을 수 없습니다.")
                        .build();
            default:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SERVER_ERROR)
                        .data("물고기 카드 삭제 중 오류가 발생했습니다.")
                        .build();
        }
    }

}
