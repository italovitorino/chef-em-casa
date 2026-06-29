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

    public static final String NOTIF_NEW_BRIEFING_QUEUE    = "chefemcasa.notifications.new-briefing";
    public static final String NOTIF_INTEREST_QUEUE        = "chefemcasa.notifications.interest-expressed";
    public static final String NOTIF_NEGOTIATION_QUEUE     = "chefemcasa.notifications.negotiation-started";
    public static final String NOTIF_PROPOSAL_SENT_QUEUE   = "chefemcasa.notifications.proposal-sent";
    public static final String NOTIF_ACCEPTED_QUEUE        = "chefemcasa.notifications.proposal-accepted";
    public static final String NOTIF_REJECTED_QUEUE        = "chefemcasa.notifications.proposal-rejected";
    public static final String NOTIF_REVISION_QUEUE        = "chefemcasa.notifications.proposal-revision";
    public static final String NOTIF_CANCELLED_QUEUE       = "chefemcasa.notifications.negotiation-cancelled";

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

    @Bean Queue notifNewBriefingQueue()  { return QueueBuilder.durable(NOTIF_NEW_BRIEFING_QUEUE).build(); }
    @Bean Queue notifInterestQueue()     { return QueueBuilder.durable(NOTIF_INTEREST_QUEUE).build(); }
    @Bean Queue notifNegotiationQueue()  { return QueueBuilder.durable(NOTIF_NEGOTIATION_QUEUE).build(); }
    @Bean Queue notifProposalSentQueue() { return QueueBuilder.durable(NOTIF_PROPOSAL_SENT_QUEUE).build(); }
    @Bean Queue notifAcceptedQueue()     { return QueueBuilder.durable(NOTIF_ACCEPTED_QUEUE).build(); }
    @Bean Queue notifRejectedQueue()     { return QueueBuilder.durable(NOTIF_REJECTED_QUEUE).build(); }
    @Bean Queue notifRevisionQueue()     { return QueueBuilder.durable(NOTIF_REVISION_QUEUE).build(); }
    @Bean Queue notifCancelledQueue()    { return QueueBuilder.durable(NOTIF_CANCELLED_QUEUE).build(); }

    @Bean
    public Binding notifNewBriefingBinding(Queue notifNewBriefingQueue,
                                           TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifNewBriefingQueue)
                .to(chefEmCasaEventsExchange).with("briefings.briefing.published");
    }

    @Bean
    public Binding notifInterestBinding(Queue notifInterestQueue,
                                        TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifInterestQueue)
                .to(chefEmCasaEventsExchange).with("briefings.interest.expressed");
    }

    @Bean
    public Binding notifNegotiationBinding(Queue notifNegotiationQueue,
                                           TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifNegotiationQueue)
                .to(chefEmCasaEventsExchange).with("briefings.negotiation.started");
    }

    @Bean
    public Binding notifProposalSentBinding(Queue notifProposalSentQueue,
                                            TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifProposalSentQueue)
                .to(chefEmCasaEventsExchange).with("negotiations.proposal.sent");
    }

    @Bean
    public Binding notifAcceptedBinding(Queue notifAcceptedQueue,
                                        TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifAcceptedQueue)
                .to(chefEmCasaEventsExchange).with("negotiations.proposal.accepted");
    }

    @Bean
    public Binding notifRejectedBinding(Queue notifRejectedQueue,
                                        TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifRejectedQueue)
                .to(chefEmCasaEventsExchange).with("negotiations.proposal.rejected");
    }

    @Bean
    public Binding notifRevisionBinding(Queue notifRevisionQueue,
                                        TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifRevisionQueue)
                .to(chefEmCasaEventsExchange).with("negotiations.proposal.revision-requested");
    }

    @Bean
    public Binding notifCancelledBinding(Queue notifCancelledQueue,
                                         TopicExchange chefEmCasaEventsExchange) {
        return BindingBuilder.bind(notifCancelledQueue)
                .to(chefEmCasaEventsExchange).with("negotiations.negotiation.cancelled");
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
