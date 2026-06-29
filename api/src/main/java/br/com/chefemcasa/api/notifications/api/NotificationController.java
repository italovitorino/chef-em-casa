package br.com.chefemcasa.api.notifications.api;

import br.com.chefemcasa.api.notifications.api.dto.NotificationResponse;
import br.com.chefemcasa.api.notifications.application.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public ResponseEntity<List<NotificationResponse>> getMyNotifications(JwtAuthenticationToken auth) {
        var userId = UUID.fromString(auth.getToken().getSubject());
        var list = notificationService.getForUser(userId).stream()
                .map(NotificationResponse::from)
                .toList();
        return ResponseEntity.ok(list);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markRead(@PathVariable UUID id, JwtAuthenticationToken auth) {
        var userId = UUID.fromString(auth.getToken().getSubject());
        notificationService.markRead(id, userId);
        return ResponseEntity.noContent().build();
    }
}
