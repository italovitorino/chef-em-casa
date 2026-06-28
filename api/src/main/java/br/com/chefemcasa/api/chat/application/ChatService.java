package br.com.chefemcasa.api.chat.application;

import br.com.chefemcasa.api.chat.domain.ChatMessage;
import br.com.chefemcasa.api.chat.domain.repository.ChatMessageRepository;
import br.com.chefemcasa.api.negotiations.domain.exception.NegotiationNotFoundException;
import br.com.chefemcasa.api.negotiations.domain.repository.NegotiationRepository;
import br.com.chefemcasa.api.shared.domain.exception.UnauthorizedActorException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final NegotiationRepository negotiationRepository;

    public ChatService(ChatMessageRepository chatMessageRepository,
                       NegotiationRepository negotiationRepository) {
        this.chatMessageRepository = chatMessageRepository;
        this.negotiationRepository = negotiationRepository;
    }

    @Transactional
    public ChatMessage sendMessage(UUID negotiationId, UUID senderId,
                                   String senderName, String content) {
        var negotiation = negotiationRepository.findById(negotiationId)
                .orElseThrow(() -> new NegotiationNotFoundException(negotiationId));
        if (!negotiation.getClientId().equals(senderId) &&
            !negotiation.getChefId().equals(senderId)) {
            throw new UnauthorizedActorException();
        }
        return chatMessageRepository.save(
                ChatMessage.create(negotiationId, senderId, senderName, content));
    }

    @Transactional(readOnly = true)
    public List<ChatMessage> getHistory(UUID negotiationId) {
        return chatMessageRepository.findByNegotiationIdOrderBySentAtAsc(negotiationId);
    }
}
