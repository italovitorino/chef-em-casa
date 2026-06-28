package br.com.chefemcasa.api.chat.api.dto;

import br.com.chefemcasa.api.chat.domain.ChatMessage;
import java.time.Instant;
import java.util.UUID;

public record MessageResponse(
        UUID id,
        UUID negotiationId,
        UUID senderId,
        String senderName,
        String content,
        Instant sentAt
) {
    public static MessageResponse from(ChatMessage msg) {
        return new MessageResponse(
                msg.getId(),
                msg.getNegotiationId(),
                msg.getSenderId(),
                msg.getSenderName(),
                msg.getContent(),
                msg.getSentAt()
        );
    }
}
