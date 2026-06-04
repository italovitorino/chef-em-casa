package br.com.chefemcasa.api.briefings.api.dto;

import java.time.Instant;
import java.util.UUID;

public record ChefInterestResponse(UUID chefId, Instant expressedAt, String message) {}
