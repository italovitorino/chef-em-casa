package br.com.chefemcasa.api.solicitations.api.dto;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record ProposalResponse(
        UUID id,
        BigDecimal totalAmount,
        String serviceDescription,
        LocalDate validUntil,
        String notes,
        Instant sentAt
) {}
