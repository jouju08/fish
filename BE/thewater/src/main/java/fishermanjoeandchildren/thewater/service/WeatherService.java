package fishermanjoeandchildren.thewater.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Service
public class WeatherService {

    @Value("${weather.api.key}")
    private String serviceKey;

    @Value("${weather.api.getVilageFcst}")
    private String apiUrl;

    private final RestTemplate restTemplate;

    public WeatherService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public String getWeatherData(double lat, double lon) {
        try {
            // 1. 위경도를 XY좌표로 변환
            int[] xy = GeoPointConverter.convertToXY(lat, lon);
            int nx = xy[0];
            int ny = xy[1];

            // 2. 현재 날짜와 시간 설정
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime threeHoursAgo = now.minusHours(3);
            int[] availableHours = {2, 5, 8, 11, 14, 17, 20, 23};
            int currentHour = threeHoursAgo.getHour();
            int adjustedHour = -1;

            for (int i = availableHours.length - 1; i >= 0; i--) {
                if (availableHours[i] <= currentHour) {
                    adjustedHour = availableHours[i];
                    break;
                }
            }

            LocalDateTime adjustedDateTime;
            if (adjustedHour == -1) {
                adjustedDateTime = threeHoursAgo.minusDays(1).withHour(23).withMinute(0).withSecond(0);
            } else {
                adjustedDateTime = threeHoursAgo.withHour(adjustedHour).withMinute(0).withSecond(0);
            }

            String baseDate = adjustedDateTime.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String baseTime = String.format("%02d00", adjustedDateTime.getHour());

            System.out.println("baseDate=" + baseDate + ", baseTime=" + baseTime);

            // 3. URL 문자열 구성
            String urlString = apiUrl +
                    "?serviceKey=" + serviceKey +
                    "&numOfRows=2000" +
                    "&pageNo=1" +
                    "&dataType=JSON" +
                    "&base_date=" + baseDate +
                    "&base_time=" + baseTime +
                    "&nx=" + nx +
                    "&ny=" + ny;

            System.out.println("API 요청 URL: " + urlString);

            // 4. URI 객체 생성 (이 과정에서 자동 인코딩 발생)
            URI uri = new URI(urlString);

            // 5. RestTemplate으로 API 호출 및 응답 그대로 반환
            String response = restTemplate.getForObject(uri, String.class);
            System.out.println("API 응답: " + response);

            return response;

        } catch (URISyntaxException e) {
            e.printStackTrace();
            return "Error creating URI: " + e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            return "Error calling API: " + e.getMessage();
        }
    }
}