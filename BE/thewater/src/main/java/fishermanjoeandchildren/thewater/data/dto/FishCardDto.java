package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.*;
import fishermanjoeandchildren.thewater.db.repository.FishingPointRepository;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FishCardDto {
    private Long id;
    private String fishName;
    private Long fishingPointId;
    private Double realSize;
    private Integer sky;
    private Double temperature;
    private Double waterTemperature;
    private Integer tide;
    private String comment;
    private String cardImg;



    public FishCard toEntity(Member member, FishingPoint fishingPoint, Fish fish , Aquarium aquarium) {

        return FishCard.builder()
                .member(member)
                .aquarium(aquarium)
                .fishPoint(fishingPoint)
                .fish(fish)
                .realSize(this.realSize)
                .sky(this.sky)
                .temperature(this.temperature)
                .waterTemperature(this.waterTemperature)
                .tide(this.tide)
                .comment(this.comment)
                .hasDeleted(false)
                .cardImg(this.cardImg)
                .build();
    }

    public static FishCardDto fromEntity(FishCard fishCard){
        String fishName = fishCard.getFish().getFishName();
        Long fishingPointId = fishCard.getFishPoint().getId();
        return FishCardDto.builder()
                .id(fishCard.getId())
                .fishName(fishName)
                .fishingPointId(fishingPointId)
                .realSize(fishCard.getRealSize())
                .sky(fishCard.getSky())
                .temperature(fishCard.getTemperature())
                .waterTemperature(fishCard.getWaterTemperature())
                .tide(fishCard.getTide())
                .comment(fishCard.getComment())
                .cardImg(fishCard.getCardImg())
                .build();
    }
}