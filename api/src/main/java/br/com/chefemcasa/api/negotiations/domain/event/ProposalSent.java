package br.com.chefemcasa.api.negotiations.domain.event;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;
public record ProposalSent(UUID eventId, Instant occurredAt, int version,
        UUID negotiationId, UUID clientId, UUID chefId, BigDecimal totalAmount) implements DomainEvent {}
