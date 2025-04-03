package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.dto.FishingPointDto;
import fishermanjoeandchildren.thewater.db.entity.FishingPoint;
import fishermanjoeandchildren.thewater.db.repository.FishingPointRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FishingPointService {

    private final FishingPointRepository fishingPointRepository; // 레포지토리 의존성 주입

    public List<FishingPointDto> getAllFishingPoints() {
        return fishingPointRepository.findAll() // 소문자로 변경(인스턴스 메서드)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    // convertToDto 메서드 추가
    private FishingPointDto convertToDto(FishingPoint fishingPoint) {
        return FishingPointDto.builder()
                .id(fishingPoint.getId())
                .pointName(fishingPoint.getPointName())
                .latitude(fishingPoint.getLatitude())
                .longitude(fishingPoint.getLongitude())
                .address(fishingPoint.getAddress())
                .build();
    }
}