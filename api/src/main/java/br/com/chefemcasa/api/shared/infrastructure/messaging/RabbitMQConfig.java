package br.com.chefemcasa.api.shared.infrastructure.messaging;

import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.support.converter.JacksonJsonMessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RabbitMQConfig {

    public static final String EXCHANGE = "chefemcasa.events";

    public static final String WELCOME_EMAIL_QUEUE          = "chefemcasa.identity.welcome-email";
    public static final String NEW_BRIEFING_QUEUE           = "chefemcasa.briefings.new-briefing";
    public static final String RESERVATION_CONFIRMED_QUEUE  = "chefemcasa.negotiations.reservation-confirmed";

    private static final String USER_REGISTERED_KEY       = "identity.user.registered";
    private static final String BRIEFING_PUBLISHED_KEY    = "briefings.briefing.published";
    private static final String RESERVATION_CONFIRMED_KEY = "negotiations.reservation.confirmed";

    @Bean
    public TopicExchange chefEmCasaEventsExchange() {
        return new TopicExchange(EXCHANGE, true, false);
    }

    @Bean
    public Queue welcomeEmailQueue() {
        return QueueBuilder.durable(WELCOME_EMAIL_QUEUE).build();
    }

    @Bean
    public Queue newBriefingQueue() {
        return QueueBuilder.durable(NEW_BRIEFING_QUEUE).build();
    }

    @Bean
    public Queue reservationConfirmedQueue() {
        return QueueBuilder.durable(RESERVATION_CONFIRMED_QUEUE).build();
    }

    @Bean
    public Binding welcomeEmailBinding(Queue welcomeEmailQueue, TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(welcomeEmailQueue).to(chefEmCasaEventsExchange).with(USER_REGISTERED_KEY);
    }

    @Bean
    public Binding newBriefingBinding(Queue newBriefingQueue, TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(newBriefingQueue).to(chefEmCasaEventsExchange).with(BRIEFING_PUBLISHED_KEY);
    }

    @Bean
    public Binding reservationConfirmedBinding(Queue reservationConfirmedQueue,
                                               TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(reservationConfirmedQueue)
                .to(chefEmCasaEventsExchange).with(RESERVATION_CONFIRMED_KEY);
    }

    @Bean
    public JacksonJsonMessageConverter messageConverter() {
        return new JacksonJsonMessageConverter();
    }

    @Bean
    public RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory,
                                         JacksonJsonMessageConverter converter) {
        var template = new RabbitTemplate(connectionFactory);
        template.setMessageConverter(converter);
        return template;
    }
}
