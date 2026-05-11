package br.com.chefemcasa.api.identity.api.dto;

import java.util.UUID;

public record TokenResponse(
        String accessToken,
        String tokenType,
        int expiresIn,
        UUID refreshToken
) {}
