package br.com.chefemcasa.api.identity.application;

import br.com.chefemcasa.api.identity.domain.exception.EmailAlreadyRegisteredException;
import br.com.chefemcasa.api.identity.domain.exception.InvalidCredentialsException;
import br.com.chefemcasa.api.identity.domain.exception.UserNotFoundException;
import br.com.chefemcasa.api.identity.domain.model.RefreshToken;
import br.com.chefemcasa.api.identity.domain.model.User;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.identity.domain.repository.RefreshTokenRepository;
import br.com.chefemcasa.api.identity.domain.repository.UserRepository;
import br.com.chefemcasa.api.identity.domain.service.PasswordEncoder;
import br.com.chefemcasa.api.identity.infrastructure.security.JwtTokenService;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.UUID;

@Service
public class AuthService {

    private static final String EVENTS_EXCHANGE = "chefemcasa.events";
    private static final String USER_REGISTERED_KEY = "identity.user.registered";
    private static final Duration REFRESH_TOKEN_VALIDITY = Duration.ofDays(7);

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final RabbitTemplate rabbitTemplate;

    public AuthService(UserRepository userRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenService jwtTokenService,
                       RabbitTemplate rabbitTemplate) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenService = jwtTokenService;
        this.rabbitTemplate = rabbitTemplate;
    }

    @Transactional
    public User register(String name, String email, String rawPassword, UserRole role) {
        if (userRepository.existsByEmail(email)) {
            throw new EmailAlreadyRegisteredException(email);
        }
        var user = User.register(name, email, passwordEncoder.encode(rawPassword), role);
        var saved = userRepository.save(user);
        saved.drainEvents().forEach(event ->
                rabbitTemplate.convertAndSend(EVENTS_EXCHANGE, USER_REGISTERED_KEY, event));
        return saved;
    }

    @Transactional
    public TokenPair login(String email, String rawPassword) {
        var user = userRepository.findByEmail(email)
                .filter(u -> passwordEncoder.matches(rawPassword, u.getPasswordHash()))
                .orElseThrow(InvalidCredentialsException::new);
        return issueTokens(user);
    }

    @Transactional
    public TokenPair refresh(UUID refreshTokenValue) {
        var refreshToken = refreshTokenRepository.findByToken(refreshTokenValue)
                .orElseThrow(InvalidCredentialsException::new);
        if (!refreshToken.isValid()) {
            throw new InvalidCredentialsException();
        }
        refreshToken.revoke();
        refreshTokenRepository.save(refreshToken);
        var user = userRepository.findById(refreshToken.getUserId())
                .orElseThrow(InvalidCredentialsException::new);
        return issueTokens(user);
    }

    public User findUserById(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));
    }

    private TokenPair issueTokens(User user) {
        var accessToken = jwtTokenService.generateAccessToken(user);
        var refreshToken = RefreshToken.issue(user.getId(), REFRESH_TOKEN_VALIDITY);
        refreshTokenRepository.save(refreshToken);
        return new TokenPair(accessToken, refreshToken.getToken());
    }
}
