package br.com.chefemcasa.api.briefings.api.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record StartNegotiationRequest(@NotNull UUID chefId) {}
