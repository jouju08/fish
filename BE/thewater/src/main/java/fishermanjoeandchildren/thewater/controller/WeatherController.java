package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.service.WeatherService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    private final WeatherService weatherService;

    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping
    public ResponseEntity<String> getWeatherData(
            @RequestParam (defaultValue = "34.3503656") double lat,
            @RequestParam (defaultValue = "126.4737491") double lon) {
        String weatherData = weatherService.getWeatherData(lat, lon);
        return ResponseEntity.ok(weatherData);
    }
}