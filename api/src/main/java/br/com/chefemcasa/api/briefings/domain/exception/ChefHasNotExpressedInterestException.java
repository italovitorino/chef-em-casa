package br.com.chefemcasa.api.briefings.domain.exception;

public class ChefHasNotExpressedInterestException extends RuntimeException {
    public ChefHasNotExpressedInterestException() {
        super("O chef não expressou interesse neste briefing");
    }
}
