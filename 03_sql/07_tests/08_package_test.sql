SET SERVEROUTPUT ON;

-- Read-only package tests. 579236 is present in all three source groups.
DECLARE
    v_profit NUMBER;
    v_total  NUMBER;
BEGIN
    v_profit := pkg_mototrack.calculate_profit('579236');
    v_total  := pkg_mototrack.get_total_profit();
    DBMS_OUTPUT.PUT_LINE('Profit for rider 579236: ' || v_profit || ' KES');
    DBMS_OUTPUT.PUT_LINE('Total fleet profit      : ' || v_total || ' KES');
END;
/

-- Rider summary via packaged cursor.
BEGIN
    pkg_mototrack.print_rider_summary('579236');
END;
/

-- Find valid sample riders and dates:
SELECT rider_code, source_group, operating_date, revenue_kes, fuel_cost_kes,
       battery_swap_cost_kes, maintenance_kes, profit_kes
FROM v_daily_performance
WHERE revenue_kes IS NOT NULL
ORDER BY operating_date, source_group
FETCH FIRST 10 ROWS ONLY;

SELECT rider_code, source_group, profit_on_complete_days_kes,
       financially_complete_days
FROM v_rider_summary
WHERE rider_code = '579236'
ORDER BY source_group;

-- Maintenance entry demo (rolled back so the dataset is unchanged).
-- Replace the rider code and date with a real row before using for real.
-- BEGIN
--   pkg_mototrack.record_maintenance(
--     p_rider_code  => '579236',
--   p_date        => DATE '2023-11-13',
--     p_type        => 'TYRE_REPAIR',
--     p_description => 'Example maintenance record',
--     p_amount_kes  => 500,
--     p_odometer_km => 12000
--   );
--   ROLLBACK;
-- END;
-- /
