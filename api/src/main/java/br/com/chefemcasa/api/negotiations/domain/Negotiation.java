package br.com.chefemcasa.api.negotiations.domain;

import br.com.chefemcasa.api.negotiations.domain.event.*;
import br.com.chefemcasa.api.negotiations.domain.exception.InvalidTransitionException;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "negotiations", schema = "negotiations")
public class Negotiation {

    @Id
    private UUID id;

    @Column(name = "briefing_id", nullable = false)
    private UUID briefingId;

    @Column(name = "client_id", nullable = false)
    private UUID clientId;

    @Column(name = "chef_id", nullable = false)
    private UUID chefId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NegotiationStatus status;

    @OneToMany(mappedBy = "negotiation", cascade = CascadeType.ALL,
               orphanRemoval = true, fetch = FetchType.EAGER)
    private List<Proposal> proposals = new ArrayList<>();

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Transient
    private final List<DomainEvent> events = new ArrayList<>();

    protected Negotiation() {}

    public static Negotiation open(UUID briefingId, UUID clientId, UUID chefId) {
        var n = new Negotiation();
        n.id = UUID.randomUUID();
        n.briefingId = briefingId;
        n.clientId = clientId;
        n.chefId = chefId;
        n.status = NegotiationStatus.AWAITING_PROPOSAL;
        n.createdAt = Instant.now();
        n.updatedAt = n.createdAt;
        return n;
    }

    public void submitProposal(BigDecimal totalAmount, String serviceDescription,
                               LocalDate validUntil, String notes) {
        if (status != NegotiationStatus.AWAITING_PROPOSAL)
            throw new InvalidTransitionException("submitProposal", status);
        proposals.add(Proposal.create(this, totalAmount, serviceDescription, validUntil, notes));
        status = NegotiationStatus.PROPOSAL_SENT;
        updatedAt = Instant.now();
        events.add(new ProposalSent(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId, totalAmount));
    }

    public void acceptProposal() {
        if (status != NegotiationStatus.PROPOSAL_SENT)
            throw new InvalidTransitionException("acceptProposal", status);
        var current = getCurrentProposal();
        if (current == null) throw new IllegalStateException("Nenhuma proposta atual para aceitar");
        status = NegotiationStatus.RESERVATION_CONFIRMED;
        updatedAt = Instant.now();
        events.add(new ProposalAccepted(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
        events.add(new ReservationConfirmed(UUID.randomUUID(), updatedAt, 1,
                id, briefingId, clientId, chefId, current.getTotalAmount()));
    }

    public void rejectProposal() {
        if (status != NegotiationStatus.PROPOSAL_SENT)
            throw new InvalidTransitionException("rejectProposal", status);
        getCurrentProposal().setCurrent(false);
        status = NegotiationStatus.AWAITING_PROPOSAL;
        updatedAt = Instant.now();
        events.add(new ProposalRejected(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
    }

    public void requestRevision() {
        if (status != NegotiationStatus.PROPOSAL_SENT)
            throw new InvalidTransitionException("requestRevision", status);
        getCurrentProposal().setCurrent(false);
        status = NegotiationStatus.AWAITING_PROPOSAL;
        updatedAt = Instant.now();
        events.add(new ProposalRevisionRequested(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
    }

    public void completeService() {
        if (status != NegotiationStatus.RESERVATION_CONFIRMED)
            throw new InvalidTransitionException("completeService", status);
        status = NegotiationStatus.SERVICE_COMPLETED;
        updatedAt = Instant.now();
        events.add(new ServiceCompleted(UUID.randomUUID(), updatedAt, 1, id, clientId, chefId));
    }

    public void cancel(UUID cancelledBy) {
        if (status == NegotiationStatus.SERVICE_COMPLETED || status == NegotiationStatus.CANCELLED)
            throw new InvalidTransitionException("cancel", status);
        status = NegotiationStatus.CANCELLED;
        updatedAt = Instant.now();
        events.add(new NegotiationCancelled(UUID.randomUUID(), updatedAt, 1,
                id, clientId, chefId, cancelledBy));
    }

    public Proposal getCurrentProposal() {
        return proposals.stream().filter(Proposal::isCurrent).findFirst().orElse(null);
    }

    public List<Proposal> getProposalHistory() {
        return proposals.stream().filter(p -> !p.isCurrent()).toList();
    }

    public List<DomainEvent> drainEvents() {
        var snapshot = List.copyOf(events);
        events.clear();
        return snapshot;
    }

    public UUID getId()                  { return id; }
    public UUID getBriefingId()          { return briefingId; }
    public UUID getClientId()            { return clientId; }
    public UUID getChefId()              { return chefId; }
    public NegotiationStatus getStatus() { return status; }
    public Instant getCreatedAt()        { return createdAt; }
    public Instant getUpdatedAt()        { return updatedAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Negotiation n)) return false;
        return id != null && id.equals(n.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
