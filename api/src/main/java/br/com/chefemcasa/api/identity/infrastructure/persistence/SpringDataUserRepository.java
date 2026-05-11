package br.com.chefemcasa.api.identity.infrastructure.persistence;

import br.com.chefemcasa.api.identity.domain.model.User;
import br.com.chefemcasa.api.identity.domain.repository.UserRepository;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface SpringDataUserRepository extends UserRepository, JpaRepository<User, UUID> {}
