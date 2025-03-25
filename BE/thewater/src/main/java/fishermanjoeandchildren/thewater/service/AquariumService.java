package fishermanjoeandchildren.thewater.service;


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
    private  final FishCardRepository fishCardRepository;

    public AquariumDto saveAquarium(AquariumDto aquariumDto){

        Member member = memberRepository.findById(aquariumDto.getMember_id()).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 멤버입니다."));
        List<FishCard> fishCards = fishCardRepository.findAllById(aquariumDto.getFishCardIds());
        List<Member> likeMembers = aquariumDto.getAquariumLikeMemberIds() != null? memberRepository.findAllById(aquariumDto.getAquariumLikeMemberIds()): List.of();

        Aquarium aquarium = aquariumDto.toEntity(member,fishCards, likeMembers);
        Aquarium savedAquarium = aquariumRepository.save(aquarium);


        return AquariumDto.fromEntity(savedAquarium);
    }


    public AquariumDto getAquarium(Long id){
        Aquarium aquarium = aquariumRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 어항입니다."));


        return AquariumDto.fromEntity(aquarium);
    }
}
