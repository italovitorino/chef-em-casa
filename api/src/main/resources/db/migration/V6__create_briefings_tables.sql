CREATE TABLE briefings.briefings (
    id                         UUID PRIMARY KEY,
    client_id                  UUID         NOT NULL,
    status                     VARCHAR(20)  NOT NULL,
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
    expires_at                 TIMESTAMPTZ  NOT NULL,
    closed_at                  TIMESTAMPTZ
);

CREATE TABLE briefings.chef_interests (
    id           UUID PRIMARY KEY,
    briefing_id  UUID        NOT NULL REFERENCES briefings.briefings(id),
    chef_id      UUID        NOT NULL,
    expressed_at TIMESTAMPTZ NOT NULL,
    message      TEXT,
    UNIQUE (briefing_id, chef_id)
);

CREATE INDEX idx_briefings_client_id    ON briefings.briefings(client_id);
CREATE INDEX idx_briefings_status       ON briefings.briefings(status);
CREATE INDEX idx_briefings_expires_at   ON briefings.briefings(expires_at);
CREATE INDEX idx_chef_interests_briefing ON briefings.chef_interests(briefing_id);
