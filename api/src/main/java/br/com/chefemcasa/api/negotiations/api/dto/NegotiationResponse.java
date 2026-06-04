package br.com.chefemcasa.api.negotiations.api.dto;

import br.com.chefemcasa.api.negotiations.domain.NegotiationStatus;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record NegotiationResponse(
        UUID id, UUID briefingId, UUID clientId, UUID chefId,
        NegotiationStatus status,
        ProposalResponse currentProposal,
        List<ProposalResponse> proposalHistory,
        Instant createdAt, Instant updatedAt
) {}
