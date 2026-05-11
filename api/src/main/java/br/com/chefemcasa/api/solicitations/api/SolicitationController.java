package br.com.chefemcasa.api.solicitations.api;

import br.com.chefemcasa.api.identity.domain.model.UserRole;
import br.com.chefemcasa.api.solicitations.api.dto.CreateSolicitationRequest;
import br.com.chefemcasa.api.solicitations.api.dto.SolicitationResponse;
import br.com.chefemcasa.api.solicitations.api.dto.SubmitProposalRequest;
import br.com.chefemcasa.api.solicitations.application.SolicitationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/solicitations")
public class SolicitationController {

    private final SolicitationService solicitationService;

    public SolicitationController(SolicitationService solicitationService) {
        this.solicitationService = solicitationService;
    }

    @PostMapping
    public ResponseEntity<SolicitationResponse> create(
            @Valid @RequestBody CreateSolicitationRequest request,
            JwtAuthenticationToken authentication) {
        var clientId = UUID.fromString(authentication.getToken().getSubject());
        var solicitation = solicitationService.createSolicitation(clientId, request);
        return ResponseEntity
                .created(URI.create("/solicitations/" + solicitation.getId()))
                .body(SolicitationMapper.toResponse(solicitation));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SolicitationResponse> getById(
            @PathVariable UUID id,
            JwtAuthenticationToken authentication) {
        var actorId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.findById(id, actorId)));
    }

    @GetMapping
    public ResponseEntity<List<SolicitationResponse>> listAll(
            JwtAuthenticationToken authentication) {
        var actorId = UUID.fromString(authentication.getToken().getSubject());
        var role = UserRole.valueOf(authentication.getToken().getClaim("role"));
        return ResponseEntity.ok(
                solicitationService.findAll(actorId, role).stream()
                        .map(SolicitationMapper::toResponse)
                        .toList());
    }

    @PostMapping("/{id}/proposals")
    public ResponseEntity<SolicitationResponse> submitProposal(
            @PathVariable UUID id,
            @Valid @RequestBody SubmitProposalRequest request,
            JwtAuthenticationToken authentication) {
        var chefId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.submitProposal(id, chefId, request)));
    }

    @PostMapping("/{id}/proposals/accept")
    public ResponseEntity<SolicitationResponse> acceptProposal(
            @PathVariable UUID id,
            JwtAuthenticationToken authentication) {
        var clientId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.acceptProposal(id, clientId)));
    }

    @PostMapping("/{id}/proposals/reject")
    public ResponseEntity<SolicitationResponse> rejectProposal(
            @PathVariable UUID id,
            JwtAuthenticationToken authentication) {
        var clientId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.rejectProposal(id, clientId)));
    }

    @PostMapping("/{id}/proposals/request-revision")
    public ResponseEntity<SolicitationResponse> requestRevision(
            @PathVariable UUID id,
            JwtAuthenticationToken authentication) {
        var clientId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.requestRevision(id, clientId)));
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<SolicitationResponse> completeService(
            @PathVariable UUID id,
            JwtAuthenticationToken authentication) {
        var clientId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.completeService(id, clientId)));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<SolicitationResponse> cancel(
            @PathVariable UUID id,
            JwtAuthenticationToken authentication) {
        var actorId = UUID.fromString(authentication.getToken().getSubject());
        return ResponseEntity.ok(SolicitationMapper.toResponse(
                solicitationService.cancel(id, actorId)));
    }
}
