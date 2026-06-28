package br.com.chefemcasa.api.chat.domain.repository;

import br.com.chefemcasa.api.chat.domain.ChatMessage;
import java.util.List;
import java.util.UUID;

public interface ChatMessageRepository {
    ChatMessage save(ChatMessage message);
    List<ChatMessage> findByNegotiationIdOrderBySentAtAsc(UUID negotiationId);
}
