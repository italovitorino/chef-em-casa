package br.com.chefemcasa.api.solicitations.api.dto;

import br.com.chefemcasa.api.solicitations.domain.model.EventType;

import java.time.LocalDate;

public record BriefingResponse(
        EventType eventType,
        LocalDate eventDate,
        int numberOfGuests,
        AddressResponse location,
        int estimatedDurationMinutes,
        String notes
) {}
