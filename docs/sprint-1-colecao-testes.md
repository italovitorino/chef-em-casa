# Coleção de Testes — Sprint 1

**Base URL:** `http://localhost:8080`  
**Autenticação:** Bearer JWT no header `Authorization` (exceto endpoints públicos)

> A coleção Postman exportada (`chef-em-casa.postman_collection`) está na raiz do repositório.

---

## Contexto: Identidade (`/api/auth`, `/api/users`)

### POST /api/auth/register

Registra um novo usuário (cliente ou chef). Público.

**Request**
```json
{
  "name": "Maria Silva",
  "email": "maria@example.com",
  "password": "senhaSegura123",
  "role": "CLIENT"
}
```

> `role`: `CLIENT` | `CHEF`  
> `password`: mínimo 8 caracteres

**Response `201 Created`**
```json
{
  "id": "a1b2c3d4-0000-0000-0000-000000000001",
  "name": "Maria Silva",
  "email": "maria@example.com",
  "role": "CLIENT",
  "createdAt": "2026-05-11T12:00:00Z"
}
```

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `400` | Campos inválidos ou senha curta |
| `409` | E-mail já cadastrado |

---

### POST /api/auth/login

Autentica o usuário e retorna os tokens de acesso. Público.

**Request**
```json
{
  "email": "maria@example.com",
  "password": "senhaSegura123"
}
```

**Response `200 OK`**
```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "refreshToken": "f7e8d9c0-1111-1111-1111-000000000001"
}
```

> `expiresIn`: segundos até expiração do `accessToken` (900 = 15 min)

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `400` | Campos ausentes |
| `401` | Credenciais inválidas |

---

### POST /api/auth/refresh

Renova o access token usando um refresh token válido. Público.

**Request**
```json
{
  "refreshToken": "f7e8d9c0-1111-1111-1111-000000000001"
}
```

**Response `200 OK`**
```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiJ9...",
  "tokenType": "Bearer",
  "expiresIn": 900,
  "refreshToken": "f7e8d9c0-2222-2222-2222-000000000002"
}
```

> Um novo `refreshToken` é emitido a cada chamada (rotação de token).

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `401` | Refresh token inválido, expirado ou já utilizado |

---

### GET /api/users/{id}

Retorna os dados do usuário autenticado. Requer JWT. Apenas o próprio usuário pode consultar seu perfil.

**Path param:** `id` — UUID do usuário

**Headers**
```
Authorization: Bearer <accessToken>
```

**Response `200 OK`**
```json
{
  "id": "a1b2c3d4-0000-0000-0000-000000000001",
  "name": "Maria Silva",
  "email": "maria@example.com",
  "role": "CLIENT",
  "createdAt": "2026-05-11T12:00:00Z"
}
```

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `401` | Token ausente ou inválido |
| `403` | Tentativa de consultar perfil de outro usuário |
| `404` | Usuário não encontrado |

---

## Contexto: Briefings (`/api/briefings`)

> Todos os endpoints deste contexto requerem `Authorization: Bearer <accessToken>`.

---

### POST /api/briefings

Publica um briefing aberto. Exclusivo para `CLIENT`.

**Request**
```json
{
  "eventType": "PRIVATE_DINNER",
  "eventDate": "2026-06-15",
  "numberOfGuests": 8,
  "street": "Rua das Acácias",
  "number": "42",
  "city": "Belo Horizonte",
  "state": "MG",
  "zipCode": "30130-010",
  "estimatedDurationMinutes": 180,
  "notes": "Prefiro cardápio italiano. Sem glúten para dois convidados."
}
```

> `eventType`: `PRIVATE_DINNER` | `LUNCH` | `CORPORATE_EVENT` | `TRAVEL` | `OTHER`  
> `numberOfGuests`: mínimo 1  
> `estimatedDurationMinutes`: mínimo 1

