package br.com.chefemcasa.api.identity.domain.exception;

import java.util.UUID;

public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(UUID id) {
        super("Usuário não encontrado: " + id);
    }
}
