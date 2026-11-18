SET SERVEROUTPUT ON;

PROMPT === Core table counts ===
SELECT 'RIDERS' table_name, COUNT(*) row_count FROM riders
UNION ALL SELECT 'SOURCE_GROUP', COUNT(*) FROM source_group
UNION ALL SELECT 'DAILY_OPERATIONS', COUNT(*) FROM daily_operations
UNION ALL SELECT 'MAINTENANCE_TYPE', COUNT(*) FROM maintenance_type
UNION ALL SELECT 'MAINTENANCE_EVENTS', COUNT(*) FROM maintenance_events
UNION ALL SELECT 'AUDIT_LOG', COUNT(*) FROM audit_log;

PROMPT === Rider reconciliation ===
SELECT COUNT(*) loaded_riders, 119 expected_riders,
       CASE WHEN COUNT(*) = 119 THEN 'PASS' ELSE 'CHECK' END AS status
FROM riders;

PROMPT === Daily rows by study group ===
SELECT source_group, COUNT(*) daily_rows, COUNT(DISTINCT rider_id) riders
FROM daily_operations
GROUP BY source_group
ORDER BY source_group;

PROMPT === Expected source row counts ===
SELECT source_group, expected_rows, loaded_rows,
       CASE WHEN expected_rows = loaded_rows THEN 'PASS' ELSE 'CHECK' END AS status
FROM (
    SELECT 'BASELINE_FUEL' AS source_group, 1480 AS expected_rows,
           COUNT(CASE WHEN source_group = 'BASELINE_FUEL' THEN 1 END) AS loaded_rows
    FROM daily_operations
    UNION ALL
    SELECT 'TRANSITION_CONTROL_FUEL', 1150,
           COUNT(CASE WHEN source_group = 'TRANSITION_CONTROL_FUEL' THEN 1 END)
    FROM daily_operations
    UNION ALL
    SELECT 'TRANSITION_TREATMENT_ELECTRIC', 88,
           COUNT(CASE WHEN source_group = 'TRANSITION_TREATMENT_ELECTRIC' THEN 1 END)
    FROM daily_operations
);

PROMPT === Missing daily fields ===
SELECT source_group,
       COUNT(*) total_rows,
       SUM(CASE WHEN revenue_kes IS NULL THEN 1 ELSE 0 END) missing_revenue,
       SUM(CASE WHEN maintenance_kes IS NULL THEN 1 ELSE 0 END) missing_maintenance,
       SUM(CASE WHEN distance_km IS NULL THEN 1 ELSE 0 END) missing_distance,
       SUM(CASE WHEN source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                 AND battery_swap_cost_kes IS NULL THEN 1
                WHEN source_group <> 'TRANSITION_TREATMENT_ELECTRIC'
                 AND fuel_cost_kes IS NULL THEN 1
                ELSE 0 END) missing_energy_cost
FROM daily_operations
GROUP BY source_group
ORDER BY source_group;

PROMPT === Date coverage ===
SELECT MIN(operating_date) first_date, MAX(operating_date) last_date,
       COUNT(DISTINCT operating_date) distinct_dates
FROM daily_operations;

PROMPT === Daily totals sample ===
SELECT * FROM v_daily_totals
ORDER BY operating_date, source_group FETCH FIRST 20 ROWS ONLY;

PROMPT === Rider summary sample ===
SELECT rider_code, source_group, active_days, financially_complete_days,
       reported_revenue_kes, total_cost_kes, profit_on_complete_days_kes,
       profit_per_km_kes
FROM v_rider_summary
ORDER BY profit_on_complete_days_kes DESC
FETCH FIRST 20 ROWS ONLY;

PROMPT === Profit function sample ===
SELECT rider_code, pkg_mototrack.calculate_profit(rider_code) calculated_profit_kes
FROM riders
ORDER BY rider_code
FETCH FIRST 20 ROWS ONLY;

PROMPT === Audit sample ===
SELECT * FROM audit_log ORDER BY changed_at DESC FETCH FIRST 20 ROWS ONLY;
