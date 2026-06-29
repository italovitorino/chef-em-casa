package br.com.chefemcasa.api.notifications.application;

import br.com.chefemcasa.api.notifications.domain.Notification;
import br.com.chefemcasa.api.notifications.domain.NotificationType;
import br.com.chefemcasa.api.notifications.domain.repository.NotificationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock NotificationRepository notificationRepository;
    @InjectMocks NotificationService notificationService;

    @Test
    void createFor_savesAndReturns() {
        var userId = UUID.randomUUID();
        var relatedId = UUID.randomUUID();
        var notification = Notification.create(userId, NotificationType.NEW_BRIEFING,
                "Novo pedido", "Um cliente publicou um briefing", relatedId);
        when(notificationRepository.save(any())).thenReturn(notification);

        var result = notificationService.createFor(userId, NotificationType.NEW_BRIEFING,
                "Novo pedido", "Um cliente publicou um briefing", relatedId);

        assertThat(result.getUserId()).isEqualTo(userId);
        assertThat(result.getType()).isEqualTo(NotificationType.NEW_BRIEFING);
        verify(notificationRepository).save(any());
    }

    @Test
    void getForUser_returnsList() {
        var userId = UUID.randomUUID();
        when(notificationRepository.findByUserIdOrderByCreatedAtDesc(userId))
                .thenReturn(List.of());

        assertThat(notificationService.getForUser(userId)).isEmpty();
    }

    @Test
    void markRead_ownerCanMark() {
        var userId = UUID.randomUUID();
        var notification = Notification.create(userId, NotificationType.PROPOSAL_SENT,
                "Proposta", "body", UUID.randomUUID());
        when(notificationRepository.findById(any())).thenReturn(Optional.of(notification));
        when(notificationRepository.save(any())).thenReturn(notification);

        notificationService.markRead(notification.getId(), userId);

        assertThat(notification.isRead()).isTrue();
    }

    @Test
    void markRead_wrongUser_throws() {
        var userId = UUID.randomUUID();
        var otherId = UUID.randomUUID();
        var notification = Notification.create(userId, NotificationType.PROPOSAL_SENT,
                "Proposta", "body", UUID.randomUUID());
        when(notificationRepository.findById(any())).thenReturn(Optional.of(notification));

        assertThatThrownBy(() -> notificationService.markRead(notification.getId(), otherId))
                .isInstanceOf(RuntimeException.class);
    }
}
