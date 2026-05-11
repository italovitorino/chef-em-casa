package br.com.chefemcasa.api.solicitations.domain.exception;

import br.com.chefemcasa.api.solicitations.domain.model.SolicitationStatus;

public class InvalidTransitionException extends RuntimeException {
    public InvalidTransitionException(String action, SolicitationStatus currentStatus) {
        super("Ação '" + action + "' não permitida no estado " + currentStatus);
    }
}
