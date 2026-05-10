package br.com.chefemcasa.api.identity.infrastructure;

import br.com.chefemcasa.api.identity.domain.model.RefreshToken;
import br.com.chefemcasa.api.identity.domain.repository.RefreshTokenRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public class JpaRefreshTokenRepository implements RefreshTokenRepository {

    private final SpringDataRefreshTokenRepository delegate;

    public JpaRefreshTokenRepository(SpringDataRefreshTokenRepository delegate) {
        this.delegate = delegate;
    }

    @Override
    public RefreshToken save(RefreshToken token) {
        return delegate.save(token);
    }

    @Override
    public Optional<RefreshToken> findByToken(UUID token) {
        return delegate.findByToken(token);
    }
}
