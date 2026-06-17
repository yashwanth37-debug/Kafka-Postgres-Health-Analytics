--==========================================================================


-- DATA MART 1


--==========================================================================


-- Total Children Vaccinated (Overall Campaign)
SELECT
    campaign_id,
    SUM(total_administered_successfully) AS total_children_vaccinated
FROM dm_coverage_daily_country
GROUP BY campaign_id;

-- Total Could Not Vaccinate (Overall Campaign)
SELECT
    campaign_id,
    SUM(could_not_vaccinate_count) AS total_could_not_vaccinate
FROM dm_coverage_daily_country
GROUP BY campaign_id;

-- Daily Coverage Rate (By Date)
SELECT
    task_date,
    SUM(total_administered_successfully) AS daily_children_vaccinated,
    SUM(total_task_submissions) AS daily_total_submissions,
    ROUND((SUM(total_administered_successfully)::NUMERIC / NULLIF(SUM(total_task_submissions), 0)) * 100, 2) AS daily_coverage_rate_percentage
FROM dm_coverage_daily_country
GROUP BY task_date
ORDER BY task_date DESC;

-- District Performance Summary
SELECT
    country_code,
    province_code,
    district_code,
    SUM(total_administered_successfully) AS district_children_vaccinated,
    SUM(could_not_vaccinate_count) AS district_failed_vaccinations,
    SUM(total_task_submissions) AS district_total_tasks,
    ROUND((SUM(total_administered_successfully)::NUMERIC / NULLIF(SUM(total_task_submissions), 0)) * 100, 2) AS district_success_rate
FROM dm_coverage_daily_district
GROUP BY country_code, province_code, district_code;

-- Health Center Coverage Rate
SELECT
    country_code,
    province_code,
    district_code,
    healthcenter_code,
    SUM(total_administered_successfully) AS hc_children_vaccinated,
    ROUND((SUM(total_administered_successfully)::NUMERIC / NULLIF(SUM(total_task_submissions), 0)) * 100, 2) AS hc_coverage_rate
FROM dm_coverage_daily_healthcenter
GROUP BY country_code, province_code, district_code, healthcenter_code;

--==========================================================================


                            -- DATA MART 2


--==========================================================================

-- KPI 1: TOTAL HOUSEHOLDS REGISTERED (Country)
SELECT
    campaign_id,
    boundary_hierarchy_code->>'country' AS country_code,
    COUNT(DISTINCT household_id) AS total_households_registered
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY campaign_id, boundary_hierarchy_code->>'country';

-- KPI 2, 3 & 4: ENUMERATION, AGE, AND GENDER (Country)
SELECT
    campaign_id,
    country_code,
    SUM(children_0_11m + children_12_23m + children_24_59m) AS total_children_enumerated,
    SUM(children_0_11m) AS sum_0_to_11_months,
    SUM(children_12_23m) AS sum_12_to_23_months,
    SUM(children_24_59m) AS sum_24_to_59_months,
    SUM(male_count) AS total_males,
    SUM(female_count) AS total_females
FROM dm_registration_daily_country
GROUP BY campaign_id, country_code;

-- KPI 1: TOTAL HOUSEHOLDS REGISTERED (Province)
SELECT
    campaign_id,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    COUNT(DISTINCT household_id) AS total_households_registered
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province';

-- KPI 2, 3 & 4: ENUMERATION, AGE, AND GENDER (Province)
SELECT
    campaign_id,
    country_code,
    province_code,
    SUM(children_0_11m + children_12_23m + children_24_59m) AS total_children_enumerated,
    SUM(children_0_11m) AS sum_0_to_11_months,
    SUM(children_12_23m) AS sum_12_to_23_months,
    SUM(children_24_59m) AS sum_24_to_59_months,
    SUM(male_count) AS total_males,
    SUM(female_count) AS total_females
FROM dm_registration_daily_province
GROUP BY campaign_id, country_code, province_code;

-- KPI 1: TOTAL HOUSEHOLDS REGISTERED (District)
SELECT
    campaign_id,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    COUNT(DISTINCT household_id) AS total_households_registered
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district';

-- KPI 2, 3 & 4: ENUMERATION, AGE, AND GENDER (District)
SELECT
    campaign_id,
    country_code,
    province_code,
    district_code,
    SUM(children_0_11m + children_12_23m + children_24_59m) AS total_children_enumerated,
    SUM(children_0_11m) AS sum_0_to_11_months,
    SUM(children_12_23m) AS sum_12_to_23_months,
    SUM(children_24_59m) AS sum_24_to_59_months,
    SUM(male_count) AS total_males,
    SUM(female_count) AS total_females
FROM dm_registration_daily_district
GROUP BY campaign_id, country_code, province_code, district_code;

-- KPI 1: TOTAL HOUSEHOLDS REGISTERED (Health Center)
SELECT
    campaign_id,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    COUNT(DISTINCT household_id) AS total_households_registered
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter';

