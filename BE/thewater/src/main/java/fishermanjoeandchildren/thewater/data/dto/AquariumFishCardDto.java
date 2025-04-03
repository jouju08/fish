package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.FishCard;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class AquariumFishCardDto {
    private String fishName;
    private Double fishSize;
    private String fishingPointName;

    //TODO 잡은 날짜
    public static AquariumFishCardDto fromEntity(FishCard fishCard) {
        return AquariumFishCardDto.builder()
                .fishName(fishCard.getFish().getFishName())
                .fishSize(fishCard.getFishSize())
                .build();
    }
}
