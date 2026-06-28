package br.com.chefemcasa.api.chat.api;

import br.com.chefemcasa.api.chat.application.ChatService;
import br.com.chefemcasa.api.chat.domain.ChatMessage;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ChatRestControllerTest {

    @Mock ChatService chatService;
    @InjectMocks ChatRestController controller;

    private final UUID negotiationId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();

    @Test
    void getHistory_returnsMessages() {
        var msg = ChatMessage.create(negotiationId, userId, "Maria", "Olá!");
        when(chatService.getHistory(negotiationId)).thenReturn(List.of(msg));

        var result = controller.getHistory(negotiationId);

        assertThat(result.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(result.getBody()).hasSize(1);
        assertThat(result.getBody().get(0).content()).isEqualTo("Olá!");
        assertThat(result.getBody().get(0).senderName()).isEqualTo("Maria");
    }

    @Test
    void getHistory_empty_returnsEmptyList() {
        when(chatService.getHistory(negotiationId)).thenReturn(List.of());

        var result = controller.getHistory(negotiationId);

        assertThat(result.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(result.getBody()).isEmpty();
    }
}
