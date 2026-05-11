package br.com.chefemcasa.api.solicitations.domain.exception;

public class UnauthorizedActorException extends RuntimeException {
    public UnauthorizedActorException() {
        super("Você não tem permissão para realizar esta ação");
    }
}
