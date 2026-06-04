package br.com.chefemcasa.api.negotiations.domain;

import br.com.chefemcasa.api.negotiations.domain.event.*;
import br.com.chefemcasa.api.negotiations.domain.exception.InvalidTransitionException;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;

class NegotiationTest {

    private Negotiation openNegotiation() {
        return Negotiation.open(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());
    }

    @Test
    void open_cria_negociacao_aguardando_proposta() {
        var n = openNegotiation();
        assertThat(n.getStatus()).isEqualTo(NegotiationStatus.AWAITING_PROPOSAL);
        assertThat(n.drainEvents()).isEmpty();
    }

    @Test
    void submitProposal_muda_status_para_proposta_enviada() {
        var n = openNegotiation();
        n.submitProposal(new BigDecimal("500.00"), "Serviço completo", LocalDate.now().plusDays(7), null);
        assertThat(n.getStatus()).isEqualTo(NegotiationStatus.PROPOSAL_SENT);
        var events = n.drainEvents();
        assertThat(events).hasSize(1);
        assertThat(events.get(0)).isInstanceOf(ProposalSent.class);
    }

    @Test
    void submitProposal_fora_do_estado_correto_lanca_excecao() {
        var n = openNegotiation();
        n.submitProposal(new BigDecimal("500.00"), "Serviço", LocalDate.now().plusDays(7), null);
        assertThatThrownBy(() -> n.submitProposal(new BigDecimal("600.00"), "Outro", LocalDate.now().plusDays(7), null))
                .isInstanceOf(InvalidTransitionException.class);
    }

    @Test
    void acceptProposal_muda_status_para_reserva_confirmada_e_emite_dois_eventos() {
        var n = openNegotiation();
        n.submitProposal(new BigDecimal("500.00"), "Serviço", LocalDate.now().plusDays(7), null);
        n.drainEvents();
        n.acceptProposal();
        assertThat(n.getStatus()).isEqualTo(NegotiationStatus.RESERVATION_CONFIRMED);
        var events = n.drainEvents();
        assertThat(events).hasSize(2);
        assertThat(events.get(0)).isInstanceOf(ProposalAccepted.class);
        assertThat(events.get(1)).isInstanceOf(ReservationConfirmed.class);
    }

    @Test
    void rejectProposal_volta_para_aguardando_proposta() {
        var n = openNegotiation();
        n.submitProposal(new BigDecimal("500.00"), "Serviço", LocalDate.now().plusDays(7), null);
        n.drainEvents();
        n.rejectProposal();
        assertThat(n.getStatus()).isEqualTo(NegotiationStatus.AWAITING_PROPOSAL);
        assertThat(n.getCurrentProposal()).isNull();
        var events = n.drainEvents();
        assertThat(events).hasSize(1);
        assertThat(events.get(0)).isInstanceOf(ProposalRejected.class);
    }

    @Test
    void cancel_em_estado_terminal_lanca_excecao() {
        var n = openNegotiation();
        n.submitProposal(new BigDecimal("500.00"), "Serviço", LocalDate.now().plusDays(7), null);
        n.acceptProposal();
        n.completeService();
        n.drainEvents();
        assertThatThrownBy(() -> n.cancel(UUID.randomUUID()))
                .isInstanceOf(InvalidTransitionException.class);
    }

    @Test
    void cancel_emite_evento_com_cancelledBy() {
        var n = openNegotiation();
        n.drainEvents();
        var cancelledBy = UUID.randomUUID();
        n.cancel(cancelledBy);
        assertThat(n.getStatus()).isEqualTo(NegotiationStatus.CANCELLED);
        var events = n.drainEvents();
        assertThat(events).hasSize(1);
        var cancelled = (NegotiationCancelled) events.get(0);
        assertThat(cancelled.cancelledBy()).isEqualTo(cancelledBy);
    }
}
