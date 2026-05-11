package br.com.chefemcasa.api.identity.infrastructure.persistence;

import br.com.chefemcasa.api.identity.domain.model.RefreshToken;
import br.com.chefemcasa.api.identity.domain.repository.RefreshTokenRepository;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface SpringDataRefreshTokenRepository extends RefreshTokenRepository, JpaRepository<RefreshToken, UUID> {}
