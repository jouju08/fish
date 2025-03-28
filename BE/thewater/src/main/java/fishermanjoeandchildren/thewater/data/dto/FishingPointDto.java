package fishermanjoeandchildren.thewater.data.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FishingPointDto {
    private Long id;
    private String pointName;
    private String latitude;
    private String longitude;
    private String address;
    private Boolean official;
}