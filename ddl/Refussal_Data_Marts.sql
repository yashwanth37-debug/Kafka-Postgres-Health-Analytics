-- ================================================================
-- OPTIMIZATION RECOMMENDATIONS: INDEXES
-- ================================================================

-- Critical: administration_status is the primary filter for nearly all KPIs
CREATE INDEX IF NOT EXISTS idx_task_admin_status
    ON project_task_enriched (administration_status);

-- JSONB functional indexes for frequent JSON field access
CREATE INDEX IF NOT EXISTS idx_task_reason
    ON project_task_enriched ((additional_details ->> 'reason'));

CREATE INDEX IF NOT EXISTS idx_task_refusal_reason
    ON project_task_enriched ((additional_details ->> 'refusalReason'))
    WHERE additional_details ->> 'reason' = 'REFUSED';

CREATE INDEX IF NOT EXISTS idx_task_absence_reason
    ON project_task_enriched ((additional_details ->> 'absenceReason'))
    WHERE additional_details ->> 'reason' = 'ABSENCE';

CREATE INDEX IF NOT EXISTS idx_task_settlement_type
    ON project_task_enriched ((additional_details ->> 'settlementType'));

-- Join acceleration
CREATE INDEX IF NOT EXISTS idx_task_beneficiary_ref
    ON project_task_enriched (project_beneficiary_client_reference_id);

CREATE INDEX IF NOT EXISTS idx_beneficiary_client_ref
    ON project_beneficiary_enriched (client_reference_id);

-- Hierarchy covering index for drill-down queries
CREATE INDEX IF NOT EXISTS idx_task_hierarchy
    ON project_task_enriched (campaign_id, country_code, province_code, district_code,
                              health_center_code, spp_code, village_code);

-- Ensure statistics are current for JSONB columns
ALTER TABLE project_task_enriched ALTER COLUMN additional_details SET STATISTICS 1000;
-- ANALYZE is usually run separately, but included here for completeness
-- ANALYZE project_task_enriched;


-- ================================================================
-- MATERIALIZED VIEWS (PostgreSQL) � Per-Level Strategy
-- This file contains the Data Mart structures for the 9 Vaccination KPIs.
-- Each view aggregates the base project_task_enriched data up to a specific
-- geographical boundary (Country, Province, District, Health Center, SPP, Village).
-- ================================================================

-- ---------------------------------------------------------------
-- KPI 1: Failed Visit Count
-- Business Rule: Total count of records where a vaccination could not be completed.
-- This includes explicit failures ('ADMINISTRATION_FAILED') and households that
-- were found closed ('CLOSED_HOUSEHOLD').
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi1_country AS
SELECT 
    campaign_id, 
    country_code, 
    COUNT(*) AS failed_visit_count
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')
GROUP BY campaign_id, country_code;

CREATE MATERIALIZED VIEW mv_kpi1_province AS
SELECT 
    campaign_id, 
    province_code, 
    COUNT(*) AS failed_visit_count
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')
GROUP BY campaign_id, province_code;

CREATE MATERIALIZED VIEW mv_kpi1_district AS
SELECT 
    campaign_id, 
    district_code, 
    COUNT(*) AS failed_visit_count
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')
GROUP BY campaign_id, district_code;

CREATE MATERIALIZED VIEW mv_kpi1_health_center AS
SELECT 
    campaign_id, 
    health_center_code, 
    COUNT(*) AS failed_visit_count
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')
GROUP BY campaign_id, health_center_code;

CREATE MATERIALIZED VIEW mv_kpi1_spp AS
SELECT 
    campaign_id, 
    spp_code, 
    COUNT(*) AS failed_visit_count
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')
GROUP BY campaign_id, spp_code;

CREATE MATERIALIZED VIEW mv_kpi1_village AS
SELECT 
    campaign_id, 
    village_code, 
    COUNT(*) AS failed_visit_count
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')
GROUP BY campaign_id, village_code;

-- ---------------------------------------------------------------
-- KPI 2: Refusal Rate
-- Business Rule: What share of unique children were actively refused by caregivers?
-- Numerator: Unique children where visit failed and reason was 'REFUSED'.
-- Denominator: Total unique children visited in the campaign.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi2_country AS
SELECT
    t.campaign_id,
    t.country_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                  AND t.additional_details ->> 'reason' = 'REFUSED')
        AS refused_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                      AND t.additional_details ->> 'reason' = 'REFUSED')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.country_code;

CREATE MATERIALIZED VIEW mv_kpi2_province AS
SELECT
    t.campaign_id,
    t.province_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                  AND t.additional_details ->> 'reason' = 'REFUSED')
        AS refused_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                      AND t.additional_details ->> 'reason' = 'REFUSED')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.province_code;

