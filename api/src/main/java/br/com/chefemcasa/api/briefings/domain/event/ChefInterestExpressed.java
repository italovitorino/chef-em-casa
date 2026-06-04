package br.com.chefemcasa.api.briefings.domain.event;

import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import java.time.Instant;
import java.util.UUID;

public record ChefInterestExpressed(
        UUID eventId, Instant occurredAt, int version,
        UUID briefingId, UUID chefId
) implements DomainEvent {}
