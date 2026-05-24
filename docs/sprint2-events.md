# Documentação de Eventos — Sprint 2

## Tabela de Eventos

| Nome do Evento | Produtor | Consumidor | Routing Key | Exchange |
|----------------|----------|------------|-------------|----------|
| `UserRegistered` | `AuthService` | `WelcomeEmailConsumer` | `identity.user.registered` | `chefemcasa.events` |
| `BriefingSubmitted` | `SolicitationService` | `NewSolicitationConsumer` | `solicitations.briefing.submitted` | `chefemcasa.events` |
| `ProposalSent` | `SolicitationService` | — (Sprint 4) | `solicitations.proposal.sent` | `chefemcasa.events` |
| `ProposalAccepted` | `SolicitationService` | — (Sprint 4) | `solicitations.proposal.accepted` | `chefemcasa.events` |
| `ProposalRejected` | `SolicitationService` | — (Sprint 4) | `solicitations.proposal.rejected` | `chefemcasa.events` |
| `ProposalRevisionRequested` | `SolicitationService` | — (Sprint 4) | `solicitations.proposal.revision-requested` | `chefemcasa.events` |
| `ReservationConfirmed` | `SolicitationService` | — (Sprint 4) | `solicitations.reservation.confirmed` | `chefemcasa.events` |
| `ServiceCompleted` | `SolicitationService` | — (Sprint 4) | `solicitations.service.completed` | `chefemcasa.events` |
| `SolicitationCancelled` | `SolicitationService` | — (Sprint 4) | `solicitations.solicitation.cancelled` | `chefemcasa.events` |

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

### `BriefingSubmitted`

**Fila:** `chefemcasa.solicitations.new-solicitation`

```json
{
  "eventId": "c4d5e6f7-abcd-1234-0000-aabbccddeeff",
  "occurredAt": "2026-05-24T21:05:00Z",
  "version": 1,
  "solicitationId": "d1e2f3a4-0000-0000-0000-000000000002",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
  "chefId": "f1e2d3c4-0000-0000-0000-000000000003"
}
```

### `ProposalSent`

**Fila:** — (sem consumidor ativo nesta sprint)

```json
{
  "eventId": "e5f6a7b8-0000-1111-2222-333344445555",
  "occurredAt": "2026-05-24T21:10:00Z",
  "version": 1,
  "solicitationId": "d1e2f3a4-0000-0000-0000-000000000002",
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

POST /api/solicitations
    └─► SolicitationService.createSolicitation()
            └─► publica BriefingSubmitted  →  routing key: solicitations.briefing.submitted
                    └─► NewSolicitationConsumer.handleBriefingSubmitted()
                            └─► log: "[NEW-SOLICITATION] Nova solicitação recebida: solicitationId=..."
```