**Response `201 Created`**
```json
{
  "id": "c3d4e5f6-0000-0000-0000-000000000003",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
  "status": "OPEN",
  "details": {
    "eventType": "PRIVATE_DINNER",
    "eventDate": "2026-06-15",
    "numberOfGuests": 8,
    "location": {
      "street": "Rua das Acácias",
      "number": "42",
      "city": "Belo Horizonte",
      "state": "MG",
      "zipCode": "30130-010"
    },
    "estimatedDurationMinutes": 180,
    "notes": "Prefiro cardápio italiano. Sem glúten para dois convidados."
  },
  "interests": [],
  "createdAt": "2026-05-11T12:30:00Z",
  "expiresAt": "2026-05-14T12:30:00Z",
  "closedAt": null
}
```

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `400` | Campos inválidos |
| `403` | Usuário não é `CLIENT` |

---

### GET /api/briefings

Lista briefings. Clientes veem os seus; chefs veem todos os `OPEN`.

**Response `200 OK`** — array de briefings no mesmo formato do `POST`.

---

### GET /api/briefings/{id}

Retorna um briefing pelo ID.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não tem acesso |
| `404` | Briefing não encontrado |

---

### POST /api/briefings/{id}/close

Fecha o briefing manualmente. Exclusivo para `CLIENT` dono do briefing.

**Response `200 OK`** — retorna o briefing com `status: "CLOSED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente dono |
| `404` | Briefing não encontrado |

---

### POST /api/briefings/{id}/interests

Chef expressa interesse no briefing. Exclusivo para `CHEF`.

**Request (opcional)**
```json
{
  "message": "Tenho experiência em eventos similares com cardápio italiano."
}
```

**Response `200 OK`** — retorna o briefing atualizado com o novo interesse na lista `interests`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é `CHEF` |
| `404` | Briefing não encontrado |
| `422` | Briefing encerrado ou chef já expressou interesse |

---

### GET /api/briefings/{id}/interests

Lista chefs que expressaram interesse. Exclusivo para `CLIENT` dono do briefing.

**Response `200 OK`**
```json
[
  {
    "chefId": "f1e2d3c4-0000-0000-0000-000000000003",
    "expressedAt": "2026-05-11T13:00:00Z",
    "message": "Tenho experiência em eventos similares com cardápio italiano."
  }
]
```

---

### POST /api/briefings/{id}/negotiations

Cliente inicia negociação com um chef que expressou interesse. Exclusivo para `CLIENT`.

**Request**
```json
{
  "chefId": "f1e2d3c4-0000-0000-0000-000000000003"
}
```

**Response `201 Created`**
```json
{
  "id": "e2f3a4b5-0000-0000-0000-000000000005",
  "briefingId": "c3d4e5f6-0000-0000-0000-000000000003",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
  "chefId": "f1e2d3c4-0000-0000-0000-000000000003",
  "status": "AWAITING_PROPOSAL",
  "currentProposal": null,
  "proposalHistory": [],
  "createdAt": "2026-05-11T13:10:00Z",
  "updatedAt": "2026-05-11T13:10:00Z"
}
```

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente dono do briefing |
| `404` | Briefing não encontrado |
| `422` | Chef não expressou interesse neste briefing |

---

### GET /api/briefings/{briefingId}/negotiations

Lista negociações de um briefing. Exclusivo para `CLIENT` dono do briefing.

**Response `200 OK`** — array de negociações no mesmo formato.

---

## Contexto: Negociações (`/api/negotiations`)

> Todos os endpoints deste contexto requerem `Authorization: Bearer <accessToken>`.

---

### GET /api/negotiations/{id}

Retorna uma negociação. Cliente e chef da negociação têm acesso.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é parte desta negociação |
| `404` | Negociação não encontrada |

---

### POST /api/negotiations/{id}/proposals

Chef envia proposta. Exclusivo para o `CHEF` da negociação. Negociação deve estar em `AWAITING_PROPOSAL`.

**Request**
```json
{
  "totalAmount": 850.00,
  "serviceDescription": "Menu degustação italiano 5 tempos com harmonização",
  "validUntil": "2026-05-18",
  "notes": "Inclui deslocamento e ingredientes"
}
```

**Response `200 OK`** — retorna a negociação com `status: "PROPOSAL_SENT"` e `currentProposal` preenchida.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o chef desta negociação |
| `404` | Negociação não encontrada |
| `422` | Negociação não está em `AWAITING_PROPOSAL` |

---

### POST /api/negotiations/{id}/proposals/accept

Cliente aceita a proposta. Transição: `PROPOSAL_SENT` → `RESERVATION_CONFIRMED`.  
O briefing pai é fechado automaticamente e demais negociações abertas são canceladas.

**Response `200 OK`** — retorna a negociação com `status: "RESERVATION_CONFIRMED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente desta negociação |
| `404` | Negociação não encontrada |
| `422` | Negociação não está em `PROPOSAL_SENT` |

