package br.com.chefemcasa.api.chat.api;

import br.com.chefemcasa.api.chat.api.dto.MessageResponse;
import br.com.chefemcasa.api.chat.api.dto.SendMessageRequest;
import br.com.chefemcasa.api.chat.application.ChatService;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;

import java.security.Principal;
import java.util.UUID;

@Controller
public class ChatController {

    private final ChatService chatService;
    private final SimpMessageSendingOperations messagingTemplate;

    public ChatController(ChatService chatService,
                          SimpMessageSendingOperations messagingTemplate) {
        this.chatService = chatService;
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/negotiations/{negotiationId}/chat")
    public void sendMessage(
            @DestinationVariable UUID negotiationId,
            @Payload @Validated SendMessageRequest request,
            Principal principal) {
        var jwtAuth = (JwtAuthenticationToken) principal;
        var senderId   = UUID.fromString(jwtAuth.getToken().getSubject());
        var senderName = jwtAuth.getToken().getClaimAsString("name");

        var saved = chatService.sendMessage(negotiationId, senderId, senderName, request.content());

        messagingTemplate.convertAndSend(
                "/topic/negotiations/" + negotiationId + "/chat",
                MessageResponse.from(saved));
    }
}
