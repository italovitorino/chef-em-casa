package br.com.chefemcasa.api.briefings.infra;

import br.com.chefemcasa.api.briefings.application.BriefingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ExpireBriefingsJob {

    private static final Logger log = LoggerFactory.getLogger(ExpireBriefingsJob.class);

    private final BriefingService briefingService;

    public ExpireBriefingsJob(BriefingService briefingService) {
        this.briefingService = briefingService;
    }

    @Scheduled(fixedDelay = 3_600_000)
    public void expireOverdueBriefings() {
        log.info("[EXPIRE-BRIEFINGS] Verificando briefings expirados");
        briefingService.expireOverdue();
    }
}
