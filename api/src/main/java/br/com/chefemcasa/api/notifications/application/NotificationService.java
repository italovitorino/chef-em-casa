package br.com.chefemcasa.api.notifications.application;

import br.com.chefemcasa.api.notifications.domain.Notification;
import br.com.chefemcasa.api.notifications.domain.NotificationType;
import br.com.chefemcasa.api.notifications.domain.repository.NotificationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public NotificationService(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @Transactional
    public Notification createFor(UUID userId, NotificationType type,
                                  String title, String body, UUID relatedId) {
        return notificationRepository.save(
                Notification.create(userId, type, title, body, relatedId));
    }

    @Transactional(readOnly = true)
    public List<Notification> getForUser(UUID userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional
    public void markRead(UUID notificationId, UUID requestingUserId) {
        var notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notificação não encontrada"));
        if (!notification.getUserId().equals(requestingUserId)) {
            throw new RuntimeException("Acesso negado");
        }
        notification.markRead();
        notificationRepository.save(notification);
    }
}
