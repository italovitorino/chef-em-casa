package br.com.chefemcasa.api.solicitations.domain.repository;

import br.com.chefemcasa.api.solicitations.domain.model.Solicitation;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SolicitationRepository {
    Solicitation save(Solicitation solicitation);
    Optional<Solicitation> findById(UUID id);
    List<Solicitation> findByClientId(UUID clientId);
    List<Solicitation> findByChefId(UUID chefId);
}
