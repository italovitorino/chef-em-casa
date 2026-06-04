package br.com.chefemcasa.api.briefings.application;

import br.com.chefemcasa.api.briefings.api.dto.CreateBriefingRequest;
import br.com.chefemcasa.api.briefings.domain.*;
import br.com.chefemcasa.api.briefings.domain.event.*;
import br.com.chefemcasa.api.briefings.domain.exception.BriefingNotFoundException;
import br.com.chefemcasa.api.briefings.domain.repository.BriefingRepository;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.negotiations.domain.Negotiation;
import br.com.chefemcasa.api.negotiations.domain.NegotiationStatus;
import br.com.chefemcasa.api.negotiations.domain.repository.NegotiationRepository;
import br.com.chefemcasa.api.shared.application.UserRoleChecker;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import br.com.chefemcasa.api.shared.domain.exception.UnauthorizedActorException;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class BriefingService {

    private static final String EXCHANGE = "chefemcasa.events";
    private static final Map<Class<?>, String> ROUTING_KEYS = Map.of(
            BriefingPublished.class,     "briefings.briefing.published",
            ChefInterestExpressed.class, "briefings.interest.expressed",
            NegotiationStarted.class,    "briefings.negotiation.started",
            BriefingClosed.class,        "briefings.briefing.closed"
    );

    private final BriefingRepository briefingRepository;
    private final NegotiationRepository negotiationRepository;
    private final UserRoleChecker userRoleChecker;
    private final RabbitTemplate rabbitTemplate;

    public BriefingService(BriefingRepository briefingRepository,
                           NegotiationRepository negotiationRepository,
                           UserRoleChecker userRoleChecker,
                           RabbitTemplate rabbitTemplate) {
        this.briefingRepository = briefingRepository;
        this.negotiationRepository = negotiationRepository;
        this.userRoleChecker = userRoleChecker;
        this.rabbitTemplate = rabbitTemplate;
    }

    @Transactional
    public Briefing publish(UUID clientId, UserRole callerRole, CreateBriefingRequest request) {
        if (callerRole != UserRole.CLIENT) throw new UnauthorizedActorException();
        var address = new Address(request.street(), request.number(), request.city(),
                request.state(), request.zipCode());
        var details = new BriefingDetails(request.eventType(), request.eventDate(),
                request.numberOfGuests(), address, request.estimatedDurationMinutes(), request.notes());
        var briefing = Briefing.open(clientId, details);
        var events = briefing.drainEvents();
        var saved = briefingRepository.save(briefing);
        publishEvents(events);
        return saved;
    }

    @Transactional
    public Briefing expressInterest(UUID briefingId, UUID chefId, UserRole callerRole, String message) {
        if (callerRole != UserRole.CHEF) throw new UnauthorizedActorException();
        var briefing = briefingRepository.findById(briefingId)
                .orElseThrow(() -> new BriefingNotFoundException(briefingId));
        briefing.expressInterest(chefId, message);
        var events = briefing.drainEvents();
        var saved = briefingRepository.save(briefing);
        publishEvents(events);
        return saved;
    }

    @Transactional
    public Negotiation startNegotiation(UUID briefingId, UUID clientId, UUID chefId) {
        var briefing = briefingRepository.findById(briefingId)
                .orElseThrow(() -> new BriefingNotFoundException(briefingId));
        if (!briefing.getClientId().equals(clientId)) throw new UnauthorizedActorException();
        var negotiation = Negotiation.open(briefingId, clientId, chefId);
        briefing.recordNegotiationStarted(chefId, negotiation.getId());
        var briefingEvents = briefing.drainEvents();
        briefingRepository.save(briefing);
        negotiationRepository.save(negotiation);
        publishEvents(briefingEvents);
        return negotiation;
    }

    @Transactional
    public Briefing close(UUID briefingId, UUID clientId) {
        var briefing = briefingRepository.findById(briefingId)
                .orElseThrow(() -> new BriefingNotFoundException(briefingId));
        if (!briefing.getClientId().equals(clientId)) throw new UnauthorizedActorException();
        return closeWithReason(briefing, BriefingCloseReason.CLIENT_CLOSED, clientId);
    }

    @Transactional
    public void closeForAcceptedProposal(UUID briefingId, UUID clientId) {
        briefingRepository.findById(briefingId).ifPresent(briefing ->
                closeWithReason(briefing, BriefingCloseReason.PROPOSAL_ACCEPTED, clientId));
    }

    @Transactional
    public void expireOverdue() {
        var overdue = briefingRepository.findByStatusAndExpiresAtBefore(BriefingStatus.OPEN, Instant.now());
        for (var briefing : overdue) {
            closeWithReason(briefing, BriefingCloseReason.EXPIRED, briefing.getClientId());
        }
    }

    public Briefing findById(UUID briefingId, UUID actorId) {
        var briefing = briefingRepository.findById(briefingId)
                .orElseThrow(() -> new BriefingNotFoundException(briefingId));
        var isClient = briefing.getClientId().equals(actorId);
        var isChef = userRoleChecker.findRoleById(actorId).map(r -> r == UserRole.CHEF).orElse(false);
        if (!isClient && !isChef) throw new UnauthorizedActorException();
        return briefing;
    }

    @Transactional(readOnly = true)
    public List<Briefing> findAll(UUID actorId, UserRole role) {
        return switch (role) {
            case CLIENT -> briefingRepository.findByClientId(actorId);
            case CHEF   -> briefingRepository.findByStatus(BriefingStatus.OPEN);
        };
    }

    private Briefing closeWithReason(Briefing briefing, BriefingCloseReason reason, UUID cancelledBy) {
        briefing.close(reason);
        var briefingEvents = briefing.drainEvents();
        var saved = briefingRepository.save(briefing);
        cancelOpenNegotiations(briefing.getId(), cancelledBy);
        publishEvents(briefingEvents);
        return saved;
    }

    private void cancelOpenNegotiations(UUID briefingId, UUID cancelledBy) {
        var openNegotiations = negotiationRepository.findByBriefingIdAndStatusIn(
                briefingId,
                List.of(NegotiationStatus.AWAITING_PROPOSAL, NegotiationStatus.PROPOSAL_SENT));
        for (var neg : openNegotiations) {
            neg.cancel(cancelledBy);
            var negEvents = neg.drainEvents();
            negotiationRepository.save(neg);
            publishEvents(negEvents);
        }
    }

    private void publishEvents(List<DomainEvent> events) {
        events.forEach(event -> {
            var key = ROUTING_KEYS.get(event.getClass());
            if (key != null) rabbitTemplate.convertAndSend(EXCHANGE, key, event);
        });
    }
}
