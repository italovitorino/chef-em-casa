package br.com.chefemcasa.api.negotiations.domain.event;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import java.time.Instant;
import java.util.UUID;
public record ProposalRejected(UUID eventId, Instant occurredAt, int version,
        UUID negotiationId, UUID clientId, UUID chefId) implements DomainEvent {}
