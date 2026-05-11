package br.com.chefemcasa.api.identity;

import br.com.chefemcasa.api.identity.api.dto.*;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.*;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.containers.RabbitMQContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
@Testcontainers
class AuthIT {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Container
    @ServiceConnection
    static final RabbitMQContainer rabbitmq = new RabbitMQContainer("rabbitmq:3.13-management");

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void full_register_login_access_refresh_revocation_flow() {
        // Register
        var registerRes = restTemplate.postForEntity("/auth/register",
                new RegisterRequest("Jane Doe", "jane@flow.com", "password123", UserRole.CLIENT),
                UserResponse.class);

        assertEquals(HttpStatus.CREATED, registerRes.getStatusCode());
        assertNotNull(registerRes.getHeaders().getLocation());
        var user = registerRes.getBody();
        assertNotNull(user.id());
        assertEquals("jane@flow.com", user.email());
        assertEquals(UserRole.CLIENT, user.role());

        // Login
        var loginRes = restTemplate.postForEntity("/auth/login",
                new LoginRequest("jane@flow.com", "password123"),
                TokenResponse.class);

        assertEquals(HttpStatus.OK, loginRes.getStatusCode());
        var tokens = loginRes.getBody();
        assertNotNull(tokens.accessToken());
        assertNotNull(tokens.refreshToken());
        assertEquals("Bearer", tokens.tokenType());
        assertEquals(900, tokens.expiresIn());

        // Access protected endpoint with valid token
        var headers = new HttpHeaders();
        headers.setBearerAuth(tokens.accessToken());
        var profileRes = restTemplate.exchange(
                "/users/" + user.id(), HttpMethod.GET,
                new HttpEntity<>(headers), UserResponse.class);

        assertEquals(HttpStatus.OK, profileRes.getStatusCode());
        assertEquals(user.id(), profileRes.getBody().id());

        // Refresh — issues new token pair
        var refreshRes = restTemplate.postForEntity("/auth/refresh",
                new RefreshTokenRequest(tokens.refreshToken()),
                TokenResponse.class);

        assertEquals(HttpStatus.OK, refreshRes.getStatusCode());
        var newTokens = refreshRes.getBody();
        assertNotEquals(tokens.accessToken(), newTokens.accessToken());
        assertNotEquals(tokens.refreshToken(), newTokens.refreshToken());

        // Old refresh token must now be revoked
        var reuseRes = restTemplate.postForEntity("/auth/refresh",
                new RefreshTokenRequest(tokens.refreshToken()), Object.class);
        assertEquals(HttpStatus.UNAUTHORIZED, reuseRes.getStatusCode());
    }

    @Test
    void register_with_duplicate_email_returns_409() {
        var req = new RegisterRequest("Dup", "dup@test.com", "password123", UserRole.CHEF);
        restTemplate.postForEntity("/auth/register", req, UserResponse.class);

        var res = restTemplate.postForEntity("/auth/register", req, Object.class);
        assertEquals(HttpStatus.CONFLICT, res.getStatusCode());
    }

    @Test
    void login_with_wrong_password_returns_401() {
        restTemplate.postForEntity("/auth/register",
                new RegisterRequest("U", "wrongpw@test.com", "password123", UserRole.CLIENT),
                UserResponse.class);

        var res = restTemplate.postForEntity("/auth/login",
                new LoginRequest("wrongpw@test.com", "notthepassword"), Object.class);
        assertEquals(HttpStatus.UNAUTHORIZED, res.getStatusCode());
    }

    @Test
    void accessing_another_users_profile_returns_403() {
        restTemplate.postForEntity("/auth/register",
                new RegisterRequest("U1", "u1@test.com", "password123", UserRole.CLIENT),
                UserResponse.class);

        var u2Res = restTemplate.postForEntity("/auth/register",
                new RegisterRequest("U2", "u2@test.com", "password123", UserRole.CLIENT),
                UserResponse.class);

        var tokens = restTemplate.postForEntity("/auth/login",
                new LoginRequest("u1@test.com", "password123"),
                TokenResponse.class).getBody();

        var headers = new HttpHeaders();
        headers.setBearerAuth(tokens.accessToken());
        var res = restTemplate.exchange(
                "/users/" + u2Res.getBody().id(), HttpMethod.GET,
                new HttpEntity<>(headers), Object.class);

        assertEquals(HttpStatus.FORBIDDEN, res.getStatusCode());
    }

    @Test
    void accessing_protected_endpoint_without_token_returns_401() {
        var res = restTemplate.getForEntity("/users/" + UUID.randomUUID(), Object.class);
        assertEquals(HttpStatus.UNAUTHORIZED, res.getStatusCode());
    }
}
