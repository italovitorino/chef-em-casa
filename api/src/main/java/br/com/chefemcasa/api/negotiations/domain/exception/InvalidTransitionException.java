package br.com.chefemcasa.api.negotiations.domain.exception;

import br.com.chefemcasa.api.negotiations.domain.NegotiationStatus;

public class InvalidTransitionException extends RuntimeException {
    public InvalidTransitionException(String action, NegotiationStatus currentStatus) {
        super("Ação '" + action + "' não permitida no estado " + currentStatus);
    }
}
