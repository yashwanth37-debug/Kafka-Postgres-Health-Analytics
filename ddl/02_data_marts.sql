--==========================================================================
    
    
                 -- DATA MART 1 
    
    
--==========================================================================

-- ============================================================================
-- 1. COUNTRY LEVEL COVERAGE MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_coverage_daily_country AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,

    -- Aggregations
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_SUCCESS' THEN 1 END) AS total_administered_successfully,
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_FAILED' THEN 1 END) AS could_not_vaccinate_count,
    COUNT(id) AS total_task_submissions
FROM project_task_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country';

CREATE UNIQUE INDEX idx_dm_cov_daily_country
    ON dm_coverage_daily_country(campaign_id, tenant_id, task_date, country_code);


-- ============================================================================
-- 2. PROVINCE LEVEL COVERAGE MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_coverage_daily_province AS
SELECT
    campaign_id, tenant_id, task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,

    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_SUCCESS' THEN 1 END) AS total_administered_successfully,
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_FAILED' THEN 1 END) AS could_not_vaccinate_count,
    COUNT(id) AS total_task_submissions
FROM project_task_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province';

CREATE UNIQUE INDEX idx_dm_cov_daily_province
    ON dm_coverage_daily_province(campaign_id, tenant_id, task_date, country_code, province_code);


-- ============================================================================
-- 3. DISTRICT LEVEL COVERAGE MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_coverage_daily_district AS
SELECT
    campaign_id, tenant_id, task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,

    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_SUCCESS' THEN 1 END) AS total_administered_successfully,
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_FAILED' THEN 1 END) AS could_not_vaccinate_count,
    COUNT(id) AS total_task_submissions
FROM project_task_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district';

CREATE UNIQUE INDEX idx_dm_cov_daily_district
    ON dm_coverage_daily_district(campaign_id, tenant_id, task_date, country_code, province_code, district_code);


-- ============================================================================
-- 4. HEALTH CENTER LEVEL COVERAGE MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_coverage_daily_healthcenter AS
SELECT
    campaign_id, tenant_id, task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,

    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_SUCCESS' THEN 1 END) AS total_administered_successfully,
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_FAILED' THEN 1 END) AS could_not_vaccinate_count,
    COUNT(id) AS total_task_submissions
FROM project_task_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter';

CREATE UNIQUE INDEX idx_dm_cov_daily_healthcenter
    ON dm_coverage_daily_healthcenter(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code);


-- ============================================================================
-- 5. SPP LEVEL COVERAGE MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_coverage_daily_spp AS
SELECT
    campaign_id, tenant_id, task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    boundary_hierarchy_code->>'spp' AS spp_code,

    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_SUCCESS' THEN 1 END) AS total_administered_successfully,
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_FAILED' THEN 1 END) AS could_not_vaccinate_count,
    COUNT(id) AS total_task_submissions
FROM project_task_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter',
    boundary_hierarchy_code->>'spp';

CREATE UNIQUE INDEX idx_dm_cov_daily_spp
    ON dm_coverage_daily_spp(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, spp_code);


-- ============================================================================
-- 6. VILLAGE LEVEL COVERAGE MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_coverage_daily_village AS
SELECT
    campaign_id, tenant_id, task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    boundary_hierarchy_code->>'spp' AS spp_code,
    boundary_hierarchy_code->>'village' AS village_code,

    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_SUCCESS' THEN 1 END) AS total_administered_successfully,
    COUNT(CASE WHEN administration_status = 'ADMINISTRATION_FAILED' THEN 1 END) AS could_not_vaccinate_count,
    COUNT(id) AS total_task_submissions
FROM project_task_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter',
    boundary_hierarchy_code->>'spp',
    boundary_hierarchy_code->>'village';

CREATE UNIQUE INDEX idx_dm_cov_daily_village
    ON dm_coverage_daily_village(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, spp_code, village_code);




--==========================================================================


                            -- DATA MART 2


--==========================================================================

-- ============================================================================
-- 1. COUNTRY LEVEL MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_registration_daily_country AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,

    COUNT(CASE WHEN age BETWEEN 0 AND 11 THEN 1 END) AS children_0_11m,
    COUNT(CASE WHEN age BETWEEN 12 AND 23 THEN 1 END) AS children_12_23m,
    COUNT(CASE WHEN age BETWEEN 24 AND 59 THEN 1 END) AS children_24_59m,
    COUNT(CASE WHEN UPPER(gender) = 'MALE' THEN 1 END) AS male_count,
    COUNT(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 END) AS female_count,
    COUNT(DISTINCT household_id) AS total_households
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country';

