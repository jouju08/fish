package fishermanjoeandchildren.thewater.data.dto;

import  fishermanjoeandchildren.thewater.db.entity.FishCard;
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
    private long id;
    private String fishName;
    private Double realSize;
    private Date collectDate;
    private Integer sky;
    private Double temperature;
    private Double waterTemperature;
    private Integer tide;
    private Boolean hasVisible;
    private String comment;
    private String cardImg;

    public static FishCardDto fromEntity(FishCard fishCard) {
        return FishCardDto.builder()
                .id(fishCard.getId())
                .fishName(fishCard.getFish().getFishName())
                .realSize(fishCard.getRealSize())
                .temperature(fishCard.getTemperature())
                .waterTemperature(fishCard.getWaterTemperature())
                .tide(fishCard.getTide())
                .comment(fishCard.getComment())
                .cardImg(fishCard.getCardImg())
                .build();
    }
}