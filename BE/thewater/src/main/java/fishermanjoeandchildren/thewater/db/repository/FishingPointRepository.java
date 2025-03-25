package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.FishingPoint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FishingPointRepository extends JpaRepository<FishingPoint, Long> {
}