CREATE UNIQUE INDEX idx_dm_reg_daily_country
    ON dm_registration_daily_country(campaign_id, tenant_id, task_date, country_code);


-- ============================================================================
-- 2. PROVINCE LEVEL MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_registration_daily_province AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,

    COUNT(CASE WHEN age BETWEEN 0 AND 11 THEN 1 END) AS children_0_11m,
    COUNT(CASE WHEN age BETWEEN 12 AND 23 THEN 1 END) AS children_12_23m,
    COUNT(CASE WHEN age BETWEEN 24 AND 59 THEN 1 END) AS children_24_59m,
    COUNT(CASE WHEN UPPER(gender) = 'MALE' THEN 1 END) AS male_count,
    COUNT(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 END) AS female_count,
    COUNT(DISTINCT household_id) AS total_households
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province';

CREATE UNIQUE INDEX idx_dm_reg_daily_province
    ON dm_registration_daily_province(campaign_id, tenant_id, task_date, country_code, province_code);


-- ============================================================================
-- 3. DISTRICT LEVEL MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_registration_daily_district AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,

    COUNT(CASE WHEN age BETWEEN 0 AND 11 THEN 1 END) AS children_0_11m,
    COUNT(CASE WHEN age BETWEEN 12 AND 23 THEN 1 END) AS children_12_23m,
    COUNT(CASE WHEN age BETWEEN 24 AND 59 THEN 1 END) AS children_24_59m,
    COUNT(CASE WHEN UPPER(gender) = 'MALE' THEN 1 END) AS male_count,
    COUNT(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 END) AS female_count,
    COUNT(DISTINCT household_id) AS total_households
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district';

CREATE UNIQUE INDEX idx_dm_reg_daily_district
    ON dm_registration_daily_district(campaign_id, tenant_id, task_date, country_code, province_code, district_code);


-- ============================================================================
-- 4. HEALTH CENTER LEVEL MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_registration_daily_healthcenter AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,

    COUNT(CASE WHEN age BETWEEN 0 AND 11 THEN 1 END) AS children_0_11m,
    COUNT(CASE WHEN age BETWEEN 12 AND 23 THEN 1 END) AS children_12_23m,
    COUNT(CASE WHEN age BETWEEN 24 AND 59 THEN 1 END) AS children_24_59m,
    COUNT(CASE WHEN UPPER(gender) = 'MALE' THEN 1 END) AS male_count,
    COUNT(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 END) AS female_count,
    COUNT(DISTINCT household_id) AS total_households
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter';

CREATE UNIQUE INDEX idx_dm_reg_daily_healthcenter
    ON dm_registration_daily_healthcenter(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code);


-- ============================================================================
-- 5. SPP LEVEL MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_registration_daily_spp AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    boundary_hierarchy_code->>'spp' AS spp_code,

    COUNT(CASE WHEN age BETWEEN 0 AND 11 THEN 1 END) AS children_0_11m,
    COUNT(CASE WHEN age BETWEEN 12 AND 23 THEN 1 END) AS children_12_23m,
    COUNT(CASE WHEN age BETWEEN 24 AND 59 THEN 1 END) AS children_24_59m,
    COUNT(CASE WHEN UPPER(gender) = 'MALE' THEN 1 END) AS male_count,
    COUNT(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 END) AS female_count,
    COUNT(DISTINCT household_id) AS total_households
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter',
    boundary_hierarchy_code->>'spp';

CREATE UNIQUE INDEX idx_dm_reg_daily_spp
    ON dm_registration_daily_spp(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, spp_code);


-- ============================================================================
-- 6. VILLAGE LEVEL MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_registration_daily_village AS
SELECT
    campaign_id,
    tenant_id,
    task_dates AS task_date,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    boundary_hierarchy_code->>'spp' AS spp_code,
    boundary_hierarchy_code->>'village' AS village_code,

    COUNT(CASE WHEN age BETWEEN 0 AND 11 THEN 1 END) AS children_0_11m,
    COUNT(CASE WHEN age BETWEEN 12 AND 23 THEN 1 END) AS children_12_23m,
    COUNT(CASE WHEN age BETWEEN 24 AND 59 THEN 1 END) AS children_24_59m,
    COUNT(CASE WHEN UPPER(gender) = 'MALE' THEN 1 END) AS male_count,
    COUNT(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 END) AS female_count,
    COUNT(DISTINCT household_id) AS total_households
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id, tenant_id, task_dates,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter',
    boundary_hierarchy_code->>'spp',
    boundary_hierarchy_code->>'village';

