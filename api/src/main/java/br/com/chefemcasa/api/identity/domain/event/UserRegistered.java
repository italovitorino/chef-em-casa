package br.com.chefemcasa.api.identity.domain.event;

import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;

import java.time.Instant;
import java.util.UUID;

public record UserRegistered(
        UUID eventId,
        Instant occurredAt,
        int version,
        UUID userId,
        String email,
        UserRole role
) implements DomainEvent {}
