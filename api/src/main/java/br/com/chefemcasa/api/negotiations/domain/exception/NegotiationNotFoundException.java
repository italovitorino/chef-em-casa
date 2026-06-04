package br.com.chefemcasa.api.negotiations.domain.exception;

import java.util.UUID;

public class NegotiationNotFoundException extends RuntimeException {
    public NegotiationNotFoundException(UUID id) {
        super("Negociação não encontrada: " + id);
    }
}
