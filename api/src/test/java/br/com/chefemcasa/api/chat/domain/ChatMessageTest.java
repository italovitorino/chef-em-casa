package br.com.chefemcasa.api.chat.domain;

import org.junit.jupiter.api.Test;
import java.util.UUID;
import static org.assertj.core.api.Assertions.assertThat;

class ChatMessageTest {

    @Test
    void create_setsAllFields() {
        var negotiationId = UUID.randomUUID();
        var senderId = UUID.randomUUID();

        var msg = ChatMessage.create(negotiationId, senderId, "João", "Olá!");

        assertThat(msg.getId()).isNotNull();
        assertThat(msg.getNegotiationId()).isEqualTo(negotiationId);
        assertThat(msg.getSenderId()).isEqualTo(senderId);
        assertThat(msg.getSenderName()).isEqualTo("João");
        assertThat(msg.getContent()).isEqualTo("Olá!");
        assertThat(msg.getSentAt()).isNotNull();
    }
}
