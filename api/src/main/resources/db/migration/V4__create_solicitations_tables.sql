CREATE TABLE solicitations.solicitations (
    id                         UUID PRIMARY KEY,
    client_id                  UUID NOT NULL,
    chef_id                    UUID NOT NULL,
    status                     VARCHAR(50)  NOT NULL,
    event_type                 VARCHAR(50)  NOT NULL,
    event_date                 DATE         NOT NULL,
    number_of_guests           INT          NOT NULL,
    street                     VARCHAR(255) NOT NULL,
    number                     VARCHAR(20)  NOT NULL,
    city                       VARCHAR(100) NOT NULL,
    state                      VARCHAR(100) NOT NULL,
    zip_code                   VARCHAR(20)  NOT NULL,
    estimated_duration_minutes INT          NOT NULL,
    notes                      TEXT,
    created_at                 TIMESTAMPTZ  NOT NULL,
    updated_at                 TIMESTAMPTZ  NOT NULL
);

CREATE TABLE solicitations.proposals (
    id                  UUID PRIMARY KEY,
    solicitation_id     UUID           NOT NULL REFERENCES solicitations.solicitations(id),
    total_amount        NUMERIC(10, 2) NOT NULL,
    service_description TEXT           NOT NULL,
    valid_until         DATE           NOT NULL,
    notes               TEXT,
    sent_at             TIMESTAMPTZ    NOT NULL,
    is_current          BOOLEAN        NOT NULL DEFAULT false
);

CREATE INDEX idx_solicitations_client_id ON solicitations.solicitations(client_id);
CREATE INDEX idx_solicitations_chef_id   ON solicitations.solicitations(chef_id);
CREATE INDEX idx_proposals_solicitation  ON solicitations.proposals(solicitation_id);
