package br.com.chefemcasa.api.identity.application;

import java.util.UUID;

public record TokenPair(String accessToken, UUID refreshToken) {}