---

### POST /api/negotiations/{id}/proposals/reject

Cliente rejeita a proposta. Transição: `PROPOSAL_SENT` → `AWAITING_PROPOSAL`.

**Response `200 OK`** — retorna a negociação com `status: "AWAITING_PROPOSAL"` e proposta movida para `proposalHistory`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente desta negociação |
| `404` | Negociação não encontrada |
| `422` | Negociação não está em `PROPOSAL_SENT` |

---

### POST /api/negotiations/{id}/proposals/request-revision

Cliente solicita revisão. Transição: `PROPOSAL_SENT` → `AWAITING_PROPOSAL`.

**Response `200 OK`** — retorna a negociação com `status: "AWAITING_PROPOSAL"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente desta negociação |
| `404` | Negociação não encontrada |
| `422` | Negociação não está em `PROPOSAL_SENT` |

---

### POST /api/negotiations/{id}/complete

Marca o serviço como concluído. Disponível para cliente e chef. Transição: `RESERVATION_CONFIRMED` → `SERVICE_COMPLETED`.

**Response `200 OK`** — retorna a negociação com `status: "SERVICE_COMPLETED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é parte desta negociação |
| `404` | Negociação não encontrada |
| `422` | Negociação não está em `RESERVATION_CONFIRMED` |

---

### POST /api/negotiations/{id}/cancel

Cancela a negociação. Disponível para cliente e chef. Transição: qualquer status não-terminal → `CANCELLED`.

**Response `200 OK`** — retorna a negociação com `status: "CANCELLED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é parte desta negociação |
| `404` | Negociação não encontrada |
| `422` | Negociação já está em estado terminal |

---

## Resumo dos Endpoints

| Método | Path | Auth | Perfil |
|--------|------|------|--------|
| `POST` | `/api/auth/register` | Não | — |
| `POST` | `/api/auth/login` | Não | — |
| `POST` | `/api/auth/refresh` | Não | — |
| `GET` | `/api/users/{id}` | JWT | próprio usuário |
| `POST` | `/api/briefings` | JWT | `CLIENT` |
| `GET` | `/api/briefings` | JWT | `CLIENT` ou `CHEF` |
| `GET` | `/api/briefings/{id}` | JWT | `CLIENT` ou `CHEF` |
| `POST` | `/api/briefings/{id}/close` | JWT | `CLIENT` |
| `POST` | `/api/briefings/{id}/interests` | JWT | `CHEF` |
| `GET` | `/api/briefings/{id}/interests` | JWT | `CLIENT` |
| `POST` | `/api/briefings/{id}/negotiations` | JWT | `CLIENT` |
| `GET` | `/api/briefings/{briefingId}/negotiations` | JWT | `CLIENT` |
| `GET` | `/api/negotiations/{id}` | JWT | `CLIENT` ou `CHEF` |
| `POST` | `/api/negotiations/{id}/proposals` | JWT | `CHEF` |
| `POST` | `/api/negotiations/{id}/proposals/accept` | JWT | `CLIENT` |
| `POST` | `/api/negotiations/{id}/proposals/reject` | JWT | `CLIENT` |
| `POST` | `/api/negotiations/{id}/proposals/request-revision` | JWT | `CLIENT` |
| `POST` | `/api/negotiations/{id}/complete` | JWT | `CLIENT` ou `CHEF` |
| `POST` | `/api/negotiations/{id}/cancel` | JWT | `CLIENT` ou `CHEF` |
