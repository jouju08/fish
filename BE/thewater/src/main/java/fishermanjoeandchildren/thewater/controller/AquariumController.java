package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.AquariumDto;
import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.AquariumService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


@RestController
@RequiredArgsConstructor
@RequestMapping("/api/aquarium")
public class AquariumController {

    private final AquariumService aquariumService;
    private final JwtUtil jwtUtil;

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/info/{aquarium_id}")
    public ApiResponse<?> getAquariumInfo(@PathVariable("aquarium_id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        AquariumDto aquariumDto = aquariumService.getAquarium(aquariumId, memberId);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(aquariumDto)
                .build();
    }


    @PostMapping("/visit/{aquarium_id}")
    public ApiResponse<?> updateAquariumVisitors(@PathVariable("aquarium_id") Long aquariumId){
        String status = aquariumService.updateVisitorCount(aquariumId);

        switch(status){
            case ResponseStatus.SUCCESS:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SUCCESS)
                        .data("어항 방문자 수가 업데이트되었습니다.")
                        .build();
            case ResponseStatus.NOT_FOUND:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.NOT_FOUND)
                        .data("해당 어항을 찾을 수 없습니다.")
                        .build();
            default:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SERVER_ERROR)
                        .data("어항 방문자 수 업데이트 중 오류가 발생했습니다.")
                        .build();
        }
    }

    @SecurityRequirement(name="BearerAuth")
    @PostMapping(value="/like/{aquarium_id}")
    public ApiResponse<?> likeAquarium(@PathVariable("aquarium_id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        String status = aquariumService.likeAquarium(aquariumId,memberId);

        switch(status){
            case ResponseStatus.SUCCESS:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SUCCESS)
                        .data("어항에 좋아요를 눌렀습니다.")
                        .build();
            case ResponseStatus.NOT_FOUND:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.NOT_FOUND)
                        .data("해당 어항을 찾을 수 없습니다.")
                        .build();
            case ResponseStatus.CONFLICT:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.CONFLICT)
                        .data("이미 좋아요를 누른 어항입니다.")
                        .build();
            default:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SERVER_ERROR)
                        .data("어항 좋아요 처리중 오류가 발생했습니다.")
                        .build();
        }

    }

    @SecurityRequirement(name="BearerAuth")
    @DeleteMapping("/like/{aquarium_id}")
    public ApiResponse<?> unlikeAquarium(@PathVariable("aquarium_id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        String status = aquariumService.unlikeAquarium(aquariumId, memberId);

        switch(status){
            case ResponseStatus.SUCCESS:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SUCCESS)
                        .data("좋아요가 취소되었습니다.")
                        .build();
            case ResponseStatus.NOT_FOUND:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.NOT_FOUND)
                        .data("좋아요 기록이 없습니다.")
                        .build();
            default:
                return ApiResponse.builder()
                        .status(status)
                        .message(ResponseMessage.SERVER_ERROR)
                        .data("좋아요 취소 중 오류가 발생했습니다.")
                        .build();
        }
    }











}
