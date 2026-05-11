package br.com.chefemcasa.api.solicitations.domain.exception;

import java.util.UUID;

public class SolicitationNotFoundException extends RuntimeException {
    public SolicitationNotFoundException(UUID id) {
        super("Solicitação não encontrada: " + id);
    }
}
