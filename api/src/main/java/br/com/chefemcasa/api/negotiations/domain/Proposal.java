package br.com.chefemcasa.api.negotiations.domain;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "proposals", schema = "negotiations")
public class Proposal {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "negotiation_id", nullable = false)
    private Negotiation negotiation;

    @Column(name = "total_amount", nullable = false)
    private BigDecimal totalAmount;

    @Column(name = "service_description", nullable = false, columnDefinition = "TEXT")
    private String serviceDescription;

    @Column(name = "valid_until", nullable = false)
    private LocalDate validUntil;

    private String notes;

    @Column(name = "sent_at", nullable = false)
    private Instant sentAt;

    @Column(name = "is_current", nullable = false)
    private boolean current;

    protected Proposal() {}

    static Proposal create(Negotiation negotiation, BigDecimal totalAmount,
                           String serviceDescription, LocalDate validUntil, String notes) {
        var p = new Proposal();
        p.id = UUID.randomUUID();
        p.negotiation = negotiation;
        p.totalAmount = totalAmount;
        p.serviceDescription = serviceDescription;
        p.validUntil = validUntil;
        p.notes = notes;
        p.sentAt = Instant.now();
        p.current = true;
        return p;
    }

    void setCurrent(boolean current) { this.current = current; }

    public UUID getId()                   { return id; }
    public BigDecimal getTotalAmount()    { return totalAmount; }
    public String getServiceDescription() { return serviceDescription; }
    public LocalDate getValidUntil()      { return validUntil; }
    public String getNotes()              { return notes; }
    public Instant getSentAt()            { return sentAt; }
    public boolean isCurrent()            { return current; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Proposal p)) return false;
        return id != null && id.equals(p.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
