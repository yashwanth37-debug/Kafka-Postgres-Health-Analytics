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
    address_type                    VARCHAR(64),
    address_locality                JSONB,

    -- Household.additionalFields
    household_additional_fields     JSONB,

    -- Household.auditDetails
    created_by                      VARCHAR(64),
    last_modified_by                VARCHAR(64),
    created_time                    BIGINT,
    last_modified_time              BIGINT,

    -- Household.clientAuditDetails
    client_created_by               VARCHAR(64),
    client_last_modified_by         VARCHAR(64),
    client_created_time             BIGINT,
    client_last_modified_time       BIGINT,

    -- HouseholdIndexV1 top-level fields
    user_name                       VARCHAR(180),
    name_of_user                    VARCHAR(250),
    user_address                    VARCHAR(440),
    task_dates                      DATE,
    synced_date                     DATE,
    role                            VARCHAR(128),
    boundary_hierarchy              JSONB,
    boundary_hierarchy_code         JSONB,
    geo_point_lat                   DOUBLE PRECISION,
    geo_point_lon                   DOUBLE PRECISION,
    synced_time_stamp               TIMESTAMPTZ,
    synced_time                     BIGINT,
    additional_details              JSONB
);

CREATE TABLE IF NOT EXISTS household_member_enriched (
    -- HouseholdMember core fields
    id                                      VARCHAR(64),
    tenant_id                               VARCHAR(1000)   NOT NULL,
    client_reference_id                     VARCHAR(64)     NOT NULL,
    household_id                            VARCHAR(64),
    household_client_reference_id           VARCHAR(64),
    individual_id                           VARCHAR(64),
    individual_client_reference_id          VARCHAR(64),
    is_head_of_household                    BOOLEAN,
    is_deleted                              BOOLEAN,
    row_version                             INTEGER,

    -- HouseholdMember.additionalFields
    member_additional_fields                JSONB,

    -- HouseholdMember.auditDetails
    created_by                              VARCHAR(64),
    last_modified_by                        VARCHAR(64),
    created_time                            BIGINT,
    last_modified_time                      BIGINT,

    -- HouseholdMember.clientAuditDetails
    client_created_by                       VARCHAR(64),
    client_last_modified_by                 VARCHAR(64),
    client_created_time                     BIGINT,
    client_last_modified_time               BIGINT,

    -- HouseholdMemberIndexV1 top-level fields
    boundary_hierarchy                      JSONB,
    boundary_hierarchy_code                 JSONB,
    date_of_birth                           BIGINT,
    age                                     INTEGER,
    gender                                  VARCHAR(64),
    user_name                               VARCHAR(180),
    name_of_user                            VARCHAR(250),
    role                                    VARCHAR(128),
    user_address                            VARCHAR(440),
    task_dates                              DATE,
    synced_date                             DATE,
    synced_time_stamp                       TIMESTAMPTZ,
    geo_point_lat                           DOUBLE PRECISION,
    geo_point_lon                           DOUBLE PRECISION,
    locality_code                           VARCHAR(128),
    additional_details                      JSONB
);

CREATE TABLE IF NOT EXISTS project_beneficiary_enriched (
    -- ProjectBeneficiary core fields
    id                                      VARCHAR(64),
    tenant_id                               VARCHAR(64)     NOT NULL,
    project_id                              VARCHAR(64)     NOT NULL,
    beneficiary_id                          VARCHAR(64),
    beneficiary_client_reference_id         VARCHAR(64),
    client_reference_id                     VARCHAR(64),
    date_of_registration                    BIGINT,
    tag                                     VARCHAR(1000),
    is_deleted                              BOOLEAN,
    row_version                             INTEGER,

    -- ProjectBeneficiary.additionalFields
    beneficiary_additional_fields           JSONB,

    -- ProjectBeneficiary.auditDetails
    created_by                              VARCHAR(64),
    last_modified_by                        VARCHAR(64),
    created_time                            BIGINT,
    last_modified_time                      BIGINT,

    -- ProjectBeneficiary.clientAuditDetails
    client_created_by                       VARCHAR(64),
    client_last_modified_by                 VARCHAR(64),
    client_created_time                     BIGINT,
    client_last_modified_time               BIGINT,

    -- ProjectBeneficiaryIndexV1 top-level fields
    boundary_hierarchy                      JSONB,
    boundary_hierarchy_code                 JSONB,
    user_name                               VARCHAR(180),
    name_of_user                            VARCHAR(250),
    role                                    VARCHAR(128),
    user_address                            VARCHAR(440),
    task_dates                              DATE,
    synced_date                             DATE,
    synced_time_stamp                       TIMESTAMPTZ,
    additional_details                      JSONB
);
