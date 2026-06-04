package br.com.chefemcasa.api.briefings.api;

import br.com.chefemcasa.api.briefings.api.dto.*;
import br.com.chefemcasa.api.briefings.domain.*;

public final class BriefingMapper {
    private BriefingMapper() {}

    public static BriefingResponse toResponse(Briefing b) {
        return new BriefingResponse(
                b.getId(), b.getClientId(), b.getStatus(),
                toDetailsResponse(b.getDetails()),
                b.getInterests().stream().map(BriefingMapper::toInterestResponse).toList(),
                b.getCreatedAt(), b.getExpiresAt(), b.getClosedAt()
        );
    }

    private static BriefingDetailsResponse toDetailsResponse(BriefingDetails d) {
        return new BriefingDetailsResponse(d.eventType(), d.eventDate(), d.numberOfGuests(),
                new AddressResponse(d.location().street(), d.location().number(),
                        d.location().city(), d.location().state(), d.location().zipCode()),
                d.estimatedDurationMinutes(), d.notes());
    }

    private static ChefInterestResponse toInterestResponse(ChefInterest i) {
        return new ChefInterestResponse(i.getChefId(), i.getExpressedAt(), i.getMessage());
    }
}
