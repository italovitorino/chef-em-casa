package br.com.chefemcasa.api.solicitations.infrastructure.messaging;

import br.com.chefemcasa.api.solicitations.domain.event.BriefingSubmitted;
import br.com.chefemcasa.api.shared.infrastructure.messaging.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class NewSolicitationConsumer {

    private static final Logger log = LoggerFactory.getLogger(NewSolicitationConsumer.class);

    @RabbitListener(queues = RabbitMQConfig.NEW_SOLICITATION_QUEUE)
    public void handleBriefingSubmitted(BriefingSubmitted event) {
        log.info("[NEW-SOLICITATION] Nova solicitação recebida: solicitationId={}, clientId={}, chefId={}",
                event.solicitationId(), event.clientId(), event.chefId());
    }
}
