package br.com.chefemcasa.api.briefings.domain.event;

import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import java.time.Instant;
import java.util.UUID;

public record NegotiationStarted(
        UUID eventId, Instant occurredAt, int version,
        UUID briefingId, UUID negotiationId, UUID clientId, UUID chefId
) implements DomainEvent {}
