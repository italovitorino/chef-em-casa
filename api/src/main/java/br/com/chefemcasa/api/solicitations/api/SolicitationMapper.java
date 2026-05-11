package br.com.chefemcasa.api.solicitations.api;

import br.com.chefemcasa.api.solicitations.api.dto.*;
import br.com.chefemcasa.api.solicitations.domain.model.*;

public final class SolicitationMapper {

    private SolicitationMapper() {}

    public static SolicitationResponse toResponse(Solicitation s) {
        var current = s.getCurrentProposal();
        return new SolicitationResponse(
                s.getId(),
                s.getClientId(),
                s.getChefId(),
                s.getStatus(),
                toBriefingResponse(s.getBriefing()),
                current != null ? toProposalResponse(current) : null,
                s.getProposalHistory().stream().map(SolicitationMapper::toProposalResponse).toList(),
                s.getCreatedAt(),
                s.getUpdatedAt()
        );
    }

    private static BriefingResponse toBriefingResponse(Briefing b) {
        return new BriefingResponse(
                b.eventType(), b.eventDate(), b.numberOfGuests(),
                toAddressResponse(b.location()),
                b.estimatedDurationMinutes(), b.notes()
        );
    }

    private static AddressResponse toAddressResponse(Address a) {
        return new AddressResponse(a.street(), a.number(), a.city(), a.state(), a.zipCode());
    }

    private static ProposalResponse toProposalResponse(Proposal p) {
        return new ProposalResponse(
                p.getId(), p.getTotalAmount(), p.getServiceDescription(),
                p.getValidUntil(), p.getNotes(), p.getSentAt()
        );
    }
}
