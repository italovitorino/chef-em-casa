package br.com.chefemcasa.api.negotiations.domain.repository;

import br.com.chefemcasa.api.negotiations.domain.Negotiation;
import br.com.chefemcasa.api.negotiations.domain.NegotiationStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NegotiationRepository {
    Negotiation save(Negotiation negotiation);
    Optional<Negotiation> findById(UUID id);
    List<Negotiation> findByClientId(UUID clientId);
    List<Negotiation> findByChefId(UUID chefId);
    List<Negotiation> findByBriefingId(UUID briefingId);
    List<Negotiation> findByBriefingIdAndStatusIn(UUID briefingId, List<NegotiationStatus> statuses);
}
