package br.com.chefemcasa.api.solicitations.domain.event;

import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public record ReservationConfirmed(
        UUID eventId,
        Instant occurredAt,
        int version,
        UUID solicitationId,
        UUID clientId,
        UUID chefId,
        BigDecimal totalAmount
) implements DomainEvent {}