CREATE UNIQUE INDEX idx_dm_reg_daily_village
    ON dm_registration_daily_village(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, spp_code, village_code);




--=================================================================================


                                -- DATA MART 3


--==================================================================================


-- ============================================================================
-- 1. COUNTRY LEVEL REFUSALS MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_refusals_daily_country AS
WITH total_tasks AS (
    SELECT
        campaign_id,
        tenant_id,
        task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        COUNT(id) AS total_task_submissions
    FROM project_task_enriched
    WHERE is_deleted = FALSE
    GROUP BY campaign_id, tenant_id, task_dates, boundary_hierarchy_code->>'country'
),
failed_tasks AS (
    SELECT
        campaign_id,
        tenant_id,
        task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        additional_details->>'reason_type' AS reason_type,
        additional_details->>'reason_code' AS reason_code,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'REFUSAL' THEN 1 END) AS refusal_count,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'ABSENCE' THEN 1 END) AS absence_count
    FROM project_task_enriched
    WHERE is_deleted = FALSE
      AND administration_status = 'ADMINISTRATION_FAILED'
    GROUP BY campaign_id, tenant_id, task_dates, boundary_hierarchy_code->>'country',
             additional_details->>'reason_type', additional_details->>'reason_code'
)
SELECT
    f.campaign_id, f.tenant_id, f.task_dates AS task_date,
    f.country_code,
    f.reason_type, f.reason_code, f.refusal_count, f.absence_count,
    COALESCE(t.total_task_submissions, 0) AS total_task_submissions
FROM failed_tasks f
         LEFT JOIN total_tasks t
                   ON f.campaign_id = t.campaign_id AND f.tenant_id = t.tenant_id AND f.task_dates = t.task_dates
                       AND f.country_code = t.country_code;

CREATE UNIQUE INDEX idx_dm_refusals_country
    ON dm_refusals_daily_country(campaign_id, tenant_id, task_date, country_code, reason_type, reason_code);


-- ============================================================================
-- 2. PROVINCE LEVEL REFUSALS MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_refusals_daily_province AS
WITH total_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        COUNT(id) AS total_task_submissions
    FROM project_task_enriched
    WHERE is_deleted = FALSE
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province'
),
failed_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        additional_details->>'reason_type' AS reason_type,
        additional_details->>'reason_code' AS reason_code,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'REFUSAL' THEN 1 END) AS refusal_count,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'ABSENCE' THEN 1 END) AS absence_count
    FROM project_task_enriched
    WHERE is_deleted = FALSE AND administration_status = 'ADMINISTRATION_FAILED'
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        additional_details->>'reason_type', additional_details->>'reason_code'
)
SELECT
    f.campaign_id, f.tenant_id, f.task_dates AS task_date,
    f.country_code, f.province_code,
    f.reason_type, f.reason_code, f.refusal_count, f.absence_count,
    COALESCE(t.total_task_submissions, 0) AS total_task_submissions
FROM failed_tasks f
         LEFT JOIN total_tasks t
                   ON f.campaign_id = t.campaign_id AND f.tenant_id = t.tenant_id AND f.task_dates = t.task_dates
                       AND f.country_code = t.country_code AND f.province_code = t.province_code;

CREATE UNIQUE INDEX idx_dm_refusals_province
    ON dm_refusals_daily_province(campaign_id, tenant_id, task_date, country_code, province_code, reason_type, reason_code);


-- ============================================================================
-- 3. DISTRICT LEVEL REFUSALS MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_refusals_daily_district AS
WITH total_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        COUNT(id) AS total_task_submissions
    FROM project_task_enriched
    WHERE is_deleted = FALSE
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district'
),
failed_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        additional_details->>'reason_type' AS reason_type,
        additional_details->>'reason_code' AS reason_code,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'REFUSAL' THEN 1 END) AS refusal_count,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'ABSENCE' THEN 1 END) AS absence_count
    FROM project_task_enriched
    WHERE is_deleted = FALSE AND administration_status = 'ADMINISTRATION_FAILED'
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        additional_details->>'reason_type', additional_details->>'reason_code'
)
SELECT
    f.campaign_id, f.tenant_id, f.task_dates AS task_date,
    f.country_code, f.province_code, f.district_code,
    f.reason_type, f.reason_code, f.refusal_count, f.absence_count,
    COALESCE(t.total_task_submissions, 0) AS total_task_submissions
