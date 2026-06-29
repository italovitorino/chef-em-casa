package br.com.chefemcasa.api.notifications.api.dto;

import br.com.chefemcasa.api.notifications.domain.Notification;

import java.time.Instant;
import java.util.UUID;

public record NotificationResponse(
        UUID id,
        String type,
        String title,
        String body,
        UUID relatedId,
        boolean read,
        Instant createdAt
) {
    public static NotificationResponse from(Notification n) {
        return new NotificationResponse(
                n.getId(), n.getType().name(),
                n.getTitle(), n.getBody(), n.getRelatedId(),
                n.isRead(), n.getCreatedAt());
    }
}
