package br.com.chefemcasa.api.briefings.api.dto;

import br.com.chefemcasa.api.briefings.domain.BriefingStatus;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record BriefingResponse(
        UUID id, UUID clientId, BriefingStatus status,
        BriefingDetailsResponse details, List<ChefInterestResponse> interests,
        Instant createdAt, Instant expiresAt, Instant closedAt
) {}
