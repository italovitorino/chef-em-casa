package br.com.chefemcasa.api.negotiations.application;

import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.negotiations.api.dto.SubmitProposalRequest;
import br.com.chefemcasa.api.negotiations.domain.Negotiation;
import br.com.chefemcasa.api.negotiations.domain.event.*;
import br.com.chefemcasa.api.negotiations.domain.exception.NegotiationNotFoundException;
import br.com.chefemcasa.api.negotiations.domain.repository.NegotiationRepository;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import br.com.chefemcasa.api.shared.domain.exception.UnauthorizedActorException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class NegotiationService {

    private static final String EXCHANGE = "chefemcasa.events";
    private static final Map<Class<?>, String> ROUTING_KEYS = Map.of(
            ProposalSent.class,              "negotiations.proposal.sent",
            ProposalAccepted.class,          "negotiations.proposal.accepted",
            ProposalRejected.class,          "negotiations.proposal.rejected",
            ProposalRevisionRequested.class, "negotiations.proposal.revision-requested",
            ReservationConfirmed.class,      "negotiations.reservation.confirmed",
            NegotiationCancelled.class,      "negotiations.negotiation.cancelled",
            ServiceCompleted.class,          "negotiations.service.completed"
    );

    private final NegotiationRepository negotiationRepository;
    private final RabbitTemplate rabbitTemplate;

    public NegotiationService(NegotiationRepository negotiationRepository,
                              RabbitTemplate rabbitTemplate) {
        this.negotiationRepository = negotiationRepository;
        this.rabbitTemplate = rabbitTemplate;
    }

    @Transactional
    public Negotiation submitProposal(UUID negotiationId, UUID chefId, SubmitProposalRequest request) {
        var negotiation = negotiationRepository.findById(negotiationId)
                .orElseThrow(() -> new NegotiationNotFoundException(negotiationId));
        if (!negotiation.getChefId().equals(chefId)) throw new UnauthorizedActorException();
        negotiation.submitProposal(request.totalAmount(), request.serviceDescription(),
                request.validUntil(), request.notes());
        return saveAndPublish(negotiation);
    }

    @Transactional
    public Negotiation acceptProposal(UUID negotiationId, UUID clientId) {
        var negotiation = findOwnedByClient(negotiationId, clientId);
        negotiation.acceptProposal();
        return saveAndPublish(negotiation);
    }

    @Transactional
    public Negotiation rejectProposal(UUID negotiationId, UUID clientId) {
        var negotiation = findOwnedByClient(negotiationId, clientId);
        negotiation.rejectProposal();
        return saveAndPublish(negotiation);
    }

    @Transactional
    public Negotiation requestRevision(UUID negotiationId, UUID clientId) {
        var negotiation = findOwnedByClient(negotiationId, clientId);
        negotiation.requestRevision();
        return saveAndPublish(negotiation);
    }

    @Transactional
    public Negotiation completeService(UUID negotiationId, UUID actorId) {
        var negotiation = negotiationRepository.findById(negotiationId)
                .orElseThrow(() -> new NegotiationNotFoundException(negotiationId));
        if (!negotiation.getClientId().equals(actorId) && !negotiation.getChefId().equals(actorId))
            throw new UnauthorizedActorException();
        negotiation.completeService();
        return saveAndPublish(negotiation);
    }

    @Transactional
    public Negotiation cancel(UUID negotiationId, UUID actorId) {
        var negotiation = negotiationRepository.findById(negotiationId)
                .orElseThrow(() -> new NegotiationNotFoundException(negotiationId));
        if (!negotiation.getClientId().equals(actorId) && !negotiation.getChefId().equals(actorId))
            throw new UnauthorizedActorException();
        negotiation.cancel(actorId);
        return saveAndPublish(negotiation);
    }

    public Negotiation findById(UUID negotiationId, UUID actorId) {
        var negotiation = negotiationRepository.findById(negotiationId)
                .orElseThrow(() -> new NegotiationNotFoundException(negotiationId));
        if (!negotiation.getClientId().equals(actorId) && !negotiation.getChefId().equals(actorId))
            throw new UnauthorizedActorException();
        return negotiation;
    }

    @Transactional(readOnly = true)
    public List<Negotiation> findByBriefingId(UUID briefingId, UUID clientId) {
        var negotiations = negotiationRepository.findByBriefingId(briefingId);
        if (negotiations.stream().anyMatch(n -> !n.getClientId().equals(clientId)))
            throw new UnauthorizedActorException();
        return negotiations;
    }

    @Transactional(readOnly = true)
    public List<Negotiation> findAll(UUID actorId, UserRole role) {
        return switch (role) {
            case CLIENT -> negotiationRepository.findByClientId(actorId);
            case CHEF   -> negotiationRepository.findByChefId(actorId);
        };
    }

    private Negotiation findOwnedByClient(UUID negotiationId, UUID clientId) {
        var negotiation = negotiationRepository.findById(negotiationId)
                .orElseThrow(() -> new NegotiationNotFoundException(negotiationId));
        if (!negotiation.getClientId().equals(clientId)) throw new UnauthorizedActorException();
        return negotiation;
    }

    private Negotiation saveAndPublish(Negotiation negotiation) {
        var events = negotiation.drainEvents();
        var saved = negotiationRepository.save(negotiation);
        publishEvents(events);
        return saved;
    }

    void publishEvents(List<DomainEvent> events) {
        events.forEach(event -> {
            var key = ROUTING_KEYS.get(event.getClass());
            if (key != null) rabbitTemplate.convertAndSend(EXCHANGE, key, event);
        });
    }
}
