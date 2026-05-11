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

## Contexto: Solicitações (`/api/solicitations`)

> Todos os endpoints deste contexto requerem `Authorization: Bearer <accessToken>`.

---

### POST /api/solicitations

Cria uma nova solicitação com briefing. Exclusivo para `CLIENT`.

**Request**
```json
{
  "chefId": "b2c3d4e5-0000-0000-0000-000000000002",
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
  "chefId": "b2c3d4e5-0000-0000-0000-000000000002",
  "status": "AWAITING_PROPOSAL",
  "briefing": {
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
  "currentProposal": null,
  "proposalHistory": [],
  "createdAt": "2026-05-11T12:30:00Z",
  "updatedAt": "2026-05-11T12:30:00Z"
}
```

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `400` | Campos inválidos |
| `403` | Usuário não é `CLIENT` |

---

### GET /api/solicitations/{id}

Retorna uma solicitação pelo ID. Cliente vê apenas suas próprias; chef vê apenas as recebidas.

**Path param:** `id` — UUID da solicitação

**Response `200 OK`**
```json
{
  "id": "c3d4e5f6-0000-0000-0000-000000000003",
  "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
  "chefId": "b2c3d4e5-0000-0000-0000-000000000002",
  "status": "PROPOSAL_SENT",
  "briefing": {
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
  "currentProposal": {
    "id": "d4e5f6g7-0000-0000-0000-000000000004",
    "totalAmount": 850.00,
    "serviceDescription": "Menu degustação italiano 5 tempos com harmonização",
    "validUntil": "2026-05-18",
    "notes": "Inclui deslocamento e ingredientes",
    "sentAt": "2026-05-11T14:00:00Z"
  },
  "proposalHistory": [],
  "createdAt": "2026-05-11T12:30:00Z",
  "updatedAt": "2026-05-11T14:00:00Z"
}
```

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Solicitação pertence a outro cliente/chef |
| `404` | Solicitação não encontrada |

---

### GET /api/solicitations

Lista todas as solicitações do usuário autenticado. Clientes veem as que criaram; chefs veem as recebidas.

**Response `200 OK`**
```json
[
  {
    "id": "c3d4e5f6-0000-0000-0000-000000000003",
    "clientId": "a1b2c3d4-0000-0000-0000-000000000001",
    "chefId": "b2c3d4e5-0000-0000-0000-000000000002",
    "status": "AWAITING_PROPOSAL",
    "briefing": { "..." },
    "currentProposal": null,
    "proposalHistory": [],
    "createdAt": "2026-05-11T12:30:00Z",
    "updatedAt": "2026-05-11T12:30:00Z"
  }
]
```

---

### POST /api/solicitations/{id}/proposals

Chef envia proposta para uma solicitação em `AWAITING_PROPOSAL`. Exclusivo para `CHEF`.

**Path param:** `id` — UUID da solicitação

**Request**
```json
{
  "totalAmount": 850.00,
  "serviceDescription": "Menu degustação italiano 5 tempos com harmonização",
  "validUntil": "2026-05-18",
  "notes": "Inclui deslocamento e ingredientes"
}
```

> `totalAmount`: mínimo `0.01`

**Response `200 OK`** — retorna a solicitação atualizada com `status: "PROPOSAL_SENT"` e `currentProposal` preenchida.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `400` | Campos inválidos |
| `403` | Usuário não é o chef da solicitação ou não é `CHEF` |
| `404` | Solicitação não encontrada |
| `409` | Solicitação não está em `AWAITING_PROPOSAL` |

---

### POST /api/solicitations/{id}/proposals/accept

Cliente aceita a proposta atual. Exclusivo para `CLIENT`. Transição: `PROPOSAL_SENT` → `RESERVATION_CONFIRMED`.

**Path param:** `id` — UUID da solicitação

**Response `200 OK`** — retorna a solicitação com `status: "RESERVATION_CONFIRMED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente da solicitação |
| `404` | Solicitação não encontrada |
| `409` | Solicitação não está em `PROPOSAL_SENT` |

---

### POST /api/solicitations/{id}/proposals/reject

Cliente rejeita a proposta. Exclusivo para `CLIENT`. Transição: `PROPOSAL_SENT` → `CANCELLED`.

**Path param:** `id` — UUID da solicitação

**Response `200 OK`** — retorna a solicitação com `status: "CANCELLED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente da solicitação |
| `404` | Solicitação não encontrada |
| `409` | Solicitação não está em `PROPOSAL_SENT` |

---

### POST /api/solicitations/{id}/proposals/request-revision

Cliente solicita revisão da proposta. Exclusivo para `CLIENT`. Transição: `PROPOSAL_SENT` → `AWAITING_PROPOSAL`.

**Path param:** `id` — UUID da solicitação

**Response `200 OK`** — retorna a solicitação com `status: "AWAITING_PROPOSAL"` e a proposta rejeitada movida para `proposalHistory`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente da solicitação |
| `404` | Solicitação não encontrada |
| `409` | Solicitação não está em `PROPOSAL_SENT` |

---

### POST /api/solicitations/{id}/complete

Cliente marca o serviço como concluído. Exclusivo para `CLIENT`. Transição: `RESERVATION_CONFIRMED` → `SERVICE_COMPLETED`.

**Path param:** `id` — UUID da solicitação

**Response `200 OK`** — retorna a solicitação com `status: "SERVICE_COMPLETED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é o cliente da solicitação |
| `404` | Solicitação não encontrada |
| `409` | Solicitação não está em `RESERVATION_CONFIRMED` |

---

### POST /api/solicitations/{id}/cancel

Cancela a solicitação. Disponível para cliente e chef. Transição: qualquer status não-terminal → `CANCELLED`.

**Path param:** `id` — UUID da solicitação

**Response `200 OK`** — retorna a solicitação com `status: "CANCELLED"`.

**Erros possíveis**

| Status | Motivo |
|--------|--------|
| `403` | Usuário não é parte desta solicitação |
| `404` | Solicitação não encontrada |
| `409` | Solicitação já está em estado terminal (`CANCELLED` ou `SERVICE_COMPLETED`) |

---

## Resumo dos Endpoints

| Método | Path | Auth | Perfil |
|--------|------|------|--------|
| `POST` | `/api/auth/register` | Não | — |
| `POST` | `/api/auth/login` | Não | — |
| `POST` | `/api/auth/refresh` | Não | — |
| `GET` | `/api/users/{id}` | JWT | próprio usuário |
| `POST` | `/api/solicitations` | JWT | `CLIENT` |
| `GET` | `/api/solicitations` | JWT | `CLIENT` ou `CHEF` |
| `GET` | `/api/solicitations/{id}` | JWT | `CLIENT` ou `CHEF` |
| `POST` | `/api/solicitations/{id}/proposals` | JWT | `CHEF` |
| `POST` | `/api/solicitations/{id}/proposals/accept` | JWT | `CLIENT` |
| `POST` | `/api/solicitations/{id}/proposals/reject` | JWT | `CLIENT` |
| `POST` | `/api/solicitations/{id}/proposals/request-revision` | JWT | `CLIENT` |
| `POST` | `/api/solicitations/{id}/complete` | JWT | `CLIENT` |
| `POST` | `/api/solicitations/{id}/cancel` | JWT | `CLIENT` ou `CHEF` |
