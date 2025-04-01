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
    private Double realSize;
    private String fishingPointName;
    private Boolean hasVisible;

    //TODO 잡은 날짜
    public static AquariumFishCardDto fromEntity(FishCard fishCard) {
        return AquariumFishCardDto.builder()
                .fishName(fishCard.getFish().getFishName())
                .realSize(fishCard.getRealSize())
                .fishingPointName(fishCard.getFishPoint().getPointName())
                .hasVisible(fishCard.getHasVisible())
                .build();
    }
}
