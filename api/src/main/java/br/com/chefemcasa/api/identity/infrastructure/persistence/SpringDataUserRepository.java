package br.com.chefemcasa.api.identity.infrastructure.persistence;

import br.com.chefemcasa.api.identity.domain.model.User;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.identity.domain.repository.UserRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

interface SpringDataUserRepository extends UserRepository, JpaRepository<User, UUID> {

    @Query("SELECT u.id FROM User u WHERE u.role = :#{T(br.com.chefemcasa.api.identity.domain.model.UserRole).CHEF}")
    List<UUID> findAllChefIds();
}