-- KPI 2, 3 & 4: ENUMERATION, AGE, AND GENDER (Health Center)
SELECT
    campaign_id,
    country_code,
    province_code,
    district_code,
    healthcenter_code,
    SUM(children_0_11m + children_12_23m + children_24_59m) AS total_children_enumerated,
    SUM(children_0_11m) AS sum_0_to_11_months,
    SUM(children_12_23m) AS sum_12_to_23_months,
    SUM(children_24_59m) AS sum_24_to_59_months,
    SUM(male_count) AS total_males,
    SUM(female_count) AS total_females
FROM dm_registration_daily_healthcenter
GROUP BY campaign_id, country_code, province_code, district_code, healthcenter_code;

-- KPI 1: TOTAL HOUSEHOLDS REGISTERED (SPP)
SELECT
    campaign_id,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    boundary_hierarchy_code->>'spp' AS spp_code,
    COUNT(DISTINCT household_id) AS total_households_registered
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter',
    boundary_hierarchy_code->>'spp';

-- KPI 2, 3 & 4: ENUMERATION, AGE, AND GENDER (SPP)
SELECT
    campaign_id,
    country_code,
    province_code,
    district_code,
    healthcenter_code,
    spp_code,
    SUM(children_0_11m + children_12_23m + children_24_59m) AS total_children_enumerated,
    SUM(children_0_11m) AS sum_0_to_11_months,
    SUM(children_12_23m) AS sum_12_to_23_months,
    SUM(children_24_59m) AS sum_24_to_59_months,
    SUM(male_count) AS total_males,
    SUM(female_count) AS total_females
FROM dm_registration_daily_spp
GROUP BY campaign_id, country_code, province_code, district_code, healthcenter_code, spp_code;

-- KPI 1: TOTAL HOUSEHOLDS REGISTERED (Village)
SELECT
    campaign_id,
    boundary_hierarchy_code->>'country' AS country_code,
    boundary_hierarchy_code->>'province' AS province_code,
    boundary_hierarchy_code->>'district' AS district_code,
    boundary_hierarchy_code->>'healthCenter' AS healthcenter_code,
    boundary_hierarchy_code->>'spp' AS spp_code,
    boundary_hierarchy_code->>'village' AS village_code,
    COUNT(DISTINCT household_id) AS total_households_registered
FROM household_member_enriched
WHERE is_deleted = FALSE
GROUP BY
    campaign_id,
    boundary_hierarchy_code->>'country',
    boundary_hierarchy_code->>'province',
    boundary_hierarchy_code->>'district',
    boundary_hierarchy_code->>'healthCenter',
    boundary_hierarchy_code->>'spp',
    boundary_hierarchy_code->>'village';

-- KPI 2, 3 & 4: ENUMERATION, AGE, AND GENDER (Village)
SELECT
    campaign_id,
    country_code,
    province_code,
    district_code,
    healthcenter_code,
    spp_code,
    village_code,
    SUM(children_0_11m + children_12_23m + children_24_59m) AS total_children_enumerated,
    SUM(children_0_11m) AS sum_0_to_11_months,
    SUM(children_12_23m) AS sum_12_to_23_months,
    SUM(children_24_59m) AS sum_24_to_59_months,
    SUM(male_count) AS total_males,
    SUM(female_count) AS total_females
FROM dm_registration_daily_village
GROUP BY campaign_id, country_code, province_code, district_code, healthcenter_code, spp_code, village_code;

--==========================================================================


                            -- DATA MART 3


--==========================================================================

-- ============================================================================
-- PHASE 2: PRODUCTION-READY KPI QUERIES (DASHBOARD LAYER)
-- ============================================================================

-- KPI 1: REFUSAL / ABSENCE REASONS BREAKDOWN
SELECT
    campaign_id,
    country_code,
    reason_code,
    SUM(refusal_count) AS total_refusals,
    SUM(absence_count) AS total_absences
FROM dm_refusals_daily_country
WHERE reason_type IN ('REFUSAL', 'ABSENCE')
GROUP BY campaign_id, country_code, reason_code
ORDER BY total_refusals DESC;


-- KPI 2: TOTAL CAMPAIGN REFUSAL & ABSENCE RATES (%)
WITH DailyTotals AS (
    SELECT
        campaign_id,
        country_code,
        task_date,
        SUM(refusal_count) AS daily_refusals,
        SUM(absence_count) AS daily_absences,
        MAX(total_task_submissions) AS daily_tasks
    FROM dm_refusals_daily_country
    GROUP BY campaign_id, country_code, task_date
)
SELECT
    campaign_id,
    country_code,
    SUM(daily_refusals) AS total_refusals,
    SUM(daily_absences) AS total_absences,
    SUM(daily_tasks) AS overarching_task_total,
    (SUM(daily_refusals)::DECIMAL / NULLIF(SUM(daily_tasks), 0)) * 100 AS refusal_rate_percentage,
    (SUM(daily_absences)::DECIMAL / NULLIF(SUM(daily_tasks), 0)) * 100 AS absence_rate_percentage
