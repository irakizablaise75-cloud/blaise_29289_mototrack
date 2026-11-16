-- Load the three original daily CSVs after importing them into their staging tables.
-- The source group is assigned here; no trip-level file or derived trip count is used.
SET SERVEROUTPUT ON;

PROMPT === Pre-load staging counts ===
SELECT 'BASELINE_FUEL' AS source_group, COUNT(*) AS staging_rows
FROM stg_daily_baseline_fuel
UNION ALL
SELECT 'TRANSITION_CONTROL_FUEL', COUNT(*) FROM stg_daily_transition_fuel
UNION ALL
SELECT 'TRANSITION_TREATMENT_ELECTRIC', COUNT(*) FROM stg_daily_transition_electric;

PROMPT === Insert distinct riders ===
MERGE INTO riders r
USING (
    SELECT TRIM(rider_code) AS rider_code
    FROM stg_daily_baseline_fuel
    WHERE rider_code IS NOT NULL AND TRIM(rider_code) IS NOT NULL
    UNION
    SELECT TRIM(rider_code)
    FROM stg_daily_transition_fuel
    WHERE rider_code IS NOT NULL AND TRIM(rider_code) IS NOT NULL
    UNION
    SELECT TRIM(rider_code)
    FROM stg_daily_transition_electric
    WHERE rider_code IS NOT NULL AND TRIM(rider_code) IS NOT NULL
) s
ON (r.rider_code = s.rider_code)
WHEN NOT MATCHED THEN
    INSERT (rider_code) VALUES (s.rider_code);

PROMPT === Merge daily operations ===
MERGE INTO daily_operations d
USING (
    SELECT rr.rider_id,
           src.source_group,
           src.operating_date,
           src.distance_km,
           src.duration_min,
           src.idle_time_min,
           src.revenue_kes,
           src.maintenance_kes,
           src.fuel_cost_kes,
           src.fuel_unit_cost_kes_per_l,
           src.fuel_amount_l,
           src.battery_swap_cost_kes,
           src.kwh_charging
    FROM (
        SELECT 'BASELINE_FUEL' AS source_group,
               TRIM(s.rider_code) AS rider_code,
               TO_DATE(NULLIF(TRIM(s.operating_date), ''), 'YYYY-MM-DD') AS operating_date,
               TO_NUMBER(NULLIF(TRIM(s.distance_km), '')) AS distance_km,
               TO_NUMBER(NULLIF(TRIM(s.duration_min), '')) AS duration_min,
               TO_NUMBER(NULLIF(TRIM(s.idle_time_min), '')) AS idle_time_min,
               TO_NUMBER(NULLIF(TRIM(s.revenue_kes), '')) AS revenue_kes,
               TO_NUMBER(NULLIF(TRIM(s.maintenance_kes), '')) AS maintenance_kes,
               TO_NUMBER(NULLIF(TRIM(s.fuel_cost_kes), '')) AS fuel_cost_kes,
               TO_NUMBER(NULLIF(TRIM(s.fuel_unit_cost_kes_per_l), ''))
                   AS fuel_unit_cost_kes_per_l,
               TO_NUMBER(NULLIF(TRIM(s.fuel_amount_l), '')) AS fuel_amount_l,
               CAST(NULL AS NUMBER) AS battery_swap_cost_kes,
               CAST(NULL AS NUMBER) AS kwh_charging
        FROM stg_daily_baseline_fuel s
        UNION ALL
        SELECT 'TRANSITION_CONTROL_FUEL',
               TRIM(s.rider_code),
               TO_DATE(NULLIF(TRIM(s.operating_date), ''), 'YYYY-MM-DD'),
               TO_NUMBER(NULLIF(TRIM(s.distance_km), '')),
               TO_NUMBER(NULLIF(TRIM(s.duration_min), '')),
               TO_NUMBER(NULLIF(TRIM(s.idle_time_min), '')),
               TO_NUMBER(NULLIF(TRIM(s.revenue_kes), '')),
               TO_NUMBER(NULLIF(TRIM(s.maintenance_kes), '')),
               TO_NUMBER(NULLIF(TRIM(s.fuel_cost_kes), '')),
               TO_NUMBER(NULLIF(TRIM(s.fuel_unit_cost_kes_per_l), '')),
               TO_NUMBER(NULLIF(TRIM(s.fuel_amount_l), '')),
               CAST(NULL AS NUMBER),
               CAST(NULL AS NUMBER)
        FROM stg_daily_transition_fuel s
        UNION ALL
        SELECT 'TRANSITION_TREATMENT_ELECTRIC',
               TRIM(s.rider_code),
               TO_DATE(NULLIF(TRIM(s.operating_date), ''), 'YYYY-MM-DD'),
               TO_NUMBER(NULLIF(TRIM(s.distance_km), '')),
               TO_NUMBER(NULLIF(TRIM(s.duration_min), '')),
               TO_NUMBER(NULLIF(TRIM(s.idle_time_min), '')),
               TO_NUMBER(NULLIF(TRIM(s.revenue_kes), '')),
               TO_NUMBER(NULLIF(TRIM(s.maintenance_kes), '')),
               CAST(NULL AS NUMBER),
               CAST(NULL AS NUMBER),
               CAST(NULL AS NUMBER),
               TO_NUMBER(NULLIF(TRIM(s.battery_swap_cost_kes), '')),
               TO_NUMBER(NULLIF(TRIM(s.kwh_charging), ''))
        FROM stg_daily_transition_electric s
    ) src
    JOIN riders rr ON rr.rider_code = src.rider_code
    WHERE src.operating_date IS NOT NULL
) src
ON (d.rider_id = src.rider_id
    AND d.source_group = src.source_group
    AND d.operating_date = src.operating_date)
WHEN MATCHED THEN
    UPDATE SET d.distance_km = src.distance_km,
               d.duration_min = src.duration_min,
               d.idle_time_min = src.idle_time_min,
               d.revenue_kes = src.revenue_kes,
               d.maintenance_kes = src.maintenance_kes,
               d.fuel_cost_kes = src.fuel_cost_kes,
               d.fuel_unit_cost_kes_per_l = src.fuel_unit_cost_kes_per_l,
               d.fuel_amount_l = src.fuel_amount_l,
               d.battery_swap_cost_kes = src.battery_swap_cost_kes,
               d.kwh_charging = src.kwh_charging
WHEN NOT MATCHED THEN
    INSERT (rider_id, source_group, operating_date, distance_km, duration_min,
            idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes,
            fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes,
            kwh_charging)
    VALUES (src.rider_id, src.source_group, src.operating_date, src.distance_km,
            src.duration_min, src.idle_time_min, src.revenue_kes, src.maintenance_kes,
            src.fuel_cost_kes, src.fuel_unit_cost_kes_per_l, src.fuel_amount_l,
            src.battery_swap_cost_kes, src.kwh_charging);

COMMIT;

PROMPT === Post-load reconciliation ===
SELECT (SELECT COUNT(*) FROM riders) AS riders_loaded,
       (SELECT COUNT(*) FROM daily_operations) AS daily_rows_loaded,
       (SELECT COUNT(*) FROM stg_daily_baseline_fuel)
         + (SELECT COUNT(*) FROM stg_daily_transition_fuel)
         + (SELECT COUNT(*) FROM stg_daily_transition_electric) AS staging_rows
FROM dual;

PROMPT === Loaded rows by source group ===
SELECT source_group, COUNT(*) AS daily_rows
FROM daily_operations
GROUP BY source_group
ORDER BY source_group;

PROMPT MotoTrack daily load complete.
