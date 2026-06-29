package br.com.chefemcasa.api.notifications.infra;

import br.com.chefemcasa.api.notifications.domain.Notification;
import br.com.chefemcasa.api.notifications.domain.repository.NotificationRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

interface SpringDataNotificationRepository
        extends NotificationRepository, JpaRepository<Notification, UUID> {}
