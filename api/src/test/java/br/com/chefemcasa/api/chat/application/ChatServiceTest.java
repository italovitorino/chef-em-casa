package br.com.chefemcasa.api.chat.application;

import br.com.chefemcasa.api.chat.domain.ChatMessage;
import br.com.chefemcasa.api.chat.domain.repository.ChatMessageRepository;
import br.com.chefemcasa.api.negotiations.domain.Negotiation;
import br.com.chefemcasa.api.negotiations.domain.repository.NegotiationRepository;
import br.com.chefemcasa.api.shared.domain.exception.UnauthorizedActorException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class ChatServiceTest {

    @Mock ChatMessageRepository chatMessageRepository;
    @Mock NegotiationRepository negotiationRepository;
    @InjectMocks ChatService chatService;

    private UUID negotiationId;
    private UUID clientId;
    private UUID chefId;
    private UUID outsiderId;

    @BeforeEach
    void setUp() {
        negotiationId = UUID.randomUUID();
        clientId      = UUID.randomUUID();
        chefId        = UUID.randomUUID();
        outsiderId    = UUID.randomUUID();
    }

    @Test
    void sendMessage_client_savesAndReturns() {
        var negotiation = mockNegotiation();
        when(negotiationRepository.findById(negotiationId)).thenReturn(Optional.of(negotiation));
        var saved = ChatMessage.create(negotiationId, clientId, "Maria", "Olá!");
        when(chatMessageRepository.save(any())).thenReturn(saved);

        var result = chatService.sendMessage(negotiationId, clientId, "Maria", "Olá!");

        assertThat(result.getNegotiationId()).isEqualTo(negotiationId);
        assertThat(result.getSenderId()).isEqualTo(clientId);
        verify(chatMessageRepository).save(any());
    }

    @Test
    void sendMessage_chef_savesAndReturns() {
        var negotiation = mockNegotiation();
        when(negotiationRepository.findById(negotiationId)).thenReturn(Optional.of(negotiation));
        var saved = ChatMessage.create(negotiationId, chefId, "Carlos", "Boa tarde!");
        when(chatMessageRepository.save(any())).thenReturn(saved);

        var result = chatService.sendMessage(negotiationId, chefId, "Carlos", "Boa tarde!");

        assertThat(result.getSenderId()).isEqualTo(chefId);
    }

    @Test
    void sendMessage_outsider_throwsUnauthorized() {
        var negotiation = mockNegotiation();
        when(negotiationRepository.findById(negotiationId)).thenReturn(Optional.of(negotiation));

        assertThatThrownBy(() ->
            chatService.sendMessage(negotiationId, outsiderId, "Hacker", "inject"))
            .isInstanceOf(UnauthorizedActorException.class);

        verify(chatMessageRepository, never()).save(any());
    }

    @Test
    void sendMessage_negotiationNotFound_throwsRuntime() {
        when(negotiationRepository.findById(negotiationId)).thenReturn(Optional.empty());

        assertThatThrownBy(() ->
            chatService.sendMessage(negotiationId, clientId, "Maria", "Olá"))
            .isInstanceOf(RuntimeException.class);
    }

    @Test
    void getHistory_returnsOrderedMessages() {
        var messages = List.of(
            ChatMessage.create(negotiationId, clientId, "Maria", "Primeira"),
            ChatMessage.create(negotiationId, chefId,   "Carlos", "Segunda")
        );
        when(chatMessageRepository.findByNegotiationIdOrderBySentAtAsc(negotiationId))
            .thenReturn(messages);

        var result = chatService.getHistory(negotiationId);

        assertThat(result).hasSize(2);
        assertThat(result.get(0).getContent()).isEqualTo("Primeira");
    }

    @Test
    void getHistory_empty_returnsEmptyList() {
        when(chatMessageRepository.findByNegotiationIdOrderBySentAtAsc(negotiationId))
            .thenReturn(List.of());

        assertThat(chatService.getHistory(negotiationId)).isEmpty();
    }

    private Negotiation mockNegotiation() {
        var negotiation = mock(Negotiation.class);
        when(negotiation.getClientId()).thenReturn(clientId);
        when(negotiation.getChefId()).thenReturn(chefId);
        return negotiation;
    }
}
