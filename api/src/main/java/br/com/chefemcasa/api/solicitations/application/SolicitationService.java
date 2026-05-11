package br.com.chefemcasa.api.solicitations.application;

import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import br.com.chefemcasa.api.solicitations.api.dto.CreateSolicitationRequest;
import br.com.chefemcasa.api.solicitations.api.dto.SubmitProposalRequest;
import br.com.chefemcasa.api.solicitations.domain.event.*;
import br.com.chefemcasa.api.solicitations.domain.exception.SolicitationNotFoundException;
import br.com.chefemcasa.api.solicitations.domain.exception.UnauthorizedActorException;
import br.com.chefemcasa.api.solicitations.domain.model.*;
import br.com.chefemcasa.api.solicitations.domain.repository.SolicitationRepository;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class SolicitationService {

    private static final String EVENTS_EXCHANGE = "chefemcasa.events";
    private static final Map<Class<?>, String> ROUTING_KEYS = Map.of(
            BriefingSubmitted.class,         "solicitations.briefing.submitted",
            ProposalSent.class,              "solicitations.proposal.sent",
            ProposalAccepted.class,          "solicitations.proposal.accepted",
            ProposalRejected.class,          "solicitations.proposal.rejected",
            ProposalRevisionRequested.class, "solicitations.proposal.revision-requested",
            ReservationConfirmed.class,      "solicitations.reservation.confirmed",
            SolicitationCancelled.class,     "solicitations.solicitation.cancelled",
            ServiceCompleted.class,          "solicitations.service.completed"
    );

    private final SolicitationRepository solicitationRepository;
    private final RabbitTemplate rabbitTemplate;

    public SolicitationService(SolicitationRepository solicitationRepository,
                                RabbitTemplate rabbitTemplate) {
        this.solicitationRepository = solicitationRepository;
        this.rabbitTemplate = rabbitTemplate;
    }

    @Transactional
    public Solicitation createSolicitation(UUID clientId, CreateSolicitationRequest request) {
        var address = new Address(request.street(), request.number(), request.city(),
                request.state(), request.zipCode());
        var briefing = new Briefing(request.eventType(), request.eventDate(),
                request.numberOfGuests(), address, request.estimatedDurationMinutes(), request.notes());
        var solicitation = Solicitation.open(clientId, request.chefId(), briefing);
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    @Transactional
    public Solicitation submitProposal(UUID solicitationId, UUID chefId, SubmitProposalRequest request) {
        var solicitation = solicitationRepository.findById(solicitationId)
                .orElseThrow(() -> new SolicitationNotFoundException(solicitationId));
        if (!solicitation.getChefId().equals(chefId)) throw new UnauthorizedActorException();
        solicitation.submitProposal(request.totalAmount(), request.serviceDescription(),
                request.validUntil(), request.notes());
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    @Transactional
    public Solicitation acceptProposal(UUID solicitationId, UUID clientId) {
        var solicitation = findOwnedByClient(solicitationId, clientId);
        solicitation.acceptProposal();
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    @Transactional
    public Solicitation rejectProposal(UUID solicitationId, UUID clientId) {
        var solicitation = findOwnedByClient(solicitationId, clientId);
        solicitation.rejectProposal();
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    @Transactional
    public Solicitation requestRevision(UUID solicitationId, UUID clientId) {
        var solicitation = findOwnedByClient(solicitationId, clientId);
        solicitation.requestRevision();
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    @Transactional
    public Solicitation completeService(UUID solicitationId, UUID clientId) {
        var solicitation = findOwnedByClient(solicitationId, clientId);
        solicitation.completeService();
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    @Transactional
    public Solicitation cancel(UUID solicitationId, UUID actorId) {
        var solicitation = solicitationRepository.findById(solicitationId)
                .orElseThrow(() -> new SolicitationNotFoundException(solicitationId));
        if (!solicitation.getClientId().equals(actorId) && !solicitation.getChefId().equals(actorId)) {
            throw new UnauthorizedActorException();
        }
        solicitation.cancel(actorId);
        var saved = solicitationRepository.save(solicitation);
        publishEvents(saved.drainEvents());
        return saved;
    }

    public Solicitation findById(UUID solicitationId, UUID actorId) {
        var solicitation = solicitationRepository.findById(solicitationId)
                .orElseThrow(() -> new SolicitationNotFoundException(solicitationId));
        if (!solicitation.getClientId().equals(actorId) && !solicitation.getChefId().equals(actorId)) {
            throw new UnauthorizedActorException();
        }
        return solicitation;
    }

    public List<Solicitation> findAll(UUID actorId, UserRole role) {
        return switch (role) {
            case CLIENT -> solicitationRepository.findByClientId(actorId);
            case CHEF   -> solicitationRepository.findByChefId(actorId);
        };
    }

    private Solicitation findOwnedByClient(UUID solicitationId, UUID clientId) {
        var solicitation = solicitationRepository.findById(solicitationId)
                .orElseThrow(() -> new SolicitationNotFoundException(solicitationId));
        if (!solicitation.getClientId().equals(clientId)) throw new UnauthorizedActorException();
        return solicitation;
    }

    private void publishEvents(List<DomainEvent> events) {
        events.forEach(event -> {
            var key = ROUTING_KEYS.get(event.getClass());
            if (key == null) throw new IllegalStateException("Sem routing key para: " + event.getClass());
            rabbitTemplate.convertAndSend(EVENTS_EXCHANGE, key, event);
        });
    }
}
