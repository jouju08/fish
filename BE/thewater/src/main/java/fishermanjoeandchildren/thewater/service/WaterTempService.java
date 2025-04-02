package fishermanjoeandchildren.thewater.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class WaterTempService {

    @Value("${waterTemp.api.key}")
    private String waterTempKey;

    @Value("${waterTemp.api}")
    private String waterTempApi;

    private RestTemplate restTemplate = new RestTemplate();

    public String getWaterTemperature(double lat, double lon) {
        String url = waterTempApi +
                "?ServiceKey=" + waterTempKey +
                "&ObsLon=" + lon +
                "&ObsLat=" + lat +
                "&ResultType=json";

        System.out.printf(url);
        ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
        return response.getBody();
    }

    public List<Map<String, String>> getFilteredWaterTemperature(double lat, double lon) {
        try {
            // API 호출해서 응답 받기
            String responseBody = getWaterTemperature(lat, lon);

            // JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(responseBody);

            // 데이터 배열 가져오기
            JsonNode dataArray = rootNode.path("result").path("data");

            // 필터링할 시간 배열
            List<String> targetHours = Arrays.asList("0", "3", "6", "9", "12", "15", "18", "21");

            // 결과를 저장할 리스트
            List<Map<String, String>> filteredResults = new ArrayList<>();

            // 데이터 순회하면서 필요한 시간대만 필터링
            for (JsonNode item : dataArray) {
                String hour = item.path("hour").asText();

                // 원하는 시간대인 경우만 추가
                if (targetHours.contains(hour)) {
                    Map<String, String> tempData = new HashMap<>();
                    tempData.put("hour", hour);
                    tempData.put("date", item.path("date").asText());
                    tempData.put("temperature", item.path("temperature").asText());

                    filteredResults.add(tempData);
                }
            }

            return filteredResults;

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>(); // 오류 발생 시 빈 리스트 반환
        }
    }
}
