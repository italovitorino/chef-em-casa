package br.com.chefemcasa.api.identity.api;

import br.com.chefemcasa.api.identity.api.dto.UserResponse;
import br.com.chefemcasa.api.identity.application.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final AuthService authService;

    public UserController(AuthService authService) {
        this.authService = authService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable UUID id,
                                                JwtAuthenticationToken authentication) {
        var requesterId = UUID.fromString(authentication.getToken().getSubject());
        if (!requesterId.equals(id)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        return ResponseEntity.ok(UserMapper.toResponse(authService.findUserById(id)));
    }
}
