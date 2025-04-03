package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.GuestBook;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class GuestBookDto {
    @NotNull
    private Long guestBookId;

    @NotNull
    private String guestNickname;

    @NotNull
    private String guestBookComment;

    @NotNull
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

}
