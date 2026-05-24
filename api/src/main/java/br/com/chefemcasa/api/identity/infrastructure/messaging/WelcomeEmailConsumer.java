package br.com.chefemcasa.api.identity.infrastructure.messaging;

import br.com.chefemcasa.api.identity.domain.event.UserRegistered;
import br.com.chefemcasa.api.shared.infrastructure.messaging.RabbitMQConfig;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class WelcomeEmailConsumer {

    private static final Logger log = LoggerFactory.getLogger(WelcomeEmailConsumer.class);

    @RabbitListener(queues = RabbitMQConfig.WELCOME_EMAIL_QUEUE)
    public void handleUserRegistered(UserRegistered event) {
        log.info("[WELCOME-EMAIL] Enviando boas-vindas para {} (userId={}, role={})",
                event.email(), event.userId(), event.role());
    }
}
