package br.com.chefemcasa.api.solicitations.domain.exception;

public class InvalidSolicitationTargetException extends RuntimeException {
    public InvalidSolicitationTargetException(String message) {
        super(message);
    }
}
