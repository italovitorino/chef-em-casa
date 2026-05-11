package br.com.chefemcasa.api.solicitations.api.dto;

import br.com.chefemcasa.api.solicitations.domain.model.SolicitationStatus;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record SolicitationResponse(
        UUID id,
        UUID clientId,
        UUID chefId,
        SolicitationStatus status,
        BriefingResponse briefing,
        ProposalResponse currentProposal,
        List<ProposalResponse> proposalHistory,
        Instant createdAt,
        Instant updatedAt
) {}