CREATE MATERIALIZED VIEW mv_kpi2_district AS
SELECT
    t.campaign_id,
    t.district_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                  AND t.additional_details ->> 'reason' = 'REFUSED')
        AS refused_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                      AND t.additional_details ->> 'reason' = 'REFUSED')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.district_code;

CREATE MATERIALIZED VIEW mv_kpi2_health_center AS
SELECT
    t.campaign_id,
    t.health_center_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                  AND t.additional_details ->> 'reason' = 'REFUSED')
        AS refused_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                      AND t.additional_details ->> 'reason' = 'REFUSED')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.health_center_code;

CREATE MATERIALIZED VIEW mv_kpi2_spp AS
SELECT
    t.campaign_id,
    t.spp_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                  AND t.additional_details ->> 'reason' = 'REFUSED')
        AS refused_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                      AND t.additional_details ->> 'reason' = 'REFUSED')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.spp_code;

CREATE MATERIALIZED VIEW mv_kpi2_village AS
SELECT
    t.campaign_id,
    t.village_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                  AND t.additional_details ->> 'reason' = 'REFUSED')
        AS refused_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE t.administration_status = 'ADMINISTRATION_FAILED'
                      AND t.additional_details ->> 'reason' = 'REFUSED')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.village_code;

-- ---------------------------------------------------------------
-- KPI 3: Absence Rate
-- Business Rule: What share of unique children were absent at time of visit?
-- Numerator: Unique children where reason is 'ABSENCE' or household was closed.
-- Denominator: Total unique children visited.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi3_country AS
SELECT
    t.campaign_id,
    t.country_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                       AND t.additional_details ->> 'reason' = 'ABSENCE')
                   OR t.administration_status = 'CLOSED_HOUSEHOLD')
        AS absent_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                           AND t.additional_details ->> 'reason' = 'ABSENCE')
                       OR t.administration_status = 'CLOSED_HOUSEHOLD')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS absence_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.country_code;

CREATE MATERIALIZED VIEW mv_kpi3_province AS
SELECT
    t.campaign_id,
    t.province_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                       AND t.additional_details ->> 'reason' = 'ABSENCE')
                   OR t.administration_status = 'CLOSED_HOUSEHOLD')
        AS absent_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                           AND t.additional_details ->> 'reason' = 'ABSENCE')
                       OR t.administration_status = 'CLOSED_HOUSEHOLD')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS absence_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.province_code;

CREATE MATERIALIZED VIEW mv_kpi3_district AS
SELECT
    t.campaign_id,
    t.district_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                       AND t.additional_details ->> 'reason' = 'ABSENCE')
                   OR t.administration_status = 'CLOSED_HOUSEHOLD')
        AS absent_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                           AND t.additional_details ->> 'reason' = 'ABSENCE')
                       OR t.administration_status = 'CLOSED_HOUSEHOLD')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS absence_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.district_code;

CREATE MATERIALIZED VIEW mv_kpi3_health_center AS
SELECT
    t.campaign_id,
    t.health_center_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                       AND t.additional_details ->> 'reason' = 'ABSENCE')
                   OR t.administration_status = 'CLOSED_HOUSEHOLD')
        AS absent_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                           AND t.additional_details ->> 'reason' = 'ABSENCE')
                       OR t.administration_status = 'CLOSED_HOUSEHOLD')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS absence_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.health_center_code;

CREATE MATERIALIZED VIEW mv_kpi3_spp AS
SELECT
    t.campaign_id,
    t.spp_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                       AND t.additional_details ->> 'reason' = 'ABSENCE')
                   OR t.administration_status = 'CLOSED_HOUSEHOLD')
        AS absent_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                           AND t.additional_details ->> 'reason' = 'ABSENCE')
                       OR t.administration_status = 'CLOSED_HOUSEHOLD')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS absence_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.spp_code;

CREATE MATERIALIZED VIEW mv_kpi3_village AS
SELECT
    t.campaign_id,
    t.village_code,
    COUNT(DISTINCT pb.beneficiary_id)
        FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                       AND t.additional_details ->> 'reason' = 'ABSENCE')
                   OR t.administration_status = 'CLOSED_HOUSEHOLD')
        AS absent_beneficiaries,
    COUNT(DISTINCT pb.beneficiary_id) AS total_beneficiaries,
    ROUND(
        COUNT(DISTINCT pb.beneficiary_id)
            FILTER (WHERE (t.administration_status = 'ADMINISTRATION_FAILED'
                           AND t.additional_details ->> 'reason' = 'ABSENCE')
                       OR t.administration_status = 'CLOSED_HOUSEHOLD')
        * 100.0
        / NULLIF(COUNT(DISTINCT pb.beneficiary_id), 0), 2
    ) AS absence_rate_pct
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
GROUP BY t.campaign_id, t.village_code;

