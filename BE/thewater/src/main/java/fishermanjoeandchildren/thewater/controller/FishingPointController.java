package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.FishingPointDto;
import fishermanjoeandchildren.thewater.service.FishingPointService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/fishing-points")
@RequiredArgsConstructor
public class FishingPointController {

    private final FishingPointService fishingPointService;

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/all")
    public ApiResponse<List<FishingPointDto>> getAllFishingPoints() {
        List<FishingPointDto> fishingPoints = fishingPointService.getAllOfficialFishingPoints();

        return ApiResponse.<List<FishingPointDto>>builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(fishingPoints)
                .build();
    }
}