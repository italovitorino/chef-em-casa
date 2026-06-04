CREATE TABLE negotiations.negotiations (
    id           UUID PRIMARY KEY,
    briefing_id  UUID        NOT NULL,
    client_id    UUID        NOT NULL,
    chef_id      UUID        NOT NULL,
    status       VARCHAR(50) NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL,
    updated_at   TIMESTAMPTZ NOT NULL
);

CREATE TABLE negotiations.proposals (
    id                  UUID PRIMARY KEY,
    negotiation_id      UUID           NOT NULL REFERENCES negotiations.negotiations(id),
    total_amount        NUMERIC(10, 2) NOT NULL,
    service_description TEXT           NOT NULL,
    valid_until         DATE           NOT NULL,
    notes               TEXT,
    sent_at             TIMESTAMPTZ    NOT NULL,
    is_current          BOOLEAN        NOT NULL DEFAULT false
);

CREATE INDEX idx_negotiations_briefing_id ON negotiations.negotiations(briefing_id);
CREATE INDEX idx_negotiations_client_id   ON negotiations.negotiations(client_id);
CREATE INDEX idx_negotiations_chef_id     ON negotiations.negotiations(chef_id);
CREATE INDEX idx_proposals_negotiation    ON negotiations.proposals(negotiation_id);
