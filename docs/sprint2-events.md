# Documentação de Eventos — Sprint 2 (atualizado)

## Tabela de Eventos

| Nome do Evento | Produtor | Consumidor | Routing Key | Exchange |
|----------------|----------|------------|-------------|----------|
| `UserRegistered` | `AuthService` | `WelcomeEmailConsumer` | `identity.user.registered` | `chefemcasa.events` |
| `BriefingPublished` | `BriefingService` | `NewBriefingConsumer` | `briefings.briefing.published` | `chefemcasa.events` |
| `ChefInterestExpressed` | `BriefingService` | — | `briefings.interest.expressed` | `chefemcasa.events` |
| `NegotiationStarted` | `BriefingService` | — | `briefings.negotiation.started` | `chefemcasa.events` |
| `BriefingClosed` | `BriefingService` | — | `briefings.briefing.closed` | `chefemcasa.events` |
| `ProposalSent` | `NegotiationService` | — (Sprint 4) | `negotiations.proposal.sent` | `chefemcasa.events` |
| `ProposalAccepted` | `NegotiationService` | — (Sprint 4) | `negotiations.proposal.accepted` | `chefemcasa.events` |
| `ProposalRejected` | `NegotiationService` | — (Sprint 4) | `negotiations.proposal.rejected` | `chefemcasa.events` |
| `ProposalRevisionRequested` | `NegotiationService` | — (Sprint 4) | `negotiations.proposal.revision-requested` | `chefemcasa.events` |
| `ReservationConfirmed` | `NegotiationService` | `ReservationConfirmedHandler` | `negotiations.reservation.confirmed` | `chefemcasa.events` |
| `ServiceCompleted` | `NegotiationService` | — (Sprint 4) | `negotiations.service.completed` | `chefemcasa.events` |
| `NegotiationCancelled` | `NegotiationService` | — (Sprint 4) | `negotiations.negotiation.cancelled` | `chefemcasa.events` |

---

## Payloads JSON de Exemplo

### `UserRegistered`

**Fila:** `chefemcasa.identity.welcome-email`

```json
{
  "eventId": "b3f1a2c4-1234-5678-abcd-ef1234567890",
  "occurredAt": "2026-05-24T21:00:00Z",
  "version": 1,
  "userId": "a1b2c3d4-0000-0000-0000-000000000001",
  "email": "joao@exemplo.com",
  "role": "CLIENT"
}
```

### `BriefingPublished`

**Fila:** `chefemcasa.briefings.new-briefing`

```json
{
  "eventId": "c4d5e6f7-abcd-1234-0000-aabbccddeeff",
  "occurredAt": "2026-05-24T21:05:00Z",
  "version": 1,
  "briefingId": "d1e2f3a4-0000-0000-0000-000000000002",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001"
}
```

### `ChefInterestExpressed`

**Fila:** — (sem consumidor ativo nesta sprint)

```json
{
  "eventId": "e5f6a7b8-0000-1111-2222-333344445555",
  "occurredAt": "2026-05-24T21:10:00Z",
  "version": 1,
  "briefingId": "d1e2f3a4-0000-0000-0000-000000000002",
  "chefId": "f1e2d3c4-0000-0000-0000-000000000003"
}
```

### `ReservationConfirmed`

**Fila:** `chefemcasa.negotiations.reservation-confirmed`

```json
{
  "eventId": "f6g7h8i9-0000-2222-3333-444455556666",
  "occurredAt": "2026-05-24T22:00:00Z",
  "version": 1,
  "negotiationId": "e2f3a4b5-0000-0000-0000-000000000005",
  "briefingId": "d1e2f3a4-0000-0000-0000-000000000002",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
  "chefId": "f1e2d3c4-0000-0000-0000-000000000003",
  "totalAmount": 850.00
}
```

### `ProposalSent`

**Fila:** — (sem consumidor ativo nesta sprint)

```json
{
  "eventId": "g7h8i9j0-0000-3333-4444-555566667777",
  "occurredAt": "2026-05-24T21:30:00Z",
  "version": 1,
  "negotiationId": "e2f3a4b5-0000-0000-0000-000000000005",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
  "chefId": "f1e2d3c4-0000-0000-0000-000000000003",
  "totalAmount": 850.00
}
```

---

## Fluxo de Eventos Implementado

```
POST /api/auth/register
    └─► AuthService.register()
            └─► publica UserRegistered  →  routing key: identity.user.registered
                    └─► WelcomeEmailConsumer.handleUserRegistered()
                            └─► log: "[WELCOME-EMAIL] Enviando boas-vindas para joao@exemplo.com"

POST /api/briefings
    └─► BriefingService.publish()
            └─► publica BriefingPublished  →  routing key: briefings.briefing.published
                    └─► (NewBriefingConsumer — notificação para chefs)

POST /api/briefings/{id}/interests
    └─► BriefingService.expressInterest()
            └─► publica ChefInterestExpressed  →  routing key: briefings.interest.expressed

POST /api/briefings/{id}/negotiations
    └─► BriefingService.startNegotiation()
            └─► publica NegotiationStarted  →  routing key: briefings.negotiation.started

POST /api/negotiations/{id}/proposals/accept
    └─► NegotiationService.acceptProposal()
            └─► publica ReservationConfirmed  →  routing key: negotiations.reservation.confirmed
                    └─► ReservationConfirmedHandler.handle()
                            └─► BriefingService.closeForAcceptedProposal()
                                    └─► publica BriefingClosed(PROPOSAL_ACCEPTED)
                                    └─► cancela negociações abertas restantes
```
