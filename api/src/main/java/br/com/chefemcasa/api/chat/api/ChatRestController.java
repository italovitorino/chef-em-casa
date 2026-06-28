package br.com.chefemcasa.api.chat.api;

import br.com.chefemcasa.api.chat.api.dto.MessageResponse;
import br.com.chefemcasa.api.chat.application.ChatService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/negotiations/{negotiationId}/messages")
public class ChatRestController {

    private final ChatService chatService;

    public ChatRestController(ChatService chatService) {
        this.chatService = chatService;
    }

    @GetMapping
    public ResponseEntity<List<MessageResponse>> getHistory(
            @PathVariable UUID negotiationId) {
        var messages = chatService.getHistory(negotiationId)
                .stream()
                .map(MessageResponse::from)
                .toList();
        return ResponseEntity.ok(messages);
    }
}
