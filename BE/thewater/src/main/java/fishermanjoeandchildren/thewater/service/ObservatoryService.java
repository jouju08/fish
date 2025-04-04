package fishermanjoeandchildren.thewater.service;

import org.springframework.stereotype.Service;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.annotation.PostConstruct;

@Service
public class ObservatoryService {

    // 관측소 정보를 저장할 클래스
    private static class Observatory {
        String code;
        String name;
        double latitude;
        double longitude;

        public Observatory(String code, String name, double latitude, double longitude) {
            this.code = code;
            this.name = name;
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }

    // 관측소 목록
    private List<Observatory> observatories = new ArrayList<>();

    // 코드로 빠르게 관측소를 찾기 위한 맵
    private Map<String, Observatory> observatoryMap = new HashMap<>();

    // 서비스 초기화 시 관측소 데이터 로드
    @PostConstruct
    public void init() {
        try {
            // 클래스패스에서 관측소 데이터 파일 로드
            InputStream is = getClass().getResourceAsStream("/observatories.txt");
            BufferedReader reader = new BufferedReader(new InputStreamReader(is));

            // 헤더 스킵
            String line = reader.readLine();

            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\t");
                if (parts.length >= 4) {
                    String code = parts[0].trim();
                    String name = parts[1].trim();
                    double latitude = Double.parseDouble(parts[2].trim());
                    double longitude = Double.parseDouble(parts[3].trim());

                    Observatory observatory = new Observatory(code, name, latitude, longitude);
                    observatories.add(observatory);
                    observatoryMap.put(code, observatory);
                }
            }

            reader.close();
            System.out.println("관측소 " + observatories.size() + "개 로드 완료");
        } catch (Exception e) {
            System.err.println("관측소 데이터 로드 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 하버사인 공식(Haversine formula)을 사용하여 두 지점 간의 거리를 계산
     * @param lat1 첫 번째 지점의 위도
     * @param lon1 첫 번째 지점의 경도
     * @param lat2 두 번째 지점의 위도
     * @param lon2 두 번째 지점의 경도
     * @return 거리(km)
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        // 지구 반경 (km)
        final double R = 6371.0;

        // 라디안으로 변환
        double lat1Rad = Math.toRadians(lat1);
        double lon1Rad = Math.toRadians(lon1);
        double lat2Rad = Math.toRadians(lat2);
        double lon2Rad = Math.toRadians(lon2);

        // 위도 및 경도 차이
        double dLat = lat2Rad - lat1Rad;
        double dLon = lon2Rad - lon1Rad;

        // 하버사인 공식
        double a = Math.pow(Math.sin(dLat / 2), 2) +
                Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                        Math.pow(Math.sin(dLon / 2), 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;

        return distance;
    }

    /**
     * 주어진 위도/경도에 가장 가까운 관측소 코드 반환
     * @param latitude 위도
     * @param longitude 경도
     * @return 가장 가까운 관측소 코드
     */
    public String findNearestObservatory(double latitude, double longitude) {
        if (observatories.isEmpty()) {
            throw new IllegalStateException("관측소 데이터가 로드되지 않았습니다.");
        }

        Observatory nearest = null;
        double minDistance = Double.MAX_VALUE;

        for (Observatory obs : observatories) {
            double distance = calculateDistance(latitude, longitude, obs.latitude, obs.longitude);
            if (distance < minDistance) {
                minDistance = distance;
                nearest = obs;
            }
        }

        if (nearest != null) {
            System.out.println("가장 가까운 관측소: " + nearest.name + " (" + nearest.code + "), 거리: " + minDistance + "km");
            return nearest.code;
        } else {
            throw new IllegalStateException("가장 가까운 관측소를 찾을 수 없습니다.");
        }
    }

    /**
     * 관측소 코드로 관측소 이름 조회
     * @param code 관측소 코드
     * @return 관측소 이름
     */
    public String getObservatoryName(String code) {
        Observatory observatory = observatoryMap.get(code);
        return observatory != null ? observatory.name : "알 수 없는 관측소";
    }

    /**
     * 관측소 정보 반환
     * @param code 관측소 코드
     * @return 관측소 정보 (코드, 이름, 위도, 경도)
     */
    public Map<String, Object> getObservatoryInfo(String code) {
        Observatory observatory = observatoryMap.get(code);

        if (observatory != null) {
            Map<String, Object> info = new HashMap<>();
            info.put("code", observatory.code);
            info.put("name", observatory.name);
            info.put("latitude", observatory.latitude);
            info.put("longitude", observatory.longitude);
            return info;
        }

        return null;
    }

    /**
     * 모든 관측소 정보 조회
     * @return 관측소 정보 목록
     */
    public List<Map<String, Object>> getAllObservatories() {
        List<Map<String, Object>> result = new ArrayList<>();

        for (Observatory obs : observatories) {
            Map<String, Object> info = new HashMap<>();
            info.put("code", obs.code);
            info.put("name", obs.name);
            info.put("latitude", obs.latitude);
            info.put("longitude", obs.longitude);
            result.add(info);
        }

        return result;
    }
}