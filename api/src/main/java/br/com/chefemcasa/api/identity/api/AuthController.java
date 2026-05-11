package br.com.chefemcasa.api.identity.api;

import br.com.chefemcasa.api.identity.api.dto.*;
import br.com.chefemcasa.api.identity.application.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        var user = authService.register(request);
        return ResponseEntity
                .created(URI.create("/users/" + user.getId()))
                .body(UserMapper.toResponse(user));
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        var tokens = authService.login(request);
        return ResponseEntity.ok(
                new TokenResponse(tokens.accessToken(), "Bearer", 900, tokens.refreshToken()));
    }

    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        var tokens = authService.refresh(request);
        return ResponseEntity.ok(
                new TokenResponse(tokens.accessToken(), "Bearer", 900, tokens.refreshToken()));
    }
}
