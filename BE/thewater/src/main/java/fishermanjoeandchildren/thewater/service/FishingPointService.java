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

    private final FishingPointRepository fishingPointRepository;

    public List<FishingPointDto> getAllOfficialFishingPoints() {
        return fishingPointRepository.findByOfficialTrue()
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    private FishingPointDto convertToDto(FishingPoint fishingPoint) {
        return FishingPointDto.builder()
                .id(fishingPoint.getId())
                .pointName(fishingPoint.getPointName())
                .latitude(fishingPoint.getLatitude())
                .longitude(fishingPoint.getLongitude())
                .address(fishingPoint.getAddress())
                .official(fishingPoint.getOfficial())
                .build();
    }
}