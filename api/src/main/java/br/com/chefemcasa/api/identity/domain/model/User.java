package br.com.chefemcasa.api.identity.domain.model;

import br.com.chefemcasa.api.identity.domain.event.UserRegistered;
import br.com.chefemcasa.api.shared.domain.event.DomainEvent;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users", schema = "identity")
public class User {

    @Id
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role;

    @Column(nullable = false)
    private boolean active;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Transient
    private final List<DomainEvent> domainEvents = new ArrayList<>();

    protected User() {}

    private User(UUID id, String name, String email, String passwordHash, UserRole role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.role = role;
        this.active = true;
        this.createdAt = Instant.now();
    }

    public static User register(String name, String email, String passwordHash, UserRole role) {
        var user = new User(UUID.randomUUID(), name, email, passwordHash, role);
        user.domainEvents.add(new UserRegistered(
                UUID.randomUUID(), user.createdAt, 1, user.id, user.email, user.role));
        return user;
    }

    public List<DomainEvent> drainEvents() {
        var snapshot = List.copyOf(domainEvents);
        domainEvents.clear();
        return snapshot;
    }

    public UUID getId() { return id; }
    public String getEmail() { return email; }
    public String getPasswordHash() { return passwordHash; }
    public String getName() { return name; }
    public UserRole getRole() { return role; }
    public boolean isActive() { return active; }
    public Instant getCreatedAt() { return createdAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User u)) return false;
        return id != null && id.equals(u.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
