package br.com.chefemcasa.api.chat.infra;

import br.com.chefemcasa.api.chat.domain.ChatMessage;
import br.com.chefemcasa.api.chat.domain.repository.ChatMessageRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

interface SpringDataChatMessageRepository
        extends ChatMessageRepository, JpaRepository<ChatMessage, UUID> {}
