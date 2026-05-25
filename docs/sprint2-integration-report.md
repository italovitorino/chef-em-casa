# Relatório de Integração — Sprint 2: Middleware Orientado a Mensagens

## Escolha da Ferramenta

O sistema utiliza **RabbitMQ 3.13** como middleware orientado a mensagens (MOM). A escolha
se justifica pela ampla adoção industrial, suporte nativo ao protocolo AMQP 0-9-1, painel de
administração web integrado e integração direta com Spring Boot via `spring-boot-starter-amqp`.
O broker é provisionado via Podman Compose, garantindo ambiente reproduzível em
desenvolvimento.

## Padrão Utilizado: Topic Exchange + Pub/Sub

Adotou-se o padrão **Topic Exchange**, que roteia mensagens com base em chaves compostas
por segmentos separados por ponto (ex.: `solicitations.briefing.submitted`). Esse modelo
permite filtrar eventos por contexto de domínio (`identity.*`, `solicitations.*`) e adicionar
novos consumidores sem qualquer alteração nos produtores — princípio fundamental de
arquiteturas orientadas a eventos.

### Topologia

- **Exchange:** `chefemcasa.events` (TopicExchange, durável)
- **Filas declaradas:**

| Fila | Binding (routing key) | Consumidor |
|------|-----------------------|------------|
| `chefemcasa.identity.welcome-email` | `identity.user.registered` | `WelcomeEmailConsumer` |
| `chefemcasa.solicitations.new-solicitation` | `solicitations.briefing.submitted` | `NewSolicitationConsumer` |

### Produtores

Os eventos são publicados pelos serviços de aplicação imediatamente após a persistência,
via `RabbitTemplate.convertAndSend()` com serialização Jackson (JSON):

| Serviço | Evento publicado | Routing Key |
|---------|-----------------|-------------|
| `AuthService` | `UserRegistered` | `identity.user.registered` |
| `SolicitationService` | `BriefingSubmitted` | `solicitations.briefing.submitted` |
| `SolicitationService` | `ProposalSent` | `solicitations.proposal.sent` |
| `SolicitationService` | `ProposalAccepted` | `solicitations.proposal.accepted` |
| `SolicitationService` | `ProposalRejected` | `solicitations.proposal.rejected` |
| `SolicitationService` | `ProposalRevisionRequested` | `solicitations.proposal.revision-requested` |
| `SolicitationService` | `ReservationConfirmed` | `solicitations.reservation.confirmed` |
| `SolicitationService` | `ServiceCompleted` | `solicitations.service.completed` |
| `SolicitationService` | `SolicitationCancelled` | `solicitations.solicitation.cancelled` |

### Consumidores (Sprint 2)

| Consumidor | Fila | Ação simulada |
|------------|------|---------------|
| `WelcomeEmailConsumer` | `chefemcasa.identity.welcome-email` | Loga envio de e-mail de boas-vindas ao novo usuário |
| `NewSolicitationConsumer` | `chefemcasa.solicitations.new-solicitation` | Loga notificação ao chef sobre nova solicitação recebida |

## Demonstração de Assincronicidade

A comunicação entre produtor e consumidor é completamente assíncrona: o endpoint REST
retorna a resposta HTTP ao cliente **antes** do consumidor processar o evento. Não existe
chamada direta entre `AuthService` e `WelcomeEmailConsumer` — o RabbitMQ é o único
intermediário. Essa separação é verificável nos logs da aplicação, onde a linha de resposta
HTTP precede a linha de log do consumidor.

**Exemplo de log observado após `POST /api/auth/register`:**
```
INFO  AuthController          : Usuário registrado com sucesso
INFO  WelcomeEmailConsumer    : [WELCOME-EMAIL] Enviando boas-vindas para joao@exemplo.com (userId=..., role=CLIENT)
```

## Desafios Encontrados

1. **Deserialização de Java Records:** O `Jackson2JsonMessageConverter` foi marcado como depreciado no Spring. A solução adotada foi usar o `JacksonJsonMessageConverter`.

2. **Permissão de arquivo no container RabbitMQ:** a primeira inicialização do ambiente, o container do RabbitMQ falhava ao subir, registrando erro `eacces` ao tentar acessar o arquivo `.erlang.cookie`. O sintoma era a interrupção imediata do broker, antes mesmo de o painel de administração ficar disponível. O diagnóstico apontou que o volume persistente montado pelo Podman havia preservado as permissões de uma execução anterior, feita sob um usuário (UID) diferente — condição que impedia o processo do RabbitMQ de ler o cookie de autenticação do cluster Erlang. A solução foi executar `podman compose down -v` para remover os volumes órfãos e recriar os containers a partir de um estado limpo, permitindo que o `.erlang.cookie` fosse gerado com as permissões corretas do usuário atual.

3. **Ausência de bindings anteriores:** A versão inicial de `RabbitMQConfig` declarava apenas
   o exchange e o `RabbitTemplate`, sem filas nem bindings. Sem bindings, as mensagens
   publicadas eram descartadas silenciosamente pelo broker. A adição explícita dos beans
   `Queue` e `Binding` resolveu o problema — Spring AMQP declara as estruturas no broker
   durante o startup da aplicação via `RabbitAdmin`.
