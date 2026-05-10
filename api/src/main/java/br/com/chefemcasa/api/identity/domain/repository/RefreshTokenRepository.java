package br.com.chefemcasa.api.identity.domain.repository;

import br.com.chefemcasa.api.identity.domain.model.RefreshToken;

import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository {
    RefreshToken save(RefreshToken token);
    Optional<RefreshToken> findByToken(UUID token);
}
