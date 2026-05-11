package br.com.chefemcasa.api.identity.api.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record RefreshTokenRequest(@NotNull UUID refreshToken) {}