FROM failed_tasks f
         LEFT JOIN total_tasks t
                   ON f.campaign_id = t.campaign_id AND f.tenant_id = t.tenant_id AND f.task_dates = t.task_dates
                       AND f.country_code = t.country_code AND f.province_code = t.province_code AND f.district_code = t.district_code;

CREATE UNIQUE INDEX idx_dm_refusals_district
    ON dm_refusals_daily_district(campaign_id, tenant_id, task_date, country_code, province_code, district_code, reason_type, reason_code);


-- ============================================================================
-- 4. HEALTH CENTER LEVEL REFUSALS MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_refusals_daily_healthcenter AS
WITH total_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
        COUNT(id) AS total_task_submissions
    FROM project_task_enriched
    WHERE is_deleted = FALSE
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        boundary_hierarchy_code->>'healthCenter'
),
failed_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
        additional_details->>'reason_type' AS reason_type,
        additional_details->>'reason_code' AS reason_code,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'REFUSAL' THEN 1 END) AS refusal_count,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'ABSENCE' THEN 1 END) AS absence_count
    FROM project_task_enriched
    WHERE is_deleted = FALSE AND administration_status = 'ADMINISTRATION_FAILED'
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        boundary_hierarchy_code->>'healthCenter',
        additional_details->>'reason_type', additional_details->>'reason_code'
)
SELECT
    f.campaign_id, f.tenant_id, f.task_dates AS task_date,
    f.country_code, f.province_code, f.district_code, f.healthcenter_code,
    f.reason_type, f.reason_code, f.refusal_count, f.absence_count,
    COALESCE(t.total_task_submissions, 0) AS total_task_submissions
FROM failed_tasks f
         LEFT JOIN total_tasks t
                   ON f.campaign_id = t.campaign_id AND f.tenant_id = t.tenant_id AND f.task_dates = t.task_dates
                       AND f.country_code = t.country_code AND f.province_code = t.province_code AND f.district_code = t.district_code AND f.healthcenter_code = t.healthcenter_code;

CREATE UNIQUE INDEX idx_dm_refusals_healthcenter
    ON dm_refusals_daily_healthcenter(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, reason_type, reason_code);


-- ============================================================================
-- 5. SPP LEVEL REFUSALS MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_refusals_daily_spp AS
WITH total_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
        boundary_hierarchy_code->>'spp' AS spp_code,
        COUNT(id) AS total_task_submissions
    FROM project_task_enriched
    WHERE is_deleted = FALSE
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        boundary_hierarchy_code->>'healthCenter',
        boundary_hierarchy_code->>'spp'
),
failed_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
        boundary_hierarchy_code->>'spp' AS spp_code,
        additional_details->>'reason_type' AS reason_type,
        additional_details->>'reason_code' AS reason_code,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'REFUSAL' THEN 1 END) AS refusal_count,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'ABSENCE' THEN 1 END) AS absence_count
    FROM project_task_enriched
    WHERE is_deleted = FALSE AND administration_status = 'ADMINISTRATION_FAILED'
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        boundary_hierarchy_code->>'healthCenter',
        boundary_hierarchy_code->>'spp',
        additional_details->>'reason_type', additional_details->>'reason_code'
)
SELECT
    f.campaign_id, f.tenant_id, f.task_dates AS task_date,
    f.country_code, f.province_code, f.district_code, f.healthcenter_code, f.spp_code,
    f.reason_type, f.reason_code, f.refusal_count, f.absence_count,
    COALESCE(t.total_task_submissions, 0) AS total_task_submissions
FROM failed_tasks f
         LEFT JOIN total_tasks t
                   ON f.campaign_id = t.campaign_id AND f.tenant_id = t.tenant_id AND f.task_dates = t.task_dates
                       AND f.country_code = t.country_code AND f.province_code = t.province_code AND f.district_code = t.district_code AND f.healthcenter_code = t.healthcenter_code AND f.spp_code = t.spp_code;

CREATE UNIQUE INDEX idx_dm_refusals_spp
    ON dm_refusals_daily_spp(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, spp_code, reason_type, reason_code);