FROM DailyTotals
GROUP BY campaign_id, country_code;


-- KPI 3: REFUSAL & ABSENCE RATES BY DISTRICT (%)
WITH DistrictDailyTotals AS (
    SELECT
        country_code,
        province_code,
        district_code,
        task_date,
        SUM(refusal_count) AS daily_refusals,
        SUM(absence_count) AS daily_absences,
        MAX(total_task_submissions) AS daily_tasks
    FROM dm_refusals_daily_district
    GROUP BY country_code, province_code, district_code, task_date
)
SELECT
    country_code,
    province_code,
    district_code,
    SUM(daily_refusals) AS district_refusals,
    SUM(daily_absences) AS district_absences,
    SUM(daily_tasks) AS district_task_total,
    (SUM(daily_refusals)::DECIMAL / NULLIF(SUM(daily_tasks), 0)) * 100 AS district_refusal_rate,
    (SUM(daily_absences)::DECIMAL / NULLIF(SUM(daily_tasks), 0)) * 100 AS district_absence_rate
FROM DistrictDailyTotals
GROUP BY country_code, province_code, district_code;



--==========================================================================


                            -- DATA MART 4


--==========================================================================


SELECT
    campaign_id,
    facility_id,
    facility_name,
    facility_level,
    product_name,
    transaction_date,

    -- ==========================================
    -- KPI 1: Vials Issued per Team/DayN

    )
END AS wastage_rate_pct,

    -- ==========================================
    -- KPI 4: Stock Reconciliation Rate (%)
    -- ==========================================
    CASE
        -- If the calculated balance is 0, we can't calculate a standard ratio
        WHEN calculated_balance = 0 THEN NULL
        ELSE ROUND(
                (reconciled_physical_count::NUMERIC / calculated_balance) * 100,
                2
             )
END AS stock_reconciliation_rate_pct,

    -- ==========================================
    -- KPI 5: Stock-out Risk (%)
    -- ==========================================
    CASE
        -- Cannot calculate risk if there is no target set for the facility
        WHEN facility_target = 0 OR facility_target IS NULL THEN NULL
        ELSE ROUND(
                (
                    -- Prioritize physical count if available, otherwise fallback to calculated balance
                    COALESCE(NULLIF(reconciled_physical_count, 0), calculated_balance)::NUMERIC
                / facility_target
                    ) * 100,
                2
             )
END AS stock_out_risk_pct,

    -- Carry forward audit timestamps for dashboard context
    last_movement_timestamp,
    last_reconciliation_timestamp

FROM dm_stock_daily;


--==========================================================================


                            -- DATA MART 5


--==========================================================================


SELECT
    campaign_id,
    user_name,
    task_date,
    locality_code,

    -- ==========================================
    -- KPI 1: Children Vaccinated & Submission Velocity (Per Locality)
    -- ==========================================
    total_vaccinated AS children_vaccinated_in_locality,
    total_submissions AS locality_submission_velocity,

    -- ==========================================
    -- KPI 2: Average Sync Lag (Per Locality)
    -- ==========================================
    ROUND(avg_sync_lag_minutes::NUMERIC, 2) AS avg_sync_lag_minutes,

    -- ==========================================
    -- KPI 3: Sync Rate (%)
    -- ==========================================
    CASE
        WHEN total_submissions = 0 THEN 0.00
        ELSE ROUND(
                (
                    (sync_within_1hr + sync_1_6hr + sync_6_24hr + sync_over_24hr)::NUMERIC
                    / total_submissions
            ) * 100,
            2
        )
        END AS sync_rate_pct,

    -- ==========================================
    -- KPI 4: Sync Timing Distribution (%)
    -- ==========================================
    CASE WHEN total_submissions = 0 THEN 0.00 ELSE ROUND((sync_within_1hr::NUMERIC / total_submissions) * 100, 2) END AS pct_synced_under_1hr,
    CASE WHEN total_submissions = 0 THEN 0.00 ELSE ROUND((sync_1_6hr::NUMERIC / total_submissions) * 100, 2) END AS pct_synced_1_to_6hr,
    CASE WHEN total_submissions = 0 THEN 0.00 ELSE ROUND((sync_6_24hr::NUMERIC / total_submissions) * 100, 2) END AS pct_synced_6_to_24hr,
    CASE WHEN total_submissions = 0 THEN 0.00 ELSE ROUND((sync_over_24hr::NUMERIC / total_submissions) * 100, 2) END AS pct_synced_over_24hr,

    -- ==========================================
    -- KPI 5: Locality Work Hours
    -- ==========================================
    TO_TIMESTAMP(first_submission_time_ms / 1000) AS locality_start_time,
    TO_TIMESTAMP(last_submission_time_ms / 1000) AS locality_end_time

FROM dm_team_performance_daily;





































































