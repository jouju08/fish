package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.dto.AquariumDto;
import fishermanjoeandchildren.thewater.service.AquariumService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/aquarium")
public class AquariumController {

    private AquariumService aquariumService;

    @Autowired
    public AquariumController(AquariumService aquariumService){
        this.aquariumService = aquariumService;
    }

    @GetMapping("/stats/{aquarium_id}")
    public ResponseEntity<AquariumDto> getAquariumStats(@PathVariable("aquarium_id") Long aquariumId){
        AquariumDto aquariumDto = aquariumService.getAquarium(aquariumId);


        return ResponseEntity.status(HttpStatus.OK).body(aquariumDto);
    }

//    @PostMapping("/")



}
