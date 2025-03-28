package fishermanjoeandchildren.thewater.service;


import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.AquariumDto;
import fishermanjoeandchildren.thewater.db.entity.*;
import fishermanjoeandchildren.thewater.db.repository.AquariumLikeRepository;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AquariumService {

    private final AquariumRepository aquariumRepository;
    private final MemberRepository memberRepository;
    private final AquariumLikeRepository aquariumLikeRepository;

    public AquariumDto saveAquarium(AquariumDto aquariumDto, Long currentMemberId){

        Member member = memberRepository.findById(aquariumDto.getMember_id()).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 멤버입니다."));

        Aquarium aquarium = aquariumDto.toEntity(member);
        Aquarium savedAquarium = aquariumRepository.save(aquarium);


        return AquariumDto.fromEntity(savedAquarium, currentMemberId);
    }


    public AquariumDto getAquarium(Long aquariumId, Long currentMemberId){
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);


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

    public String likeAquarium(Long aquariumId, Long currentMemberId){
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);

        if(aquarium == null){
            return ResponseStatus.NOT_FOUND;
        }

        if(aquariumLikeRepository.existsByAquariumIdAndMemberId(aquariumId, currentMemberId)){
            return ResponseStatus.CONFLICT;
        }

        AquariumLike like = AquariumLike.builder()
                . aquariumId(aquariumId)
                .memberId(currentMemberId)
                .build();
        aquariumLikeRepository.save(like);

        aquarium.incrementLikes();
        aquariumRepository.save(aquarium);

        return ResponseStatus.SUCCESS;
    }

    public String unlikeAquarium(Long aquariumId, Long memberId) {
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);
        if (aquarium == null) {
            return ResponseStatus.NOT_FOUND;
        }

        AquariumLikeId likeId = new AquariumLikeId(aquariumId, memberId);

        if (!aquariumLikeRepository.existsByAquariumIdAndMemberId(aquariumId,memberId)) {
            return ResponseStatus.NOT_FOUND;
        }

        aquariumLikeRepository.deleteById(new AquariumLikeId(aquariumId,memberId));
        aquarium.decrementLikes();
        aquariumRepository.save(aquarium);

        return ResponseStatus.SUCCESS;
    }

}
