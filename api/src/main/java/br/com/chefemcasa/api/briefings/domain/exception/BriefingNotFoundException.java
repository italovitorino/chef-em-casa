package br.com.chefemcasa.api.briefings.domain.exception;

import java.util.UUID;

public class BriefingNotFoundException extends RuntimeException {
    public BriefingNotFoundException(UUID id) {
        super("Briefing não encontrado: " + id);
    }
}
