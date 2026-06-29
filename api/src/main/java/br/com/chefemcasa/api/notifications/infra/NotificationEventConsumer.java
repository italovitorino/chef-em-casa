package br.com.chefemcasa.api.notifications.infra;

import br.com.chefemcasa.api.briefings.domain.event.BriefingPublished;
import br.com.chefemcasa.api.briefings.domain.event.ChefInterestExpressed;
import br.com.chefemcasa.api.briefings.domain.event.NegotiationStarted;
import br.com.chefemcasa.api.briefings.domain.repository.BriefingRepository;
import br.com.chefemcasa.api.identity.domain.repository.UserRepository;
import br.com.chefemcasa.api.negotiations.domain.event.NegotiationCancelled;
import br.com.chefemcasa.api.negotiations.domain.event.ProposalAccepted;
import br.com.chefemcasa.api.negotiations.domain.event.ProposalRejected;
import br.com.chefemcasa.api.negotiations.domain.event.ProposalRevisionRequested;
import br.com.chefemcasa.api.negotiations.domain.event.ProposalSent;
import br.com.chefemcasa.api.notifications.application.NotificationService;
import br.com.chefemcasa.api.notifications.domain.NotificationType;
import br.com.chefemcasa.api.shared.infrastructure.messaging.RabbitMQConfig;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class NotificationEventConsumer {

    private final NotificationService notificationService;
    private final UserRepository userRepository;
    private final BriefingRepository briefingRepository;

    public NotificationEventConsumer(NotificationService notificationService,
                                     UserRepository userRepository,
                                     BriefingRepository briefingRepository) {
        this.notificationService = notificationService;
        this.userRepository = userRepository;
        this.briefingRepository = briefingRepository;
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_NEW_BRIEFING_QUEUE)
    public void onBriefingPublished(BriefingPublished event) {
        userRepository.findAllChefIds().forEach(chefId ->
                notificationService.createFor(
                        chefId, NotificationType.NEW_BRIEFING,
                        "Novo pedido disponível",
                        "Um cliente publicou um novo briefing. Expresse seu interesse!",
                        event.briefingId()));
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_INTEREST_QUEUE)
    public void onInterestExpressed(ChefInterestExpressed event) {
        briefingRepository.findById(event.briefingId()).ifPresent(briefing ->
                notificationService.createFor(
                        briefing.getClientId(), NotificationType.INTEREST_EXPRESSED,
                        "Chef interessado no seu briefing",
                        "Um chef expressou interesse no seu pedido. Inicie uma negociação!",
                        event.briefingId()));
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_NEGOTIATION_QUEUE)
    public void onNegotiationStarted(NegotiationStarted event) {
        notificationService.createFor(
                event.chefId(), NotificationType.NEGOTIATION_STARTED,
                "Cliente iniciou uma negociação",
                "Um cliente quer negociar com você. Envie sua proposta!",
                event.negotiationId());
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_PROPOSAL_SENT_QUEUE)
    public void onProposalSent(ProposalSent event) {
        notificationService.createFor(
                event.clientId(), NotificationType.PROPOSAL_SENT,
                "Nova proposta recebida",
                "O chef enviou uma proposta para você. Confira os detalhes!",
                event.negotiationId());
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_ACCEPTED_QUEUE)
    public void onProposalAccepted(ProposalAccepted event) {
        notificationService.createFor(
                event.chefId(), NotificationType.PROPOSAL_ACCEPTED,
                "Proposta aceita!",
                "Parabéns! Sua proposta foi aceita pelo cliente.",
                event.negotiationId());
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_REJECTED_QUEUE)
    public void onProposalRejected(ProposalRejected event) {
        notificationService.createFor(
                event.chefId(), NotificationType.PROPOSAL_REJECTED,
                "Proposta recusada",
                "O cliente recusou sua proposta.",
                event.negotiationId());
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_REVISION_QUEUE)
    public void onRevisionRequested(ProposalRevisionRequested event) {
        notificationService.createFor(
                event.chefId(), NotificationType.PROPOSAL_REVISION_REQUESTED,
                "Revisão solicitada",
                "O cliente quer revisar a proposta. Envie uma nova versão.",
                event.negotiationId());
    }

    @RabbitListener(queues = RabbitMQConfig.NOTIF_CANCELLED_QUEUE)
    public void onNegotiationCancelled(NegotiationCancelled event) {
        notificationService.createFor(
                event.clientId(), NotificationType.NEGOTIATION_CANCELLED,
                "Negociação cancelada", "A negociação foi cancelada.", event.negotiationId());
        notificationService.createFor(
                event.chefId(), NotificationType.NEGOTIATION_CANCELLED,
                "Negociação cancelada", "A negociação foi cancelada.", event.negotiationId());
    }
}
