package br.com.chefemcasa.api.briefings.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "chef_interests", schema = "briefings")
public class ChefInterest {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "briefing_id", nullable = false)
    private Briefing briefing;

    @Column(name = "chef_id", nullable = false)
    private UUID chefId;

    @Column(name = "expressed_at", nullable = false)
    private Instant expressedAt;

    @Column(columnDefinition = "TEXT")
    private String message;

    protected ChefInterest() {}

    static ChefInterest create(Briefing briefing, UUID chefId, String message) {
        var i = new ChefInterest();
        i.id = UUID.randomUUID();
        i.briefing = briefing;
        i.chefId = chefId;
        i.expressedAt = Instant.now();
        i.message = message;
        return i;
    }

    public UUID getId()             { return id; }
    public UUID getChefId()         { return chefId; }
    public Instant getExpressedAt() { return expressedAt; }
    public String getMessage()      { return message; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ChefInterest c)) return false;
        return id != null && id.equals(c.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
