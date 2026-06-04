package br.com.chefemcasa.api.negotiations.infra;

import br.com.chefemcasa.api.negotiations.domain.Negotiation;
import br.com.chefemcasa.api.negotiations.domain.repository.NegotiationRepository;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface SpringDataNegotiationRepository extends NegotiationRepository, JpaRepository<Negotiation, UUID> {}
