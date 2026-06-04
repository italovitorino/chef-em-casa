package br.com.chefemcasa.api.negotiations.application;

import br.com.chefemcasa.api.briefings.application.BriefingService;
import br.com.chefemcasa.api.negotiations.domain.event.ReservationConfirmed;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class ReservationConfirmedHandler {

    private static final Logger log = LoggerFactory.getLogger(ReservationConfirmedHandler.class);

    private final BriefingService briefingService;

    public ReservationConfirmedHandler(BriefingService briefingService) {
        this.briefingService = briefingService;
    }

    @RabbitListener(queues = "chefemcasa.negotiations.reservation-confirmed")
    public void handle(ReservationConfirmed event) {
        log.info("[RESERVATION-CONFIRMED] Fechando briefing: briefingId={}", event.briefingId());
        briefingService.closeForAcceptedProposal(event.briefingId(), event.clientId());
    }
}
