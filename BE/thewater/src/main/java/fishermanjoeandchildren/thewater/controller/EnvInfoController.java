package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.service.WaterTempService;
import fishermanjoeandchildren.thewater.service.WeatherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/env-info")
public class EnvInfoController {

    private final WeatherService weatherService;

    @Autowired
    private WaterTempService waterTempService;

    public EnvInfoController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    @GetMapping("/predict/weather")
    public ApiResponse<?> getWeatherData(
            @RequestParam (defaultValue = "34.3503656") double lat,
            @RequestParam (defaultValue = "126.4737491") double lon) {
        String weatherData = weatherService.getWeatherData(lat, lon);

        try {
            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(weatherData).build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND_PAGE)
                    .message(ResponseMessage.NOT_FOUND_PAGE)
                    .data("날씨 정보를 불러오는 중 에러가 발생했습니다." + e.getMessage()).build();
        }
    }

    @GetMapping("/predict/water-temp")
    public ApiResponse<?> getWaterTemperature(
            @RequestParam (defaultValue = "34.3503656") double lat,
            @RequestParam (defaultValue = "126.4737491") double lon) {
        try {
            String waterTemperature = waterTempService.getWaterTemperature(lat, lon);
            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(waterTemperature)
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.BAD_REQUEST)
                    .message(ResponseMessage.BAD_REQUEST)
                    .data("수온 데이터를 가져오는 중 오류가 발생했습니다." + e.getMessage())
                    .build();
        }
    }
}