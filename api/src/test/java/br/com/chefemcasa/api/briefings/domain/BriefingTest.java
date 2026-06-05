package br.com.chefemcasa.api.briefings.domain;

import br.com.chefemcasa.api.briefings.domain.event.*;
import br.com.chefemcasa.api.briefings.domain.exception.ChefHasNotExpressedInterestException;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;

class BriefingTest {

    private Briefing openBriefing() {
        return Briefing.open(UUID.randomUUID(), new BriefingDetails(
                EventType.ROMANTIC_DINNER,
                LocalDate.now().plusDays(7),
                10,
                new Address("Rua A", "1", "São Paulo", "SP", "01000-000"),
                120,
                null
        ));
    }

    @Test
    void open_cria_briefing_aberto_com_evento_publicado() {
        var briefing = openBriefing();
        assertThat(briefing.getStatus()).isEqualTo(BriefingStatus.OPEN);
        var events = briefing.drainEvents();
        assertThat(events).hasSize(1);
        assertThat(events.get(0)).isInstanceOf(BriefingPublished.class);
    }

    @Test
    void expressInterest_adiciona_interesse_e_emite_evento() {
        var briefing = openBriefing();
        briefing.drainEvents();
        var chefId = UUID.randomUUID();
        briefing.expressInterest(chefId, "Tenho experiência em eventos similares");
        assertThat(briefing.getInterests()).hasSize(1);
        assertThat(briefing.getInterests().get(0).getChefId()).isEqualTo(chefId);
        var events = briefing.drainEvents();
        assertThat(events).hasSize(1);
        assertThat(events.get(0)).isInstanceOf(ChefInterestExpressed.class);
    }

    @Test
    void expressInterest_mesmo_chef_duas_vezes_lanca_excecao() {
        var briefing = openBriefing();
        var chefId = UUID.randomUUID();
        briefing.expressInterest(chefId, null);
        briefing.drainEvents();
        assertThatThrownBy(() -> briefing.expressInterest(chefId, null))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void expressInterest_em_briefing_fechado_lanca_excecao() {
        var briefing = openBriefing();
        briefing.close(BriefingCloseReason.CLIENT_CLOSED);
        briefing.drainEvents();
        assertThatThrownBy(() -> briefing.expressInterest(UUID.randomUUID(), null))
                .isInstanceOf(IllegalStateException.class);
    }

    @Test
    void close_altera_status_e_emite_evento() {
        var briefing = openBriefing();
        briefing.drainEvents();
        briefing.close(BriefingCloseReason.CLIENT_CLOSED);
        assertThat(briefing.getStatus()).isEqualTo(BriefingStatus.CLOSED);
        assertThat(briefing.getClosedAt()).isNotNull();
        var events = briefing.drainEvents();
        assertThat(events).hasSize(1);
        var closed = (BriefingClosed) events.get(0);
        assertThat(closed.reason()).isEqualTo(BriefingCloseReason.CLIENT_CLOSED);
    }

    @Test
    void close_idempotente_nao_emite_evento_duas_vezes() {
        var briefing = openBriefing();
        briefing.close(BriefingCloseReason.CLIENT_CLOSED);
        briefing.drainEvents();
        briefing.close(BriefingCloseReason.CLIENT_CLOSED);
        assertThat(briefing.drainEvents()).isEmpty();
    }

    @Test
    void recordNegotiationStarted_sem_interesse_previo_lanca_excecao() {
        var briefing = openBriefing();
        briefing.drainEvents();
        assertThatThrownBy(() -> briefing.recordNegotiationStarted(UUID.randomUUID(), UUID.randomUUID()))
                .isInstanceOf(ChefHasNotExpressedInterestException.class);
    }

    @Test
    void recordNegotiationStarted_com_interesse_emite_evento() {
        var briefing = openBriefing();
        var chefId = UUID.randomUUID();
        briefing.expressInterest(chefId, null);
        briefing.drainEvents();
        var negotiationId = UUID.randomUUID();
        briefing.recordNegotiationStarted(chefId, negotiationId);
        var events = briefing.drainEvents();
        assertThat(events).hasSize(1);
        var started = (NegotiationStarted) events.get(0);
        assertThat(started.negotiationId()).isEqualTo(negotiationId);
        assertThat(started.chefId()).isEqualTo(chefId);
    }
}
