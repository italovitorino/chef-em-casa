package br.com.chefemcasa.api.solicitations.infrastructure;

import br.com.chefemcasa.api.solicitations.domain.model.Solicitation;
import br.com.chefemcasa.api.solicitations.domain.repository.SolicitationRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JpaSolicitationRepository implements SolicitationRepository {

    private final SpringDataSolicitationRepository delegate;

    public JpaSolicitationRepository(SpringDataSolicitationRepository delegate) {
        this.delegate = delegate;
    }

    @Override
    public Solicitation save(Solicitation solicitation) {
        return delegate.save(solicitation);
    }

    @Override
    public Optional<Solicitation> findById(UUID id) {
        return delegate.findById(id);
    }

    @Override
    public List<Solicitation> findByClientId(UUID clientId) {
        return delegate.findByClientId(clientId);
    }

    @Override
    public List<Solicitation> findByChefId(UUID chefId) {
        return delegate.findByChefId(chefId);
    }
}