-- ---------------------------------------------------------------
-- KPI 4: Refusal Breakdown
-- Business Rule: What are the most common reasons for refusal?
-- Extracts the 'refusalReason' from the JSON payload for deeper analysis.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi4_country AS
SELECT
    campaign_id,
    country_code,
    COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown') AS refusal_reason,
    COUNT(*) AS refusal_count
FROM project_task_enriched
WHERE administration_status = 'ADMINISTRATION_FAILED'
  AND additional_details ->> 'reason' = 'REFUSED'
GROUP BY campaign_id, country_code, COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown')
ORDER BY refusal_count DESC;

CREATE MATERIALIZED VIEW mv_kpi4_province AS
SELECT
    campaign_id,
    province_code,
    COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown') AS refusal_reason,
    COUNT(*) AS refusal_count
FROM project_task_enriched
WHERE administration_status = 'ADMINISTRATION_FAILED'
  AND additional_details ->> 'reason' = 'REFUSED'
GROUP BY campaign_id, province_code, COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown')
ORDER BY refusal_count DESC;

CREATE MATERIALIZED VIEW mv_kpi4_district AS
SELECT
    campaign_id,
    district_code,
    COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown') AS refusal_reason,
    COUNT(*) AS refusal_count
FROM project_task_enriched
WHERE administration_status = 'ADMINISTRATION_FAILED'
  AND additional_details ->> 'reason' = 'REFUSED'
GROUP BY campaign_id, district_code, COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown')
ORDER BY refusal_count DESC;

CREATE MATERIALIZED VIEW mv_kpi4_health_center AS
SELECT
    campaign_id,
    health_center_code,
    COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown') AS refusal_reason,
    COUNT(*) AS refusal_count
FROM project_task_enriched
WHERE administration_status = 'ADMINISTRATION_FAILED'
  AND additional_details ->> 'reason' = 'REFUSED'
GROUP BY campaign_id, health_center_code, COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown')
ORDER BY refusal_count DESC;

CREATE MATERIALIZED VIEW mv_kpi4_spp AS
SELECT
    campaign_id,
    spp_code,
    COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown') AS refusal_reason,
    COUNT(*) AS refusal_count
FROM project_task_enriched
WHERE administration_status = 'ADMINISTRATION_FAILED'
  AND additional_details ->> 'reason' = 'REFUSED'
GROUP BY campaign_id, spp_code, COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown')
ORDER BY refusal_count DESC;

CREATE MATERIALIZED VIEW mv_kpi4_village AS
SELECT
    campaign_id,
    village_code,
    COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown') AS refusal_reason,
    COUNT(*) AS refusal_count
FROM project_task_enriched
WHERE administration_status = 'ADMINISTRATION_FAILED'
  AND additional_details ->> 'reason' = 'REFUSED'
GROUP BY campaign_id, village_code, COALESCE(NULLIF(TRIM(additional_details ->> 'refusalReason'), ''), 'Unknown')
ORDER BY refusal_count DESC;

-- ---------------------------------------------------------------
-- KPI 5: Absence Breakdown
-- Business Rule: What are the most common reasons for absence?
-- Groups by 'absenceReason' JSON field or 'CLOSED_HOUSEHOLD'.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi5_country AS
SELECT
    campaign_id,
    country_code,
    CASE
        WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
        ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED')
    END AS absence_category,
    COUNT(*) AS absence_count
FROM project_task_enriched
WHERE additional_details ->> 'reason' = 'ABSENCE'
   OR administration_status = 'CLOSED_HOUSEHOLD'
GROUP BY campaign_id, country_code, 
    CASE WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
         ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED') END
ORDER BY absence_count DESC;

CREATE MATERIALIZED VIEW mv_kpi5_province AS
SELECT
    campaign_id,
    province_code,
    CASE
        WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
        ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED')
    END AS absence_category,
    COUNT(*) AS absence_count
FROM project_task_enriched
WHERE additional_details ->> 'reason' = 'ABSENCE'
   OR administration_status = 'CLOSED_HOUSEHOLD'
GROUP BY campaign_id, province_code, 
    CASE WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
         ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED') END
ORDER BY absence_count DESC;

