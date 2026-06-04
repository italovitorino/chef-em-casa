package br.com.chefemcasa.api.shared.application;

import br.com.chefemcasa.api.identity.domain.model.UserRole;
import java.util.Optional;
import java.util.UUID;

public interface UserRoleChecker {
    Optional<UserRole> findRoleById(UUID userId);
}
