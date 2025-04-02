package fishermanjoeandchildren.thewater.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;

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
}