CREATE MATERIALIZED VIEW mv_kpi5_district AS
SELECT
    campaign_id,
    district_code,
    CASE
        WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
        ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED')
    END AS absence_category,
    COUNT(*) AS absence_count
FROM project_task_enriched
WHERE additional_details ->> 'reason' = 'ABSENCE'
   OR administration_status = 'CLOSED_HOUSEHOLD'
GROUP BY campaign_id, district_code, 
    CASE WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
         ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED') END
ORDER BY absence_count DESC;

CREATE MATERIALIZED VIEW mv_kpi5_health_center AS
SELECT
    campaign_id,
    health_center_code,
    CASE
        WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
        ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED')
    END AS absence_category,
    COUNT(*) AS absence_count
FROM project_task_enriched
WHERE additional_details ->> 'reason' = 'ABSENCE'
   OR administration_status = 'CLOSED_HOUSEHOLD'
GROUP BY campaign_id, health_center_code, 
    CASE WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
         ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED') END
ORDER BY absence_count DESC;

CREATE MATERIALIZED VIEW mv_kpi5_spp AS
SELECT
    campaign_id,
    spp_code,
    CASE
        WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
        ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED')
    END AS absence_category,
    COUNT(*) AS absence_count
FROM project_task_enriched
WHERE additional_details ->> 'reason' = 'ABSENCE'
   OR administration_status = 'CLOSED_HOUSEHOLD'
GROUP BY campaign_id, spp_code, 
    CASE WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
         ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED') END
ORDER BY absence_count DESC;

CREATE MATERIALIZED VIEW mv_kpi5_village AS
SELECT
    campaign_id,
    village_code,
    CASE
        WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
        ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED')
    END AS absence_category,
    COUNT(*) AS absence_count
FROM project_task_enriched
WHERE additional_details ->> 'reason' = 'ABSENCE'
   OR administration_status = 'CLOSED_HOUSEHOLD'
GROUP BY campaign_id, village_code, 
    CASE WHEN administration_status = 'CLOSED_HOUSEHOLD' THEN 'CLOSED_HOUSEHOLD'
         ELSE COALESCE(NULLIF(TRIM(additional_details ->> 'absenceReason'), ''), 'UNSPECIFIED') END
ORDER BY absence_count DESC;

-- ---------------------------------------------------------------
-- KPI 6: Refusal Rate by District (Single Level)
-- Business Rule: Which districts have the highest refusal rates?
-- Note: By design, this is only calculated at the district level.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi6_district AS
SELECT
    campaign_id,
    district_code,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE district_code IS NOT NULL
GROUP BY campaign_id, district_code;

-- ---------------------------------------------------------------
-- KPI 7: Refusal Rate by Settlement Type
-- Business Rule: Are refusals clustering in specific settlement types?
-- Extracts 'settlementType' from the task JSON details.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi7_country AS
SELECT
    campaign_id,
    country_code,
    additional_details ->> 'settlementType' AS settlement_type,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE additional_details ->> 'settlementType' IS NOT NULL
GROUP BY campaign_id, country_code, additional_details ->> 'settlementType';

CREATE MATERIALIZED VIEW mv_kpi7_province AS
SELECT
    campaign_id,
    province_code,
    additional_details ->> 'settlementType' AS settlement_type,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE additional_details ->> 'settlementType' IS NOT NULL
GROUP BY campaign_id, province_code, additional_details ->> 'settlementType';

CREATE MATERIALIZED VIEW mv_kpi7_district AS
SELECT
    campaign_id,
    district_code,
    additional_details ->> 'settlementType' AS settlement_type,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE additional_details ->> 'settlementType' IS NOT NULL
GROUP BY campaign_id, district_code, additional_details ->> 'settlementType';

CREATE MATERIALIZED VIEW mv_kpi7_health_center AS
SELECT
    campaign_id,
    health_center_code,
    additional_details ->> 'settlementType' AS settlement_type,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE additional_details ->> 'settlementType' IS NOT NULL
GROUP BY campaign_id, health_center_code, additional_details ->> 'settlementType';

CREATE MATERIALIZED VIEW mv_kpi7_spp AS
SELECT
    campaign_id,
    spp_code,
    additional_details ->> 'settlementType' AS settlement_type,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE additional_details ->> 'settlementType' IS NOT NULL
GROUP BY campaign_id, spp_code, additional_details ->> 'settlementType';

CREATE MATERIALIZED VIEW mv_kpi7_village AS
SELECT
    campaign_id,
    village_code,
    additional_details ->> 'settlementType' AS settlement_type,
    COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                       AND additional_details ->> 'reason' = 'REFUSED') AS refusal_count,
    COUNT(*) AS total_records,
    ROUND(
        COUNT(*) FILTER (WHERE administration_status = 'ADMINISTRATION_FAILED'
                           AND additional_details ->> 'reason' = 'REFUSED')
        * 100.0 / NULLIF(COUNT(*), 0), 2
    ) AS refusal_rate_pct
