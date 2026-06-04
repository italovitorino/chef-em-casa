package br.com.chefemcasa.api.briefings.api;

import br.com.chefemcasa.api.briefings.api.dto.*;
import br.com.chefemcasa.api.briefings.application.BriefingService;
import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.negotiations.api.NegotiationMapper;
import br.com.chefemcasa.api.negotiations.api.dto.NegotiationResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/briefings")
public class BriefingController {

    private final BriefingService briefingService;

    public BriefingController(BriefingService briefingService) {
        this.briefingService = briefingService;
    }

    @PostMapping
    public ResponseEntity<BriefingResponse> publish(
            @Valid @RequestBody CreateBriefingRequest request,
            JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        var role = UserRole.valueOf(auth.getToken().getClaim("role"));
        var briefing = briefingService.publish(clientId, role, request);
        return ResponseEntity
                .created(URI.create("/api/briefings/" + briefing.getId()))
                .body(BriefingMapper.toResponse(briefing));
    }

    @GetMapping
    public ResponseEntity<List<BriefingResponse>> listAll(JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        var role = UserRole.valueOf(auth.getToken().getClaim("role"));
        return ResponseEntity.ok(
                briefingService.findAll(actorId, role).stream()
                        .map(BriefingMapper::toResponse).toList());
    }

    @GetMapping("/{id}")
    public ResponseEntity<BriefingResponse> getById(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(BriefingMapper.toResponse(briefingService.findById(id, actorId)));
    }

    @PostMapping("/{id}/close")
    public ResponseEntity<BriefingResponse> close(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(BriefingMapper.toResponse(briefingService.close(id, clientId)));
    }

    @PostMapping("/{id}/interests")
    public ResponseEntity<BriefingResponse> expressInterest(
            @PathVariable UUID id,
            @RequestBody(required = false) ExpressInterestRequest request,
            JwtAuthenticationToken auth) {
        var chefId = UUID.fromString(auth.getToken().getSubject());
        var role = UserRole.valueOf(auth.getToken().getClaim("role"));
        var message = request != null ? request.message() : null;
        return ResponseEntity.ok(BriefingMapper.toResponse(
                briefingService.expressInterest(id, chefId, role, message)));
    }

    @GetMapping("/{id}/interests")
    public ResponseEntity<List<ChefInterestResponse>> listInterests(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        var briefing = briefingService.findById(id, actorId);
        return ResponseEntity.ok(
                briefing.getInterests().stream()
                        .map(i -> new ChefInterestResponse(i.getChefId(), i.getExpressedAt(), i.getMessage()))
                        .toList());
    }

    @PostMapping("/{id}/negotiations")
    public ResponseEntity<NegotiationResponse> startNegotiation(
            @PathVariable UUID id,
            @Valid @RequestBody StartNegotiationRequest request,
            JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        var negotiation = briefingService.startNegotiation(id, clientId, request.chefId());
        return ResponseEntity
                .created(URI.create("/api/negotiations/" + negotiation.getId()))
                .body(NegotiationMapper.toResponse(negotiation));
    }
}
