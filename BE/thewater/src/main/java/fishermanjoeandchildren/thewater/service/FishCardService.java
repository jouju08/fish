package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.db.entity.*;
import fishermanjoeandchildren.thewater.db.repository.*;
import lombok.RequiredArgsConstructor;
import org.apache.coyote.BadRequestException;
import org.springframework.data.crossstore.ChangeSetPersister;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;


import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class FishCardService {
    private final FishCardRepository fishCardRepository;
    private final AquariumRepository aquariumRepository;
    private final FishRepository fishRepository;
    private final MemberRepository memberRepository;
    private final FishingPointRepository fishingPointRepository;

    public List<FishCardDto> getAllFishCards(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new NoSuchElementException("사용자 정보가 없습니다."));

        List<FishCard> fishCards = fishCardRepository.findFishCardExceptDeleted(member.getId());

        return fishCards.stream()
                .map(FishCardDto::fromEntity)
                .toList();
    }


    public FishCardDto addFishCard(FishCardDto fishCardDto, Long memberId) {
        Member member = memberRepository.findById(memberId).orElse(null);
        if (member == null) {
            throw new NoSuchElementException("유저 정보가 없습니다.");
        }

        FishingPoint fishingPoint = fishingPointRepository.findById(fishCardDto.getFishingPointId()).orElse(null);
        if (fishingPoint == null) {
            throw new NoSuchElementException("낚시 포인트 정보가 없습니다.");
        }

        Fish fish = fishRepository.findByFishname(fishCardDto.getFishName()).orElse(null);
        if (fish == null) {
            throw new NoSuchElementException("물고기 정보가 없습니다.");
        }

        Aquarium aquarium=member.getAquarium();

        FishCard fishcard = fishCardDto.toEntity(member,fishingPoint,fish,aquarium);
        FishCard savedFishcard = fishCardRepository.save(fishcard);

        return FishCardDto.fromEntity(savedFishcard);
    }

    public String deleteFishCard(Long fishCardId, Long memberId) {
        FishCard fishCard = fishCardRepository.findById(fishCardId).orElse(null);
        if (fishCard == null) return ResponseStatus.NOT_FOUND;

        // 소유자 확인
        if (!fishCard.getMember().getId().equals(memberId)) {
            return ResponseStatus.NOT_FOUND;
        }

        // soft delete 처리
        fishCard.setHasDeleted(true);
        fishCardRepository.save(fishCard);
        return ResponseStatus.SUCCESS;
    }

}
