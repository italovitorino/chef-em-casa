package br.com.chefemcasa.api.briefings.api.dto;

import br.com.chefemcasa.api.briefings.domain.EventType;
import java.time.LocalDate;

public record BriefingDetailsResponse(
        EventType eventType, LocalDate eventDate, int numberOfGuests,
        AddressResponse location, int estimatedDurationMinutes, String notes
) {}
