package br.com.chefemcasa.api.briefings.infra;

import br.com.chefemcasa.api.briefings.domain.Briefing;
import br.com.chefemcasa.api.briefings.domain.repository.BriefingRepository;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface SpringDataBriefingRepository extends BriefingRepository, JpaRepository<Briefing, UUID> {}
