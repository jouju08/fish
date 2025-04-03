package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.GuestBookDto;
import fishermanjoeandchildren.thewater.db.entity.GuestBook;
import fishermanjoeandchildren.thewater.db.repository.GuestBookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GuestBookService {

    private final GuestBookRepository guestBookRepository;

    public ApiResponse<?> getComments(Long aquariumId, Long currentMemberId){
        List<GuestBook> guestBook = guestBookRepository.findByAquariumId(aquariumId);

        List<GuestBookDto> guestBookDtos = guestBook.stream()
                .map(gb->GuestBookDto.fromEntity(gb,currentMemberId))
                .collect(Collectors.toList());

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(guestBookDtos)
                .build();
    }
}
