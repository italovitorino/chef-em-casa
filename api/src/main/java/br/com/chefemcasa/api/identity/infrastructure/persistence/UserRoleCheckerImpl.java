package br.com.chefemcasa.api.identity.infrastructure.persistence;

import br.com.chefemcasa.api.identity.domain.model.User;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.identity.domain.repository.UserRepository;
import br.com.chefemcasa.api.solicitations.application.UserRoleChecker;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.UUID;

@Component
public class UserRoleCheckerImpl implements UserRoleChecker {

    private final UserRepository userRepository;

    public UserRoleCheckerImpl(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public Optional<UserRole> findRoleById(UUID userId) {
        return userRepository.findById(userId).map(User::getRole);
    }
}
