package br.com.chefemcasa.api.solicitations.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;

import java.time.LocalDate;

@Embeddable
public record Briefing(
        @Enumerated(EnumType.STRING) @Column(name = "event_type")   EventType eventType,
        @Column(name = "event_date")                                 LocalDate eventDate,
        @Column(name = "number_of_guests")                           int numberOfGuests,
        Address location,
        @Column(name = "estimated_duration_minutes")                 int estimatedDurationMinutes,
        String notes
) {}
