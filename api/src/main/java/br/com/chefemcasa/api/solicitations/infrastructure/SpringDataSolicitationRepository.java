package br.com.chefemcasa.api.solicitations.infrastructure;

import br.com.chefemcasa.api.solicitations.domain.model.Solicitation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

interface SpringDataSolicitationRepository extends JpaRepository<Solicitation, UUID> {
    List<Solicitation> findByClientId(UUID clientId);
    List<Solicitation> findByChefId(UUID chefId);
}