-- ============================================================================
-- 6. VILLAGE LEVEL REFUSALS MART
-- ============================================================================
CREATE MATERIALIZED VIEW dm_refusals_daily_village AS
WITH total_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
        boundary_hierarchy_code->>'spp' AS spp_code,
        boundary_hierarchy_code->>'village' AS village_code,
        COUNT(id) AS total_task_submissions
    FROM project_task_enriched
    WHERE is_deleted = FALSE
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        boundary_hierarchy_code->>'healthCenter',
        boundary_hierarchy_code->>'spp',
        boundary_hierarchy_code->>'village'
),
failed_tasks AS (
    SELECT
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country' AS country_code,
        boundary_hierarchy_code->>'province' AS province_code,
        boundary_hierarchy_code->>'district' AS district_code,
        boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
        boundary_hierarchy_code->>'spp' AS spp_code,
        boundary_hierarchy_code->>'village' AS village_code,
        additional_details->>'reason_type' AS reason_type,
        additional_details->>'reason_code' AS reason_code,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'REFUSAL' THEN 1 END) AS refusal_count,
        COUNT(CASE WHEN additional_details->>'reason_type' = 'ABSENCE' THEN 1 END) AS absence_count
    FROM project_task_enriched
    WHERE is_deleted = FALSE AND administration_status = 'ADMINISTRATION_FAILED'
    GROUP BY
        campaign_id, tenant_id, task_dates,
        boundary_hierarchy_code->>'country',
        boundary_hierarchy_code->>'province',
        boundary_hierarchy_code->>'district',
        boundary_hierarchy_code->>'healthCenter',
        boundary_hierarchy_code->>'spp',
        boundary_hierarchy_code->>'village',
        additional_details->>'reason_type', additional_details->>'reason_code'
)
SELECT
    f.campaign_id, f.tenant_id, f.task_dates AS task_date,
    f.country_code, f.province_code, f.district_code, f.healthcenter_code, f.spp_code, f.village_code,
    f.reason_type, f.reason_code, f.refusal_count, f.absence_count,
    COALESCE(t.total_task_submissions, 0) AS total_task_submissions
FROM failed_tasks f
         LEFT JOIN total_tasks t
                   ON f.campaign_id = t.campaign_id AND f.tenant_id = t.tenant_id AND f.task_dates = t.task_dates
                       AND f.country_code = t.country_code AND f.province_code = t.province_code AND f.district_code = t.district_code AND f.healthcenter_code = t.healthcenter_code AND f.spp_code = t.spp_code AND f.village_code = t.village_code;

CREATE UNIQUE INDEX idx_dm_refusals_village
    ON dm_refusals_daily_village(campaign_id, tenant_id, task_date, country_code, province_code, district_code, healthcenter_code, spp_code, village_code, reason_type, reason_code);

--==========================================================================


                            -- DATA MART 4


--==========================================================================

CREATE TABLE IF NOT EXISTS dm_stock_daily AS

    -- ==========================================
-- 1. Isolate the final stock check of the day
-- ==========================================
    WITH latest_daily_reconciliation AS (
        SELECT
        campaign_id,
        facility_id,
        facility_name,
        facility_level,
        facility_target,
        product_name,
        TO_TIMESTAMP(date_of_reconciliation / 1000)::DATE AS transaction_date,
    physical_count,
    date_of_reconciliation, -- Keep the raw timestamp for the audit trail
    ROW_NUMBER() OVER (
                          PARTITION BY campaign_id, facility_id, product_name, TO_TIMESTAMP(date_of_reconciliation / 1000)::DATE
    ORDER BY date_of_reconciliation DESC
    ) as daily_rank
    FROM stock_reconciliation_enriched
    WHERE is_deleted = false
    ),

    -- ==========================================
