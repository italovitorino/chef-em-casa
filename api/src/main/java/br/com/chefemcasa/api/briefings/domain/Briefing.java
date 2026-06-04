package br.com.chefemcasa.api.briefings.domain;

import br.com.chefemcasa.api.briefings.domain.event.*;
import br.com.chefemcasa.api.briefings.domain.exception.ChefHasNotExpressedInterestException;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "briefings", schema = "briefings")
public class Briefing {

    @Id
    private UUID id;

    @Column(name = "client_id", nullable = false)
    private UUID clientId;

    @Embedded
    @AttributeOverrides({
            @AttributeOverride(name = "location.street",  column = @Column(name = "street")),
            @AttributeOverride(name = "location.number",  column = @Column(name = "number")),
            @AttributeOverride(name = "location.city",    column = @Column(name = "city")),
            @AttributeOverride(name = "location.state",   column = @Column(name = "state")),
            @AttributeOverride(name = "location.zipCode", column = @Column(name = "zip_code"))
    })
    private BriefingDetails details;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BriefingStatus status;

    @OneToMany(mappedBy = "briefing", cascade = CascadeType.ALL,
               orphanRemoval = true, fetch = FetchType.EAGER)
    private List<ChefInterest> interests = new ArrayList<>();

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "closed_at")
    private Instant closedAt;

    @Transient
    private final List<DomainEvent> events = new ArrayList<>();

    protected Briefing() {}

    public static Briefing open(UUID clientId, BriefingDetails details) {
        var b = new Briefing();
        b.id = UUID.randomUUID();
        b.clientId = clientId;
        b.details = details;
        b.status = BriefingStatus.OPEN;
        b.createdAt = Instant.now();
        b.expiresAt = b.createdAt.plusSeconds(72 * 3600);
        b.events.add(new BriefingPublished(UUID.randomUUID(), b.createdAt, 1, b.id, b.clientId));
        return b;
    }

    public void expressInterest(UUID chefId, String message) {
        if (status != BriefingStatus.OPEN)
            throw new IllegalStateException("Não é possível expressar interesse em briefing encerrado");
        if (hasInterestFrom(chefId))
            throw new IllegalStateException("Chef já expressou interesse neste briefing");
        interests.add(ChefInterest.create(this, chefId, message));
        events.add(new ChefInterestExpressed(UUID.randomUUID(), Instant.now(), 1, id, chefId));
    }

    public void recordNegotiationStarted(UUID chefId, UUID negotiationId) {
        if (status != BriefingStatus.OPEN)
            throw new IllegalStateException("Briefing não está aberto para negociações");
        if (!hasInterestFrom(chefId))
            throw new ChefHasNotExpressedInterestException();
        events.add(new NegotiationStarted(UUID.randomUUID(), Instant.now(), 1,
                id, negotiationId, clientId, chefId));
    }

    public void close(BriefingCloseReason reason) {
        if (status == BriefingStatus.CLOSED) return;
        status = BriefingStatus.CLOSED;
        closedAt = Instant.now();
        events.add(new BriefingClosed(UUID.randomUUID(), closedAt, 1, id, reason));
    }

    public boolean hasInterestFrom(UUID chefId) {
        return interests.stream().anyMatch(i -> i.getChefId().equals(chefId));
    }

    public List<DomainEvent> drainEvents() {
        var snapshot = List.copyOf(events);
        events.clear();
        return snapshot;
    }

    public UUID getId()                      { return id; }
    public UUID getClientId()                { return clientId; }
    public BriefingDetails getDetails()      { return details; }
    public BriefingStatus getStatus()        { return status; }
    public List<ChefInterest> getInterests() { return List.copyOf(interests); }
    public Instant getCreatedAt()            { return createdAt; }
    public Instant getExpiresAt()            { return expiresAt; }
    public Instant getClosedAt()             { return closedAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Briefing b)) return false;
        return id != null && id.equals(b.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
