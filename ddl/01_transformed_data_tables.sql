CREATE TABLE IF NOT EXISTS household_enriched (
    -- Household core fields
    id                              VARCHAR(64),
    tenant_id                       VARCHAR(1000)       NOT NULL,
    client_reference_id             VARCHAR(64),
    member_count                    INTEGER             NOT NULL,
    is_deleted                      BOOLEAN,
    row_version                     INTEGER,

    -- Household.address (flattened)
    address_id                      VARCHAR(64),
    address_latitude                DOUBLE PRECISION,
    address_longitude               DOUBLE PRECISION,
    address_location_accuracy       DOUBLE PRECISION,
    address_type                    TEXT,
    address_locality                JSONB,

    -- Household.additionalFields
    household_additional_fields     JSONB,

    -- Household.auditDetails
    created_by                      TEXT,
    last_modified_by                TEXT,
    created_time                    BIGINT,
    last_modified_time              BIGINT,

    -- Household.clientAuditDetails
    client_created_by               TEXT,
    client_last_modified_by         TEXT,
    client_created_time             BIGINT,
    client_last_modified_time       BIGINT,

    -- HouseholdIndexV1 top-level fields
    user_name                       TEXT,
    name_of_user                    TEXT,
    user_address                    TEXT,
    task_dates                      DATE,
    synced_date                     TEXT,
    role                            TEXT,
    boundary_hierarchy              JSONB,
    synced_time_stamp               TIMESTAMPTZ,
    synced_time                     DATE,
    additional_details              JSONB
);