-- 2. The UNION ALL (Now carrying timestamp data)
-- ==========================================
    unified_stock_events AS (
    -- Top Half: Everyday Stock Movements
                                SELECT
                                campaign_id, facility_id, facility_name, facility_level, facility_target, product_name,
                                TO_TIMESTAMP(date_of_entry / 1000)::DATE AS transaction_date,
    CASE WHEN event_type = 'RECEIVED' THEN physical_count ELSE 0 END AS received_qty,
    CASE WHEN event_type = 'ISSUED' THEN physical_count ELSE 0 END AS issued_qty,
    CASE WHEN event_type = 'RETURNED' THEN physical_count ELSE 0 END AS returned_qty,
    CASE WHEN event_type = 'DAMAGED' THEN physical_count ELSE 0 END AS damaged_qty,
    0 AS reconciliation_physical_count,

    -- NEW: Pass the movement timestamp, put 0 for reconciliation
    date_of_entry AS last_movement_time_ms,
    0::BIGINT AS last_reconciliation_time_ms
    FROM stock_enriched
    WHERE event_type IN ('RECEIVED', 'ISSUED', 'RETURNED', 'DAMAGED')

    UNION ALL

    -- Bottom Half: Manual Stock Checks
    SELECT
    campaign_id, facility_id, facility_name, facility_level, facility_target, product_name,
    transaction_date,
    0 AS received_qty, 0 AS issued_qty, 0 AS returned_qty, 0 AS damaged_qty,
    physical_count AS reconciliation_physical_count,

    -- NEW: Put 0 for movement, pass the reconciliation timestamp
    0::BIGINT AS last_movement_time_ms,
    date_of_reconciliation AS last_reconciliation_time_ms
    FROM latest_daily_reconciliation
    WHERE daily_rank = 1
    )

-- ==========================================
-- 3. Final Aggregation
-- ==========================================
SELECT
    campaign_id,
    facility_id,
    facility_name,
    facility_level,
    facility_target,
    product_name,
    transaction_date,
    SUM(received_qty) AS total_received,
    SUM(issued_qty) AS total_issued,
    SUM(returned_qty) AS total_returned,
    SUM(damaged_qty) AS total_damaged,
    (SUM(received_qty) - SUM(issued_qty) + SUM(returned_qty) - SUM(damaged_qty)) AS calculated_balance,
    SUM(reconciliation_physical_count) AS reconciled_physical_count,

    -- NEW: Extract the latest timestamps and convert them to readable formats
    TO_TIMESTAMP(NULLIF(MAX(last_movement_time_ms), 0) / 1000) AS last_movement_timestamp,
    TO_TIMESTAMP(NULLIF(MAX(last_reconciliation_time_ms), 0) / 1000) AS last_reconciliation_timestamp

FROM unified_stock_events
GROUP BY
    campaign_id, facility_id, facility_name, facility_level, facility_target, product_name, transaction_date;

    
--==========================================================================


                            -- DATA MART 5


--==========================================================================


CREATE TABLE IF NOT EXISTS dm_team_performance_daily AS

SELECT
    campaign_id,
    user_name,
    TO_TIMESTAMP(created_time / 1000)::DATE AS task_date,
    locality_code, -- Now a grouping dimension

    -- 1. Geography Aggregation (JSONB must still be aggregated)
    MAX(boundary_hierarchy_code::TEXT)::JSONB AS boundary_hierarchy_code,

    -- 2. Core Task Metrics
    COUNT(CASE WHEN administration_status = 'ADMINISTERED' THEN 1 END) AS total_vaccinated,
    COUNT(id) AS total_submissions,

    -- 3. Time Boundary Metrics
    MIN(created_time) AS first_submission_time_ms,
    MAX(created_time) AS last_submission_time_ms,
    MIN(synced_time) AS first_synced_time_ms,

    -- 4. Average Sync Lag (in minutes)
    AVG(
            CASE
                WHEN synced_time IS NOT NULL AND created_time IS NOT NULL
                    THEN GREATEST((synced_time - created_time), 0) / 60000.0
                ELSE NULL
                END
    ) AS avg_sync_lag_minutes,

    -- 5. Sync Distribution Buckets
    COUNT(CASE WHEN (synced_time - created_time) / 60000.0 < 60 THEN 1 END) AS sync_within_1hr,
    COUNT(
            CASE WHEN (synced_time - created_time) / 60000.0 >= 60
                AND (synced_time - created_time) / 60000.0 < 360 THEN 1 END
    ) AS sync_1_6hr,
    COUNT(
            CASE WHEN (synced_time - created_time) / 60000.0 >= 360
                AND (synced_time - created_time) / 60000.0 <= 1440 THEN 1 END
    ) AS sync_6_24hr,
    COUNT(CASE WHEN (synced_time - created_time) / 60000.0 > 1440 THEN 1 END) AS sync_over_24hr

FROM project_task_enriched
WHERE task_type IS NOT NULL
GROUP BY
    campaign_id,
    user_name,
    TO_TIMESTAMP(created_time / 1000)::DATE,
    locality_code; -- Added to the GROUP BY clause

-- Update the index to match the new grain
CREATE INDEX IF NOT EXISTS idx_team_perf_daily
    ON dm_team_performance_daily (campaign_id, user_name, task_date, locality_code);


