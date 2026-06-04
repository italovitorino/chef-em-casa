# Chef em Casa

Marketplace para contratação de chefes de cozinha particulares. A plataforma conecta clientes que desejam um chef para eventos privados — jantares em casa, almoços, viagens e ocasiões especiais — com profissionais disponíveis para prestar o serviço.

O fluxo central começa quando o cliente publica um briefing aberto detalhando o evento (tipo, data, número de convidados, endereço e duração estimada). Chefs interessados expressam interesse no briefing, e o cliente pode iniciar negociações simultâneas com múltiplos chefs. Dentro de cada negociação, o chef envia uma proposta comercial e cliente e chef negociam: o cliente pode aceitar, rejeitar ou solicitar uma revisão da proposta. Ao aceitar uma proposta, a reserva é confirmada, o briefing é encerrado automaticamente e as demais negociações abertas são canceladas. Briefings sem proposta aceita expiram automaticamente após 72 horas. Ao término do serviço, o serviço é marcado como concluído.

## Stack

- **Backend**: Java 25 + Spring Boot 3.x
- **Mobile**: Flutter (iOS e Android)
- **Banco**: PostgreSQL
- **Mensageria**: RabbitMQ
- **Containerização**: Podman

## Como executar

### Pré-requisitos

- Podman e podman-compose

### 1. Configurar variáveis de ambiente

```bash
cd api
cp .env.example .env
```

Edite o `.env` conforme necessário. O `podman-compose` lê esse arquivo automaticamente ao subir os serviços.

### 2. Subir o stack completo

```bash
cd api
podman-compose up -d
```

Isso constrói a imagem da API e sobe o PostgreSQL, o RabbitMQ e a aplicação. O painel do RabbitMQ fica disponível em `http://localhost:15672` (usuário/senha definidos no `.env`). A API fica em `http://localhost:8080`.

### 3. Executar a API localmente (desenvolvimento)

Se preferir rodar a API fora do container (requer Java 25 e Maven):

```bash
cd api
podman-compose up -d db rabbitmq      # sobe apenas a infra
set -a && source .env && set +a       # exporta as variáveis para o shell
./mvnw spring-boot:run
```

### 4. Derrubar o stack

```bash
cd api
podman-compose down
```