FROM project_task_enriched
WHERE additional_details ->> 'settlementType' IS NOT NULL
GROUP BY campaign_id, village_code, additional_details ->> 'settlementType';

-- ---------------------------------------------------------------
-- KPI 8: Revisit Success Rate
-- Business Rule: Of children initially missed, how many were reached on revisit?
-- 'VISITED' implies a successful revisit. Failures are 'CLOSED_HOUSEHOLD' or 'ADMINISTRATION_FAILED'.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi8_country AS
SELECT
    campaign_id,
    country_code,
    COUNT(*) FILTER (WHERE administration_status = 'VISITED') AS visited_count,
    COUNT(*) FILTER (WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')) AS failed_count,
    COUNT(*) AS total_revisit_records,
    ROUND(COUNT(*) FILTER (WHERE administration_status = 'VISITED') * 100.0 / NULLIF(COUNT(*), 0), 2) AS revisit_success_rate_pct
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED', 'VISITED')
GROUP BY campaign_id, country_code;

CREATE MATERIALIZED VIEW mv_kpi8_province AS
SELECT
    campaign_id,
    province_code,
    COUNT(*) FILTER (WHERE administration_status = 'VISITED') AS visited_count,
    COUNT(*) FILTER (WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')) AS failed_count,
    COUNT(*) AS total_revisit_records,
    ROUND(COUNT(*) FILTER (WHERE administration_status = 'VISITED') * 100.0 / NULLIF(COUNT(*), 0), 2) AS revisit_success_rate_pct
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED', 'VISITED')
GROUP BY campaign_id, province_code;

CREATE MATERIALIZED VIEW mv_kpi8_district AS
SELECT
    campaign_id,
    district_code,
    COUNT(*) FILTER (WHERE administration_status = 'VISITED') AS visited_count,
    COUNT(*) FILTER (WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')) AS failed_count,
    COUNT(*) AS total_revisit_records,
    ROUND(COUNT(*) FILTER (WHERE administration_status = 'VISITED') * 100.0 / NULLIF(COUNT(*), 0), 2) AS revisit_success_rate_pct
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED', 'VISITED')
GROUP BY campaign_id, district_code;

CREATE MATERIALIZED VIEW mv_kpi8_health_center AS
SELECT
    campaign_id,
    health_center_code,
    COUNT(*) FILTER (WHERE administration_status = 'VISITED') AS visited_count,
    COUNT(*) FILTER (WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')) AS failed_count,
    COUNT(*) AS total_revisit_records,
    ROUND(COUNT(*) FILTER (WHERE administration_status = 'VISITED') * 100.0 / NULLIF(COUNT(*), 0), 2) AS revisit_success_rate_pct
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED', 'VISITED')
GROUP BY campaign_id, health_center_code;

CREATE MATERIALIZED VIEW mv_kpi8_spp AS
SELECT
    campaign_id,
    spp_code,
    COUNT(*) FILTER (WHERE administration_status = 'VISITED') AS visited_count,
    COUNT(*) FILTER (WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')) AS failed_count,
    COUNT(*) AS total_revisit_records,
    ROUND(COUNT(*) FILTER (WHERE administration_status = 'VISITED') * 100.0 / NULLIF(COUNT(*), 0), 2) AS revisit_success_rate_pct
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED', 'VISITED')
GROUP BY campaign_id, spp_code;

CREATE MATERIALIZED VIEW mv_kpi8_village AS
SELECT
    campaign_id,
    village_code,
    COUNT(*) FILTER (WHERE administration_status = 'VISITED') AS visited_count,
    COUNT(*) FILTER (WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED')) AS failed_count,
    COUNT(*) AS total_revisit_records,
    ROUND(COUNT(*) FILTER (WHERE administration_status = 'VISITED') * 100.0 / NULLIF(COUNT(*), 0), 2) AS revisit_success_rate_pct
FROM project_task_enriched
WHERE administration_status IN ('CLOSED_HOUSEHOLD', 'ADMINISTRATION_FAILED', 'VISITED')
GROUP BY campaign_id, village_code;

-- ---------------------------------------------------------------
-- KPI 9: Multi-Unsuccessful Revisit Beneficiaries
-- Business Rule: How many children remain unvaccinated after all revisit attempts?
-- Uses a CTE to find beneficiaries with >1 visit attempt, but ZERO successful visits.
-- ---------------------------------------------------------------
CREATE MATERIALIZED VIEW mv_kpi9_country AS
WITH unsuccessful_beneficiaries AS (
    SELECT pb.beneficiary_id
    FROM project_task_enriched t
    JOIN project_beneficiary_enriched pb
      ON t.project_beneficiary_client_reference_id = pb.client_reference_id
    GROUP BY pb.beneficiary_id
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (WHERE t.administration_status = 'VISITED') = 0
       AND COUNT(*) FILTER (WHERE t.administration_status = 'ADMINISTRATION_SUCCESS') = 0
)
SELECT t.campaign_id, t.country_code,
       COUNT(DISTINCT pb.beneficiary_id) AS multi_unsuccessful_beneficiaries
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
WHERE pb.beneficiary_id IN (SELECT beneficiary_id FROM unsuccessful_beneficiaries)
GROUP BY t.campaign_id, t.country_code;

CREATE MATERIALIZED VIEW mv_kpi9_province AS
WITH unsuccessful_beneficiaries AS (
    SELECT pb.beneficiary_id
    FROM project_task_enriched t
    JOIN project_beneficiary_enriched pb
      ON t.project_beneficiary_client_reference_id = pb.client_reference_id
    GROUP BY pb.beneficiary_id
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (WHERE t.administration_status = 'VISITED') = 0
       AND COUNT(*) FILTER (WHERE t.administration_status = 'ADMINISTRATION_SUCCESS') = 0
)
SELECT t.campaign_id, t.province_code,
       COUNT(DISTINCT pb.beneficiary_id) AS multi_unsuccessful_beneficiaries
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
WHERE pb.beneficiary_id IN (SELECT beneficiary_id FROM unsuccessful_beneficiaries)
GROUP BY t.campaign_id, t.province_code;

CREATE MATERIALIZED VIEW mv_kpi9_district AS
WITH unsuccessful_beneficiaries AS (
    SELECT pb.beneficiary_id
    FROM project_task_enriched t
    JOIN project_beneficiary_enriched pb
      ON t.project_beneficiary_client_reference_id = pb.client_reference_id
    GROUP BY pb.beneficiary_id
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (WHERE t.administration_status = 'VISITED') = 0
       AND COUNT(*) FILTER (WHERE t.administration_status = 'ADMINISTRATION_SUCCESS') = 0
)
SELECT t.campaign_id, t.district_code,
       COUNT(DISTINCT pb.beneficiary_id) AS multi_unsuccessful_beneficiaries
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
WHERE pb.beneficiary_id IN (SELECT beneficiary_id FROM unsuccessful_beneficiaries)
GROUP BY t.campaign_id, t.district_code;

CREATE MATERIALIZED VIEW mv_kpi9_health_center AS
WITH unsuccessful_beneficiaries AS (
    SELECT pb.beneficiary_id
    FROM project_task_enriched t
    JOIN project_beneficiary_enriched pb
      ON t.project_beneficiary_client_reference_id = pb.client_reference_id
    GROUP BY pb.beneficiary_id
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (WHERE t.administration_status = 'VISITED') = 0
       AND COUNT(*) FILTER (WHERE t.administration_status = 'ADMINISTRATION_SUCCESS') = 0
)
SELECT t.campaign_id, t.health_center_code,
       COUNT(DISTINCT pb.beneficiary_id) AS multi_unsuccessful_beneficiaries
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
WHERE pb.beneficiary_id IN (SELECT beneficiary_id FROM unsuccessful_beneficiaries)
GROUP BY t.campaign_id, t.health_center_code;

CREATE MATERIALIZED VIEW mv_kpi9_spp AS
WITH unsuccessful_beneficiaries AS (
    SELECT pb.beneficiary_id
    FROM project_task_enriched t
    JOIN project_beneficiary_enriched pb
      ON t.project_beneficiary_client_reference_id = pb.client_reference_id
    GROUP BY pb.beneficiary_id
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (WHERE t.administration_status = 'VISITED') = 0
       AND COUNT(*) FILTER (WHERE t.administration_status = 'ADMINISTRATION_SUCCESS') = 0
)
SELECT t.campaign_id, t.spp_code,
       COUNT(DISTINCT pb.beneficiary_id) AS multi_unsuccessful_beneficiaries
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
WHERE pb.beneficiary_id IN (SELECT beneficiary_id FROM unsuccessful_beneficiaries)
GROUP BY t.campaign_id, t.spp_code;

CREATE MATERIALIZED VIEW mv_kpi9_village AS
WITH unsuccessful_beneficiaries AS (
    SELECT pb.beneficiary_id
    FROM project_task_enriched t
    JOIN project_beneficiary_enriched pb
      ON t.project_beneficiary_client_reference_id = pb.client_reference_id
    GROUP BY pb.beneficiary_id
    HAVING COUNT(*) > 1
       AND COUNT(*) FILTER (WHERE t.administration_status = 'VISITED') = 0
       AND COUNT(*) FILTER (WHERE t.administration_status = 'ADMINISTRATION_SUCCESS') = 0
)
SELECT t.campaign_id, t.village_code,
       COUNT(DISTINCT pb.beneficiary_id) AS multi_unsuccessful_beneficiaries
FROM project_task_enriched t
JOIN project_beneficiary_enriched pb
  ON t.project_beneficiary_client_reference_id = pb.client_reference_id
WHERE pb.beneficiary_id IN (SELECT beneficiary_id FROM unsuccessful_beneficiaries)
GROUP BY t.campaign_id, t.village_code;



-- ================================================================
-- UNIQUE INDEXES FOR CONCURRENT REFRESH
-- ================================================================

CREATE UNIQUE INDEX idx_mv_kpi1_country_uniq ON mv_kpi1_country (campaign_id, country_code);
CREATE UNIQUE INDEX idx_mv_kpi1_province_uniq ON mv_kpi1_province (campaign_id, province_code);
CREATE UNIQUE INDEX idx_mv_kpi1_district_uniq ON mv_kpi1_district (campaign_id, district_code);
CREATE UNIQUE INDEX idx_mv_kpi1_health_center_uniq ON mv_kpi1_health_center (campaign_id, health_center_code);
CREATE UNIQUE INDEX idx_mv_kpi1_spp_uniq ON mv_kpi1_spp (campaign_id, spp_code);
CREATE UNIQUE INDEX idx_mv_kpi1_village_uniq ON mv_kpi1_village (campaign_id, village_code);
CREATE UNIQUE INDEX idx_mv_kpi2_country_uniq ON mv_kpi2_country (campaign_id, country_code);
CREATE UNIQUE INDEX idx_mv_kpi2_province_uniq ON mv_kpi2_province (campaign_id, province_code);
CREATE UNIQUE INDEX idx_mv_kpi2_district_uniq ON mv_kpi2_district (campaign_id, district_code);
CREATE UNIQUE INDEX idx_mv_kpi2_health_center_uniq ON mv_kpi2_health_center (campaign_id, health_center_code);
CREATE UNIQUE INDEX idx_mv_kpi2_spp_uniq ON mv_kpi2_spp (campaign_id, spp_code);
CREATE UNIQUE INDEX idx_mv_kpi2_village_uniq ON mv_kpi2_village (campaign_id, village_code);
CREATE UNIQUE INDEX idx_mv_kpi3_country_uniq ON mv_kpi3_country (campaign_id, country_code);
CREATE UNIQUE INDEX idx_mv_kpi3_province_uniq ON mv_kpi3_province (campaign_id, province_code);
CREATE UNIQUE INDEX idx_mv_kpi3_district_uniq ON mv_kpi3_district (campaign_id, district_code);
CREATE UNIQUE INDEX idx_mv_kpi3_health_center_uniq ON mv_kpi3_health_center (campaign_id, health_center_code);
CREATE UNIQUE INDEX idx_mv_kpi3_spp_uniq ON mv_kpi3_spp (campaign_id, spp_code);
CREATE UNIQUE INDEX idx_mv_kpi3_village_uniq ON mv_kpi3_village (campaign_id, village_code);
CREATE UNIQUE INDEX idx_mv_kpi4_country_uniq ON mv_kpi4_country (campaign_id, country_code, refusal_reason);
CREATE UNIQUE INDEX idx_mv_kpi4_province_uniq ON mv_kpi4_province (campaign_id, province_code, refusal_reason);
CREATE UNIQUE INDEX idx_mv_kpi4_district_uniq ON mv_kpi4_district (campaign_id, district_code, refusal_reason);
CREATE UNIQUE INDEX idx_mv_kpi4_health_center_uniq ON mv_kpi4_health_center (campaign_id, health_center_code, refusal_reason);
CREATE UNIQUE INDEX idx_mv_kpi4_spp_uniq ON mv_kpi4_spp (campaign_id, spp_code, refusal_reason);
CREATE UNIQUE INDEX idx_mv_kpi4_village_uniq ON mv_kpi4_village (campaign_id, village_code, refusal_reason);
CREATE UNIQUE INDEX idx_mv_kpi5_country_uniq ON mv_kpi5_country (campaign_id, country_code, absence_category);
CREATE UNIQUE INDEX idx_mv_kpi5_province_uniq ON mv_kpi5_province (campaign_id, province_code, absence_category);
CREATE UNIQUE INDEX idx_mv_kpi5_district_uniq ON mv_kpi5_district (campaign_id, district_code, absence_category);
CREATE UNIQUE INDEX idx_mv_kpi5_health_center_uniq ON mv_kpi5_health_center (campaign_id, health_center_code, absence_category);
CREATE UNIQUE INDEX idx_mv_kpi5_spp_uniq ON mv_kpi5_spp (campaign_id, spp_code, absence_category);
CREATE UNIQUE INDEX idx_mv_kpi5_village_uniq ON mv_kpi5_village (campaign_id, village_code, absence_category);
CREATE UNIQUE INDEX idx_mv_kpi6_district_uniq ON mv_kpi6_district (campaign_id, district_code);
CREATE UNIQUE INDEX idx_mv_kpi7_country_uniq ON mv_kpi7_country (campaign_id, country_code, settlement_type);
CREATE UNIQUE INDEX idx_mv_kpi7_province_uniq ON mv_kpi7_province (campaign_id, province_code, settlement_type);
CREATE UNIQUE INDEX idx_mv_kpi7_district_uniq ON mv_kpi7_district (campaign_id, district_code, settlement_type);
CREATE UNIQUE INDEX idx_mv_kpi7_health_center_uniq ON mv_kpi7_health_center (campaign_id, health_center_code, settlement_type);
CREATE UNIQUE INDEX idx_mv_kpi7_spp_uniq ON mv_kpi7_spp (campaign_id, spp_code, settlement_type);
CREATE UNIQUE INDEX idx_mv_kpi7_village_uniq ON mv_kpi7_village (campaign_id, village_code, settlement_type);
CREATE UNIQUE INDEX idx_mv_kpi8_country_uniq ON mv_kpi8_country (campaign_id, country_code);
CREATE UNIQUE INDEX idx_mv_kpi8_province_uniq ON mv_kpi8_province (campaign_id, province_code);
CREATE UNIQUE INDEX idx_mv_kpi8_district_uniq ON mv_kpi8_district (campaign_id, district_code);
CREATE UNIQUE INDEX idx_mv_kpi8_health_center_uniq ON mv_kpi8_health_center (campaign_id, health_center_code);
CREATE UNIQUE INDEX idx_mv_kpi8_spp_uniq ON mv_kpi8_spp (campaign_id, spp_code);
CREATE UNIQUE INDEX idx_mv_kpi8_village_uniq ON mv_kpi8_village (campaign_id, village_code);
CREATE UNIQUE INDEX idx_mv_kpi9_country_uniq ON mv_kpi9_country (campaign_id, country_code);
CREATE UNIQUE INDEX idx_mv_kpi9_province_uniq ON mv_kpi9_province (campaign_id, province_code);
CREATE UNIQUE INDEX idx_mv_kpi9_district_uniq ON mv_kpi9_district (campaign_id, district_code);
CREATE UNIQUE INDEX idx_mv_kpi9_health_center_uniq ON mv_kpi9_health_center (campaign_id, health_center_code);
CREATE UNIQUE INDEX idx_mv_kpi9_spp_uniq ON mv_kpi9_spp (campaign_id, spp_code);
CREATE UNIQUE INDEX idx_mv_kpi9_village_uniq ON mv_kpi9_village (campaign_id, village_code);


-- ================================================================
-- REFRESH STRATEGY (PostgreSQL pg_cron)
-- ================================================================

-- Schedule via pg_cron (example: every 30 minutes)
SELECT cron.schedule('refresh_kpi_views', '*/30 * * * *', $$
    -- KPI 1
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi1_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi1_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi1_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi1_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi1_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi1_village;
    
    -- KPI 2
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi2_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi2_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi2_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi2_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi2_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi2_village;
    
    -- KPI 3
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi3_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi3_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi3_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi3_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi3_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi3_village;
    
    -- KPI 4
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi4_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi4_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi4_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi4_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi4_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi4_village;
    
    -- KPI 5
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi5_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi5_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi5_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi5_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi5_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi5_village;
    
    -- KPI 6
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi6_district;
    
    -- KPI 7
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi7_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi7_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi7_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi7_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi7_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi7_village;
    
    -- KPI 8
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi8_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi8_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi8_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi8_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi8_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi8_village;
    
    -- KPI 9
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi9_country;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi9_province;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi9_district;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi9_health_center;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi9_spp;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_kpi9_village;
$$);


