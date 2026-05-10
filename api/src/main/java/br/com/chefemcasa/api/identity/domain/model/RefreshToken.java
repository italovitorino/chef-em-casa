package br.com.chefemcasa.api.identity.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "refresh_tokens", schema = "identity")
public class RefreshToken {

    @Id
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(nullable = false, unique = true)
    private UUID token;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(nullable = false)
    private boolean revoked;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected RefreshToken() {}

    public static RefreshToken issue(UUID userId, Duration validity) {
        var rt = new RefreshToken();
        rt.id = UUID.randomUUID();
        rt.userId = userId;
        rt.token = UUID.randomUUID();
        rt.createdAt = Instant.now();
        rt.expiresAt = rt.createdAt.plus(validity);
        rt.revoked = false;
        return rt;
    }

    public boolean isValid() {
        return !revoked && Instant.now().isBefore(expiresAt);
    }

    public void revoke() { this.revoked = true; }

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public UUID getToken() { return token; }
    public Instant getExpiresAt() { return expiresAt; }
    public boolean isRevoked() { return revoked; }
    public Instant getCreatedAt() { return createdAt; }
}
