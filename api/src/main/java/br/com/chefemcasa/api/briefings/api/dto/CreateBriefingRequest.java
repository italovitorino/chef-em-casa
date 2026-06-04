package br.com.chefemcasa.api.briefings.api.dto;

import br.com.chefemcasa.api.briefings.domain.EventType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record CreateBriefingRequest(
        @NotNull EventType eventType,
        @NotNull LocalDate eventDate,
        @Min(1) int numberOfGuests,
        @NotBlank String street,
        @NotBlank String number,
        @NotBlank String city,
        @NotBlank String state,
        @NotBlank String zipCode,
        @Min(1) int estimatedDurationMinutes,
        String notes
) {}
