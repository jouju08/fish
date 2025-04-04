package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {
    boolean existsByLoginId(String loginId);
    boolean existsByEmail(String email);
    boolean existsByNickname(String nickname);
    Optional<Member> findByLoginId(String loginId);

    List<Member> findByNicknameContaining(String nickname);

    @Query("SELECT m.nickname FROM Member m WHERE m.has_deleted = false")
    List<String> findAllActiveNicknames();
}
