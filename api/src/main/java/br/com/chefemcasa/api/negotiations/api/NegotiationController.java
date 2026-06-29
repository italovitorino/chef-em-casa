package br.com.chefemcasa.api.negotiations.api;

import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.negotiations.api.dto.NegotiationResponse;
import br.com.chefemcasa.api.negotiations.api.dto.SubmitProposalRequest;
import br.com.chefemcasa.api.negotiations.application.NegotiationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
public class NegotiationController {

    private final NegotiationService negotiationService;

    public NegotiationController(NegotiationService negotiationService) {
        this.negotiationService = negotiationService;
    }

    @GetMapping("/api/negotiations/mine")
    public ResponseEntity<List<NegotiationResponse>> getMyNegotiations(JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        var roleClaim = (String) auth.getToken().getClaim("role");
        var role = UserRole.valueOf(roleClaim);
        var list = negotiationService.findAll(actorId, role).stream()
                .map(NegotiationMapper::toResponse)
                .toList();
        return ResponseEntity.ok(list);
    }

    @GetMapping("/api/negotiations/{id}")
    public ResponseEntity<NegotiationResponse> getById(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(negotiationService.findById(id, actorId)));
    }

    @GetMapping("/api/briefings/{briefingId}/negotiations")
    public ResponseEntity<List<NegotiationResponse>> listByBriefing(
            @PathVariable UUID briefingId, JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(
                negotiationService.findByBriefingId(briefingId, clientId).stream()
                        .map(NegotiationMapper::toResponse).toList());
    }

    @PostMapping("/api/negotiations/{id}/proposals")
    public ResponseEntity<NegotiationResponse> submitProposal(
            @PathVariable UUID id,
            @Valid @RequestBody SubmitProposalRequest request,
            JwtAuthenticationToken auth) {
        var chefId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(
                negotiationService.submitProposal(id, chefId, request)));
    }

    @PostMapping("/api/negotiations/{id}/proposals/accept")
    public ResponseEntity<NegotiationResponse> acceptProposal(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(
                negotiationService.acceptProposal(id, clientId)));
    }

    @PostMapping("/api/negotiations/{id}/proposals/reject")
    public ResponseEntity<NegotiationResponse> rejectProposal(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(
                negotiationService.rejectProposal(id, clientId)));
    }

    @PostMapping("/api/negotiations/{id}/proposals/request-revision")
    public ResponseEntity<NegotiationResponse> requestRevision(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var clientId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(
                negotiationService.requestRevision(id, clientId)));
    }

    @PostMapping("/api/negotiations/{id}/complete")
    public ResponseEntity<NegotiationResponse> completeService(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(
                negotiationService.completeService(id, actorId)));
    }

    @PostMapping("/api/negotiations/{id}/cancel")
    public ResponseEntity<NegotiationResponse> cancel(
            @PathVariable UUID id, JwtAuthenticationToken auth) {
        var actorId = UUID.fromString(auth.getToken().getSubject());
        return ResponseEntity.ok(NegotiationMapper.toResponse(
                negotiationService.cancel(id, actorId)));
    }
}
