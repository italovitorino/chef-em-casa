CREATE TABLE chat.messages (
    id              UUID         PRIMARY KEY,
    negotiation_id  UUID         NOT NULL,
    sender_id       UUID         NOT NULL,
    sender_name     VARCHAR(255) NOT NULL,
    content         TEXT         NOT NULL,
    sent_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_negotiation_id_sent_at
    ON chat.messages (negotiation_id, sent_at);

CREATE INDEX idx_chat_messages_sender_id
    ON chat.messages (sender_id);
