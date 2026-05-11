package br.com.chefemcasa.api.solicitations.domain.model;

import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import br.com.chefemcasa.api.solicitations.domain.event.*;
import br.com.chefemcasa.api.solicitations.domain.exception.InvalidTransitionException;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "solicitations", schema = "solicitations")
public class Solicitation {

    @Id
    private UUID id;

    @Column(name = "client_id", nullable = false)
    private UUID clientId;

    @Column(name = "chef_id", nullable = false)
    private UUID chefId;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "location.street",  column = @Column(name = "street")),
            @AttributeOverride(name = "location.number",  column = @Column(name = "number")),
            @AttributeOverride(name = "location.city",    column = @Column(name = "city")),
            @AttributeOverride(name = "location.state",   column = @Column(name = "state")),
            @AttributeOverride(name = "location.zipCode", column = @Column(name = "zip_code"))
    })
    private Briefing briefing;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SolicitationStatus status;

    @OneToMany(mappedBy = "solicitation", cascade = CascadeType.ALL,
               orphanRemoval = true, fetch = FetchType.EAGER)
    private List<Proposal> proposals = new ArrayList<>();

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Transient
    private final List<DomainEvent> events = new ArrayList<>();

    protected Solicitation() {}

    public static Solicitation open(UUID clientId, UUID chefId, Briefing briefing) {
        var s = new Solicitation();
        s.id = UUID.randomUUID();
        s.clientId = clientId;
        s.chefId = chefId;
        s.briefing = briefing;
        s.status = SolicitationStatus.AWAITING_PROPOSAL;
        s.createdAt = Instant.now();
        s.updatedAt = s.createdAt;
        s.events.add(new BriefingSubmitted(UUID.randomUUID(), s.createdAt, 1,
                s.id, s.clientId, s.chefId));
        return s;
    }

    public void submitProposal(java.math.BigDecimal totalAmount, String serviceDescription,
                               java.time.LocalDate validUntil, String notes) {
        if (status != SolicitationStatus.AWAITING_PROPOSAL) {
            throw new InvalidTransitionException("submitProposal", status);
        }
        proposals.add(Proposal.create(this, totalAmount, serviceDescription, validUntil, notes));
        status = SolicitationStatus.PROPOSAL_SENT;
        updatedAt = Instant.now();
        events.add(new ProposalSent(UUID.randomUUID(), updatedAt, 1,
                id, clientId, chefId, totalAmount));
    }

    public void acceptProposal() {
        if (status != SolicitationStatus.PROPOSAL_SENT) {
            throw new InvalidTransitionException("acceptProposal", status);
        }
        var current = getCurrentProposal();
        if (current == null) {
            throw new IllegalStateException("Nenhuma proposta atual para aceitar");
        }
        status = SolicitationStatus.RESERVATION_CONFIRMED;
        updatedAt = Instant.now();
        events.add(new ProposalAccepted(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
        events.add(new ReservationConfirmed(UUID.randomUUID(), updatedAt, 1,
                id, clientId, chefId, current.getTotalAmount()));
    }

    public void rejectProposal() {
        if (status != SolicitationStatus.PROPOSAL_SENT) {
            throw new InvalidTransitionException("rejectProposal", status);
        }
        getCurrentProposal().setCurrent(false);
        status = SolicitationStatus.AWAITING_PROPOSAL;
        updatedAt = Instant.now();
        events.add(new ProposalRejected(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
    }

    public void requestRevision() {
        if (status != SolicitationStatus.PROPOSAL_SENT) {
            throw new InvalidTransitionException("requestRevision", status);
        }
        getCurrentProposal().setCurrent(false);
        status = SolicitationStatus.AWAITING_PROPOSAL;
        updatedAt = Instant.now();
        events.add(new ProposalRevisionRequested(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
    }

    public void completeService() {
        if (status != SolicitationStatus.RESERVATION_CONFIRMED) {
            throw new InvalidTransitionException("completeService", status);
        }
        status = SolicitationStatus.SERVICE_COMPLETED;
        updatedAt = Instant.now();
        events.add(new ServiceCompleted(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
    }

    public void cancel(UUID cancelledBy) {
        if (status == SolicitationStatus.SERVICE_COMPLETED
                || status == SolicitationStatus.CANCELLED) {
            throw new InvalidTransitionException("cancel", status);
        }
        status = SolicitationStatus.CANCELLED;
        updatedAt = Instant.now();
        events.add(new SolicitationCancelled(UUID.randomUUID(), updatedAt, 1,
                id, clientId, chefId, cancelledBy));
    }

    public List<DomainEvent> drainEvents() {
        var snapshot = List.copyOf(events);
        events.clear();
        return snapshot;
    }

    public Proposal getCurrentProposal() {
        return proposals.stream().filter(Proposal::isCurrent).findFirst().orElse(null);
    }

    public List<Proposal> getProposalHistory() {
        return proposals.stream().filter(p -> !p.isCurrent()).toList();
    }

    public UUID getId()                  { return id; }
    public UUID getClientId()            { return clientId; }
    public UUID getChefId()              { return chefId; }
    public Briefing getBriefing()        { return briefing; }
    public SolicitationStatus getStatus(){ return status; }
    public Instant getCreatedAt()        { return createdAt; }
    public Instant getUpdatedAt()        { return updatedAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Solicitation s)) return false;
        return id != null && id.equals(s.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
