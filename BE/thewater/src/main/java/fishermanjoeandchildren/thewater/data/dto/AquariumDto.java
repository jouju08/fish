package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.AquariumLike;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.db.entity.Member;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class AquariumDto {

    @NotNull
    private Long id;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int visitorCnt;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int likeCnt;


    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int fishCnt;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int totalPrice;

    @NotNull
    private Long member_id;

    private List<Long> fishCardIds;

    private List<Long> aquariumLikeMemberIds;

    public Aquarium toEntity(Member owner, List<FishCard> fishCards, List<Member> likeMembers){
        Aquarium aquarium = Aquarium.builder()
                .id(id)
                .visitorCnt(visitorCnt)
                .likeCnt(likeCnt)
                .fishCnt(fishCnt)
                .totalPrice(totalPrice)
                .member(owner)
                .fishCard(fishCards)
                .build();

        if (likeMembers != null) {
            List<AquariumLike> likes = likeMembers.stream()
                    .map(member -> AquariumLike.builder()
                            .aquariumId(aquarium.getId()) // 아직 저장 전이면 0일 수 있음 → setter 필요
                            .memberId(member.getId())
                            .aquarium(aquarium)
                            .member(member)
                            .build())
                    .collect(Collectors.toList());

            aquarium.setAquariumLikes(likes);
        }
        return aquarium;
    }

    public static AquariumDto fromEntity(Aquarium aquarium) {
        return AquariumDto.builder()
                .id(aquarium.getId())
                .visitorCnt(aquarium.getVisitorCnt())
                .likeCnt(aquarium.getLikeCnt())
                .fishCnt(aquarium.getFishCnt())
                .totalPrice(aquarium.getTotalPrice())
                .member_id(aquarium.getMember().getId())
                .fishCardIds(
                        aquarium.getFishCard() != null ?
                                aquarium.getFishCard().stream()
                                        .map(FishCard::getId)
                                        .collect(Collectors.toList()) :
                                null
                )
                .aquariumLikeMemberIds(
                        aquarium.getAquariumLikes() != null ?
                                aquarium.getAquariumLikes().stream()
                                        .map(AquariumLike::getMemberId)
                                        .collect(Collectors.toList()) :
                                null
                )
                .build();
    }


}
