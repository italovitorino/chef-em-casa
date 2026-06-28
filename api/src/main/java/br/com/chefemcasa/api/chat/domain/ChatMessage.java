package br.com.chefemcasa.api.chat.domain;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "messages", schema = "chat")
public class ChatMessage {

    @Id
    private UUID id;

    @Column(name = "negotiation_id", nullable = false)
    private UUID negotiationId;

    @Column(name = "sender_id", nullable = false)
    private UUID senderId;

    @Column(name = "sender_name", nullable = false)
    private String senderName;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "sent_at", nullable = false)
    private Instant sentAt;

    protected ChatMessage() {}

    public static ChatMessage create(UUID negotiationId, UUID senderId,
                                     String senderName, String content) {
        var msg = new ChatMessage();
        msg.id = UUID.randomUUID();
        msg.negotiationId = negotiationId;
        msg.senderId = senderId;
        msg.senderName = senderName;
        msg.content = content;
        msg.sentAt = Instant.now();
        return msg;
    }

    public UUID getId()             { return id; }
    public UUID getNegotiationId()  { return negotiationId; }
    public UUID getSenderId()       { return senderId; }
    public String getSenderName()   { return senderName; }
    public String getContent()      { return content; }
    public Instant getSentAt()      { return sentAt; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof ChatMessage m)) return false;
        return id != null && id.equals(m.id);
    }

    @Override
    public int hashCode() { return getClass().hashCode(); }
}
