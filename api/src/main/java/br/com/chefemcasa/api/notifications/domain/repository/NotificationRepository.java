package br.com.chefemcasa.api.notifications.domain.repository;

import br.com.chefemcasa.api.notifications.domain.Notification;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationRepository {
    Notification save(Notification notification);
    List<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId);
    Optional<Notification> findById(UUID id);
}
