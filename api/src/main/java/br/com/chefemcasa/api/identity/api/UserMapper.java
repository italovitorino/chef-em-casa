package br.com.chefemcasa.api.identity.api;

import br.com.chefemcasa.api.identity.api.dto.UserResponse;
import br.com.chefemcasa.api.identity.domain.model.User;

public final class UserMapper {

    private UserMapper() {}

    public static UserResponse toResponse(User user) {
        return new UserResponse(
                user.getId(), user.getName(), user.getEmail(),
                user.getRole(), user.getCreatedAt());
    }
}
