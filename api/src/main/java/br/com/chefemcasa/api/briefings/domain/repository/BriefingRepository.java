package br.com.chefemcasa.api.briefings.domain.repository;

import br.com.chefemcasa.api.briefings.domain.Briefing;
import br.com.chefemcasa.api.briefings.domain.BriefingStatus;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BriefingRepository {
    Briefing save(Briefing briefing);
    Optional<Briefing> findById(UUID id);
    List<Briefing> findByClientId(UUID clientId);
    List<Briefing> findByStatus(BriefingStatus status);
    List<Briefing> findByStatusAndExpiresAtBefore(BriefingStatus status, Instant expiresAt);
}
