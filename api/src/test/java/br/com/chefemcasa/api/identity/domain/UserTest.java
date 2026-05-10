package br.com.chefemcasa.api.identity.domain;

import br.com.chefemcasa.api.identity.domain.event.UserRegistered;
import br.com.chefemcasa.api.identity.domain.model.User;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    @Test
    void register_creates_user_with_correct_fields() {
        var user = User.register("John Doe", "john@example.com", "hashed_pw", UserRole.CLIENT);

        assertNotNull(user.getId());
        assertEquals("john@example.com", user.getEmail());
        assertEquals("hashed_pw", user.getPasswordHash());
        assertEquals("John Doe", user.getName());
        assertEquals(UserRole.CLIENT, user.getRole());
        assertTrue(user.isActive());
        assertNotNull(user.getCreatedAt());
    }

    @Test
    void register_raises_user_registered_event() {
        var user = User.register("Jane Doe", "jane@example.com", "hashed_pw", UserRole.CHEF);
        var events = user.drainEvents();

        assertEquals(1, events.size());
        assertInstanceOf(UserRegistered.class, events.getFirst());
        var event = (UserRegistered) events.getFirst();
        assertEquals(user.getId(), event.userId());
        assertEquals("jane@example.com", event.email());
        assertEquals(UserRole.CHEF, event.role());
        assertNotNull(event.eventId());
        assertNotNull(event.occurredAt());
        assertEquals(1, event.version());
    }

    @Test
    void drain_events_clears_the_event_list() {
        var user = User.register("X", "x@example.com", "hashed_pw", UserRole.CLIENT);
        user.drainEvents();
        assertTrue(user.drainEvents().isEmpty());
    }

    @Test
    void equality_is_based_on_id_not_fields() {
        var user1 = User.register("A", "a@example.com", "hash", UserRole.CLIENT);
        var user2 = User.register("A", "a@example.com", "hash", UserRole.CLIENT);
        assertNotEquals(user1, user2);
    }
}
