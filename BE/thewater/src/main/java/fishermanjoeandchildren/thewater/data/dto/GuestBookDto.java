package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.GuestBook;
import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import jdk.jfr.Description;
import lombok.*;

@Schema(description = "방명록 정보")
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class GuestBookDto {

    @Schema(description = "get요청시 사용되는 부분, post시 해당 값 보내지 않아도 됨")
    private Long guestBookId;

    @NotNull
    @Schema(description = "get요청시 사용되는 부분, post시 해당 값 보내지 않아도 됨")
    private String guestNickname;

    @NotNull
    private String guestBookComment;

    @Schema(description = "get요청시 사용되는 부분, post시 해당 값 보내지 않아도 됨")
    private Boolean wroteByMe;

    public static GuestBookDto fromEntity(GuestBook guestBook, Long currentMember){

        boolean myCommnet = guestBook.getId() == currentMember;

        return GuestBookDto.builder()
                .guestBookId(guestBook.getId())
                .guestNickname(guestBook.getGuest().getNickname())
                .guestBookComment(guestBook.getComment())
                .wroteByMe(myCommnet)
                .build();
    }

    public static GuestBook toEntity(GuestBookDto guestBookDto, Aquarium aquarium , Member member){

        return GuestBook.builder()
                .comment(guestBookDto.getGuestBookComment())
                .aquarium(aquarium)
                .guest(member)
                .build();
    }

}
