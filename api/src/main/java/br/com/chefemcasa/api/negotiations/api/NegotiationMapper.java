package br.com.chefemcasa.api.negotiations.api;

import br.com.chefemcasa.api.negotiations.api.dto.NegotiationResponse;
import br.com.chefemcasa.api.negotiations.api.dto.ProposalResponse;
import br.com.chefemcasa.api.negotiations.domain.Negotiation;
import br.com.chefemcasa.api.negotiations.domain.Proposal;

public final class NegotiationMapper {
    private NegotiationMapper() {}

    public static NegotiationResponse toResponse(Negotiation n) {
        var current = n.getCurrentProposal();
        return new NegotiationResponse(
                n.getId(), n.getBriefingId(), n.getClientId(), n.getChefId(), n.getStatus(),
                current != null ? toProposalResponse(current) : null,
                n.getProposalHistory().stream().map(NegotiationMapper::toProposalResponse).toList(),
                n.getCreatedAt(), n.getUpdatedAt()
        );
    }

    private static ProposalResponse toProposalResponse(Proposal p) {
        return new ProposalResponse(p.getId(), p.getTotalAmount(), p.getServiceDescription(),
                p.getValidUntil(), p.getNotes(), p.getSentAt());
    }
}
