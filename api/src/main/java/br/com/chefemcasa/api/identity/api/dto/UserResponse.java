package br.com.chefemcasa.api.identity.api.dto;

import br.com.chefemcasa.api.identity.domain.model.UserRole;

import java.time.Instant;
import java.util.UUID;

public record UserResponse(
        UUID id,
        String name,
        String email,
        UserRole role,
        Instant createdAt
) {}
