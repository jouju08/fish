package fishermanjoeandchildren.thewater.service;


import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.AquariumDto;
import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.Fish;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import fishermanjoeandchildren.thewater.db.repository.FishCardRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AquariumService {

    private final AquariumRepository aquariumRepository;
    private final MemberRepository memberRepository;

    public AquariumDto saveAquarium(AquariumDto aquariumDto, Long currentMemberId){

        Member member = memberRepository.findById(aquariumDto.getMember_id()).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 멤버입니다."));

        Aquarium aquarium = aquariumDto.toEntity(member);
        Aquarium savedAquarium = aquariumRepository.save(aquarium);


        return AquariumDto.fromEntity(savedAquarium, currentMemberId);
    }


    public AquariumDto getAquarium(Long id, Long currentMemberId){
        Aquarium aquarium = aquariumRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 어항입니다."));


        return AquariumDto.fromEntity(aquarium,currentMemberId);
    }

    public String updateVisitorCount(Long aquariumId){
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);
        if(aquarium == null){
            return ResponseStatus.NOT_FOUND;
        }

        aquarium.incrementVisitors();
        aquariumRepository.save(aquarium);
        return ResponseStatus.SUCCESS;
    }
}
