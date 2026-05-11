package br.com.chefemcasa.api.solicitations.api.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.LocalDate;

public record SubmitProposalRequest(
        @NotNull @DecimalMin("0.01") BigDecimal totalAmount,
        @NotBlank String serviceDescription,
        @NotNull LocalDate validUntil,
        String notes
) {}
