package br.com.chefemcasa.api.solicitations.infrastructure;

import br.com.chefemcasa.api.solicitations.domain.model.Solicitation;
import br.com.chefemcasa.api.solicitations.domain.repository.SolicitationRepository;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface SpringDataSolicitationRepository extends SolicitationRepository, JpaRepository<Solicitation, UUID> {}
