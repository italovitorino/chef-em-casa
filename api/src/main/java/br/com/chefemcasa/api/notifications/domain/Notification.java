package br.com.chefemcasa.api.notifications.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "notifications", schema = "notifications")
public class Notification {

    @Id
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(name = "related_id")
    private UUID relatedId;

    @Column(name = "is_read", nullable = false)
    private boolean read = false;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected Notification() {}

    public static Notification create(UUID userId, NotificationType type,
                                      String title, String body, UUID relatedId) {
        var n = new Notification();
        n.id = UUID.randomUUID();
        n.userId = userId;
        n.type = type;
        n.title = title;
        n.body = body;
        n.relatedId = relatedId;
        n.createdAt = Instant.now();
        return n;
    }

    public void markRead() { this.read = true; }

    public UUID getId()               { return id; }
    public UUID getUserId()           { return userId; }
    public NotificationType getType() { return type; }
    public String getTitle()          { return title; }
    public String getBody()           { return body; }
    public UUID getRelatedId()        { return relatedId; }
    public boolean isRead()           { return read; }
    public Instant getCreatedAt()     { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Notification n)) return false;
        return id != null && id.equals(n.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
