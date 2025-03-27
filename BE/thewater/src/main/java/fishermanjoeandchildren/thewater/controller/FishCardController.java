package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.service.FishCardService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/")
@RequiredArgsConstructor
public class FishCardController {
    private final FishCardService fishCardService;

    @GetMapping("fish/all")
    public ApiResponse<List<FishCardDto>>getFishAll() {
        List<FishCardDto> allFishCards=fishCardService.getAllFishCards();
        return ApiResponse.<List<FishCardDto>>builder()
                .data(allFishCards).build();
    }

    @PostMapping("collection/add")
    public ApiResponse<FishCard> addFishCard(@RequestBody FishCardDto fishCardDto, Authentication auth) {
        FishCard fishCard=fishCardService.addFishCard(fishCardDto, auth);
        return ApiResponse.<FishCard>builder()
                .data(fishCard)
                .message(ResponseMessage.SUCCESS)
                .status(ResponseStatus.SUCCESS)
                .build();
    }
}
