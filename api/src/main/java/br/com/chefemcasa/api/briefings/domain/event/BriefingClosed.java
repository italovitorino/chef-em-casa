package br.com.chefemcasa.api.briefings.domain.event;

import br.com.chefemcasa.api.briefings.domain.BriefingCloseReason;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import java.time.Instant;
import java.util.UUID;

public record BriefingClosed(
        UUID eventId, Instant occurredAt, int version,
        UUID briefingId, BriefingCloseReason reason
) implements DomainEvent {}
