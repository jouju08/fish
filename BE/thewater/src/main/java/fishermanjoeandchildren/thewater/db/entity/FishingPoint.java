package fishermanjoeandchildren.thewater.db.entity;

import jakarta.persistence.*;

import java.util.List;

@Table(name = "fishing_point")
@Entity
public class FishingPoint {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //지명
    @Column(nullable = false, name = "point_name")
    private String pointName;

    //위도
    @Column(nullable = false)
    private String latitude;

    //경도
    @Column(nullable = false)
    private String longitude;

    //위치(address)
    @Column(nullable = false)
    private String address;

    // 공개여부
    @Column(nullable = false)
    private Boolean official = false;


}
