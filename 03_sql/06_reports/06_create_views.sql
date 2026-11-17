-- Reporting views for daily data across all study groups.
SET SERVEROUTPUT ON;

CREATE OR REPLACE VIEW v_daily_performance AS
SELECT d.daily_id,
       r.rider_code,
       d.source_group,
       d.operating_date,
       d.distance_km,
       d.duration_min,
       d.idle_time_min,
       d.revenue_kes,
       d.fuel_cost_kes,
       d.fuel_unit_cost_kes_per_l,
       d.fuel_amount_l,
       d.battery_swap_cost_kes,
       d.kwh_charging,
       d.maintenance_kes,
       CASE
           WHEN d.maintenance_kes IS NOT NULL
            AND ((d.source_group IN ('BASELINE_FUEL', 'TRANSITION_CONTROL_FUEL')
                  AND d.fuel_cost_kes IS NOT NULL)
                 OR (d.source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                     AND d.battery_swap_cost_kes IS NOT NULL))
           THEN d.maintenance_kes
                + CASE WHEN d.source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                       THEN d.battery_swap_cost_kes
                       ELSE d.fuel_cost_kes
                  END
       END AS total_cost_kes,
       CASE
           WHEN d.revenue_kes IS NOT NULL
            AND d.maintenance_kes IS NOT NULL
            AND ((d.source_group IN ('BASELINE_FUEL', 'TRANSITION_CONTROL_FUEL')
                  AND d.fuel_cost_kes IS NOT NULL)
                 OR (d.source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                     AND d.battery_swap_cost_kes IS NOT NULL))
           THEN d.revenue_kes - d.maintenance_kes
                - CASE WHEN d.source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                       THEN d.battery_swap_cost_kes
                       ELSE d.fuel_cost_kes
                  END
       END AS profit_kes,
       CASE WHEN d.distance_km > 0
            THEN d.revenue_kes / d.distance_km END AS revenue_per_km_kes,
       CASE
           WHEN d.distance_km > 0
            AND d.maintenance_kes IS NOT NULL
            AND ((d.source_group IN ('BASELINE_FUEL', 'TRANSITION_CONTROL_FUEL')
                  AND d.fuel_cost_kes IS NOT NULL)
                 OR (d.source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                     AND d.battery_swap_cost_kes IS NOT NULL))
           THEN (d.maintenance_kes
                + CASE WHEN d.source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                       THEN d.battery_swap_cost_kes
                       ELSE d.fuel_cost_kes
                  END) / d.distance_km
       END AS cost_per_km_kes
FROM daily_operations d
JOIN riders r ON r.rider_id = d.rider_id;

CREATE OR REPLACE VIEW v_rider_summary AS
SELECT r.rider_id,
       r.rider_code,
       d.source_group,
       COUNT(d.daily_id) AS active_days,
       COUNT(p.profit_kes) AS financially_complete_days,
       SUM(d.distance_km) AS total_distance_km,
       SUM(d.duration_min) AS total_duration_min,
       SUM(d.idle_time_min) AS total_idle_time_min,
       SUM(d.revenue_kes) AS reported_revenue_kes,
       SUM(d.fuel_cost_kes) AS reported_fuel_cost_kes,
       SUM(d.battery_swap_cost_kes) AS reported_battery_cost_kes,
       SUM(d.maintenance_kes) AS reported_maintenance_kes,
       SUM(p.total_cost_kes) AS total_cost_kes,
       SUM(p.profit_kes) AS profit_on_complete_days_kes,
       CASE WHEN SUM(CASE WHEN p.profit_kes IS NOT NULL THEN d.distance_km END) > 0
            THEN SUM(p.profit_kes)
                 / SUM(CASE WHEN p.profit_kes IS NOT NULL THEN d.distance_km END)
       END AS profit_per_km_kes
FROM riders r
JOIN daily_operations d ON d.rider_id = r.rider_id
JOIN v_daily_performance p ON p.daily_id = d.daily_id
GROUP BY r.rider_id, r.rider_code, d.source_group;

CREATE OR REPLACE VIEW v_daily_totals AS
SELECT d.operating_date,
       d.source_group,
       COUNT(DISTINCT d.rider_id) AS active_riders,
       COUNT(p.profit_kes) AS financially_complete_days,
       SUM(d.distance_km) AS total_distance_km,
       SUM(d.revenue_kes) AS reported_revenue_kes,
       SUM(d.fuel_cost_kes) AS reported_fuel_cost_kes,
       SUM(d.battery_swap_cost_kes) AS reported_battery_cost_kes,
       SUM(d.maintenance_kes) AS reported_maintenance_kes,
       SUM(p.total_cost_kes) AS total_cost_kes,
       SUM(p.profit_kes) AS profit_on_complete_days_kes
FROM daily_operations d
JOIN v_daily_performance p ON p.daily_id = d.daily_id
GROUP BY d.operating_date, d.source_group;

CREATE OR REPLACE VIEW v_maintenance_summary AS
SELECT r.rider_code,
       COUNT(m.maintenance_event_id) AS events,
       SUM(m.amount_kes) AS total_maintenance_kes,
       MAX(m.maintenance_date) AS last_event_date
FROM riders r
LEFT JOIN maintenance_events m ON m.rider_id = r.rider_id
GROUP BY r.rider_code;

PROMPT MotoTrack views created.
