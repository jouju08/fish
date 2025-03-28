package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {
    boolean existsByLoginId(String loginId);
    boolean existsByEmail(String email);
    boolean existsByNickname(String nickname);
    Optional<Member> findByLoginId(String loginId);
}
