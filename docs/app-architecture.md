# Arquitetura do Aplicativo Flutter — Chef em Casa (Cliente)

## Visão Geral

O app segue uma arquitetura em camadas baseada nos princípios de Clean Architecture, adaptada para Flutter com Riverpod como gerenciador de estado.

```
┌─────────────────────────────────────────────────────────┐
│                        SCREENS                          │
│   (UI, navegação, consumo de estado via ConsumerWidget) │
└────────────────────────┬────────────────────────────────┘
                         │ watch / read
┌────────────────────────▼────────────────────────────────┐
│                      PROVIDERS                          │
│  (Riverpod Notifiers — estado, lógica de apresentação,  │
│   polling assíncrono via Timer.periodic)                │
└────────────────────────┬────────────────────────────────┘
                         │ chamada direta
┌────────────────────────▼────────────────────────────────┐
│                    REPOSITORIES                         │
│   (acesso à API REST via Dio — serialização/HTTP)       │
└────────────────────────┬────────────────────────────────┘
                         │ HTTP/JSON
┌────────────────────────▼────────────────────────────────┐
│                    BACKEND REST API                     │
│   (Spring Boot — endpoints /api/briefings, /api/auth,   │
│    /api/negotiations)                                   │
└─────────────────────────────────────────────────────────┘
```

## Camadas

### 1. Screens (`lib/screens/`)
Widgets Flutter responsáveis pela interface. Usam `ConsumerWidget` ou `ConsumerStatefulWidget` para acessar providers via `ref.watch`. Não contêm lógica de negócio.

| Tela | Responsabilidade |
|---|---|
| `WelcomeScreen` | Hero inicial com botões de login/cadastro |
| `LoginScreen` | Formulário de autenticação |
| `RegisterScreen` | Formulário de cadastro |
| `HomeScreen` | Navegação por abas (home, briefings, perfil) |
| `BriefingScreen` | Wizard de criação de briefing (7 passos) |
| `BriefingsScreen` | Listagem de briefings do cliente (3 abas) |
| `BriefingDetailScreen` | Detalhes do briefing + interesses de chefs + polling 15s |
| `NegotiationDetailScreen` | Estado da negociação + proposta + ações + polling 8s |
| `StartNegotiationScreen` | Tela de transição que inicia a negociação via API |
| `SuccessScreen` | Confirmação pós-ação |

### 2. Providers (`lib/features/*/presentation/`)
Gerenciam estado assíncrono usando Riverpod. Providers de detalhe implementam **polling automático** com `Timer.periodic` para atualizar o estado sem ação do usuário.

| Provider | Tipo | Polling | Responsabilidade |
|---|---|---|---|
| `authProvider` | `Notifier<AuthState>` | — | Login, registro, logout |
| `briefingNotifierProvider` | `Notifier<BriefingState>` | — | Criação de briefing |
| `briefingsListProvider` | `AsyncNotifier<List<BriefingListItem>>` | manual (pull) | Lista de briefings |
| `briefingDetailProvider(id)` | `FamilyAsyncNotifier` | **15s** | Detalhes + interesses do briefing |
| `negotiationProvider(id)` | `FamilyAsyncNotifier` | **8s** | Estado + proposta da negociação |

### 3. Repositories (`lib/features/*/data/`)
Encapsulam chamadas HTTP com Dio. Cada método mapeia para um endpoint REST. Lançam `AppException` em caso de erro para que os providers tratem adequadamente.

| Repository | Endpoints cobertos |
|---|---|
| `BriefingRepository` | `POST /api/briefings`, `GET /api/briefings`, `GET /api/briefings/{id}`, `POST /api/briefings/{id}/close` |
| `NegotiationRepository` | `POST /api/briefings/{id}/negotiations`, `GET /api/briefings/{id}/negotiations`, `GET /api/negotiations/{id}`, `POST /api/negotiations/{id}/proposals/accept`, `.../reject`, `.../request-revision`, `.../complete`, `.../cancel` |
| `AuthRepository` | `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/refresh` |

### 4. DTOs (`lib/features/*/data/*_dto.dart`)
Classes de transferência de dados com `fromJson` factories. Não contêm lógica de negócio — apenas mapeamento JSON → Dart.

## Fluxo de Atualização Assíncrona (Polling)

```
BriefingDetailScreen
    │
    │ ref.watch(briefingDetailProvider(id))
    │
    ▼
BriefingDetailNotifier
    │ build() → inicia Timer(15s)
    │
    ├── a cada 15s: ref.invalidateSelf() → re-fetch da API
    │
    └── onDispose() → timer.cancel()  (ao sair da tela)

NegotiationDetailScreen
    │
    │ ref.watch(negotiationProvider(id))
    │
    ▼
NegotiationNotifier
    │ build() → inicia Timer(8s)
    │
    ├── a cada 8s: ref.invalidateSelf() → re-fetch da API
    │
    └── onDispose() → timer.cancel()  (ao sair da tela)
```

Quando o **chef** (via app prestador ou Postman) envia uma proposta, o app do cliente detecta a mudança automaticamente no próximo ciclo de polling, sem nenhuma ação manual do usuário.

## Infraestrutura de Rede

- **Dio** com interceptor de token (`TokenInterceptor`)
- Renovação automática do access token via refresh token (401 → `/api/auth/refresh`)
- Tokens armazenados em `FlutterSecureStorage`
- Base URL configurada em `ApiConfig` (apontando para `10.0.2.2:8080` no emulador Android)

## Comunicação Assíncrona via MOM (RabbitMQ)

O backend publica eventos no RabbitMQ a cada ação do domínio. O app cliente não consome o MOM diretamente — usa polling REST como mecanismo equivalente (conforme permitido pela especificação da Sprint 3). A arquitetura backend já está orientada a eventos: aceitação de proposta, por exemplo, publica `ProposalAccepted` + `ReservationConfirmed` que disparam o fechamento automático do briefing e o cancelamento das demais negociações.
