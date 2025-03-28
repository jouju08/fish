package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.Fish;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import fishermanjoeandchildren.thewater.db.repository.FishCardRepository;
import fishermanjoeandchildren.thewater.db.repository.FishRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
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

    public List<FishCardDto> getAllFishCards(Long memberId) {
        List<FishCardDto> allFishCard= new ArrayList<FishCardDto>();
        Member member = memberRepository.findById(memberId).orElseThrow(NoSuchElementException::new);
        Long userId = member.getId();
        try{
            allFishCard=fishCardRepository.findFishCardExceptDeleted(userId);
            if(allFishCard.isEmpty()){
                throw new NoSuchElementException("No FishCard found");
            }
            return allFishCard;
        }catch (Exception e){
            throw new NoSuchElementException("등록된 물고기 정보가 없습니다.");
        }

    }

    public FishCard addFishCard(FishCardDto fishCardDto,Long memberId) {
        FishCard fishCard = fishCardDto.toEntity();
        String fishName = fishCardDto.getFishName();
        try{
            Member member = memberRepository.findById(memberId).orElseThrow(NoSuchElementException::new);
            Aquarium aquarium=member.getAquarium();
            if (aquarium == null) {
                throw new RuntimeException("어항이 존재하지 않습니다.");
            }
            Fish fish= fishRepository.findByFishname(fishName).orElseThrow(()-> new RuntimeException("존재하지 않는 물고기입니다."));
            fishCard.setAquarium(aquarium);
            fishCard.setMember(member);
            fishCard.setFish(fish);
            fishCardRepository.save(fishCard);
            return fishCard;
        }catch (Exception e){
            throw new RuntimeException("도감 생성 실패");
        }
    }
}
