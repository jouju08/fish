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
    private String fishName;
    private Double realSize;
    private Integer sky;
    private Double temperature;
    private Double waterTemperature;
    private Integer tide;
    private Boolean hasVisible;
    private String comment;
    private String cardImg;

    public FishCard toEntity() {
        return FishCard.builder()
                .realSize(this.realSize)
                .temperature(this.temperature)
                .waterTemperature(this.waterTemperature)
                .tide(this.tide)
                .comment(this.comment)
                .cardImg(this.cardImg)
                .build();
    }
}