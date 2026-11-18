-- Application logic for daily operations, maintenance and financial summaries.
SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE pkg_mototrack AS

    e_rider_not_found EXCEPTION;
    e_invalid_amount  EXCEPTION;

    FUNCTION get_rider_id(p_rider_code IN VARCHAR2) RETURN NUMBER;

    PROCEDURE add_daily_operation(
        p_rider_code              IN VARCHAR2,
        p_source_group            IN VARCHAR2,
        p_operating_date          IN DATE,
        p_distance_km             IN NUMBER,
        p_duration_min            IN NUMBER,
        p_idle_time_min           IN NUMBER,
        p_revenue_kes             IN NUMBER,
        p_maintenance_kes         IN NUMBER,
        p_fuel_cost_kes           IN NUMBER,
        p_fuel_unit_cost_kes_per_l IN NUMBER,
        p_fuel_amount_l           IN NUMBER,
        p_battery_swap_cost_kes   IN NUMBER,
        p_kwh_charging            IN NUMBER);

    PROCEDURE record_maintenance(
        p_rider_code  IN VARCHAR2,
        p_date        IN DATE,
        p_type        IN VARCHAR2,
        p_description IN VARCHAR2,
        p_amount_kes  IN NUMBER,
        p_odometer_km IN NUMBER DEFAULT NULL);

    FUNCTION calculate_profit(p_rider_code IN VARCHAR2) RETURN NUMBER;
    FUNCTION get_total_profit RETURN NUMBER;

    PROCEDURE print_rider_summary(p_rider_code IN VARCHAR2);

END pkg_mototrack;
/

CREATE OR REPLACE PACKAGE BODY pkg_mototrack AS

    FUNCTION get_rider_id(p_rider_code IN VARCHAR2) RETURN NUMBER IS
        l_id   NUMBER;
        l_code VARCHAR2(50) := TRIM(p_rider_code);
    BEGIN
        IF l_code IS NULL THEN
            RAISE e_rider_not_found;
        END IF;
        SELECT rider_id INTO l_id FROM riders WHERE rider_code = l_code;
        RETURN l_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_rider_not_found;
    END get_rider_id;

    PROCEDURE add_daily_operation(
        p_rider_code               IN VARCHAR2,
        p_source_group             IN VARCHAR2,
        p_operating_date           IN DATE,
        p_distance_km              IN NUMBER,
        p_duration_min             IN NUMBER,
        p_idle_time_min            IN NUMBER,
        p_revenue_kes              IN NUMBER,
        p_maintenance_kes          IN NUMBER,
        p_fuel_cost_kes            IN NUMBER,
        p_fuel_unit_cost_kes_per_l IN NUMBER,
        p_fuel_amount_l            IN NUMBER,
        p_battery_swap_cost_kes    IN NUMBER,
        p_kwh_charging             IN NUMBER) IS
        l_rider_id NUMBER;
    BEGIN
        l_rider_id := get_rider_id(p_rider_code);
        INSERT INTO daily_operations (
            rider_id, source_group, operating_date, distance_km, duration_min,
            idle_time_min, revenue_kes, maintenance_kes, fuel_cost_kes,
            fuel_unit_cost_kes_per_l, fuel_amount_l, battery_swap_cost_kes,
            kwh_charging)
        VALUES (
            l_rider_id, UPPER(TRIM(p_source_group)), p_operating_date,
            p_distance_km, p_duration_min, p_idle_time_min, p_revenue_kes,
            p_maintenance_kes, p_fuel_cost_kes, p_fuel_unit_cost_kes_per_l,
            p_fuel_amount_l, p_battery_swap_cost_kes, p_kwh_charging);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Daily operation already exists for this rider, group and date.');
    END add_daily_operation;

    PROCEDURE record_maintenance(
        p_rider_code  IN VARCHAR2,
        p_date        IN DATE,
        p_type        IN VARCHAR2,
        p_description IN VARCHAR2,
        p_amount_kes  IN NUMBER,
        p_odometer_km IN NUMBER DEFAULT NULL) IS
        l_rider_id NUMBER;
    BEGIN
        IF p_amount_kes IS NULL OR p_amount_kes < 0 THEN
            RAISE e_invalid_amount;
        END IF;
        l_rider_id := get_rider_id(p_rider_code);
        INSERT INTO maintenance_events (
            rider_id, maintenance_date, maintenance_type, description,
            amount_kes, odometer_km)
        VALUES (
            l_rider_id, p_date, p_type, p_description, p_amount_kes, p_odometer_km);
    END record_maintenance;

    FUNCTION calculate_profit(p_rider_code IN VARCHAR2) RETURN NUMBER IS
        l_profit   NUMBER;
        l_rider_id NUMBER;
    BEGIN
        l_rider_id := get_rider_id(p_rider_code);
        SELECT SUM(
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
                   END)
        INTO l_profit
        FROM daily_operations d
        WHERE d.rider_id = l_rider_id;
        RETURN l_profit;
    END calculate_profit;

    FUNCTION get_total_profit RETURN NUMBER IS
        l_profit NUMBER;
    BEGIN
        SELECT SUM(
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
                   END)
        INTO l_profit
        FROM daily_operations d;
        RETURN l_profit;
    END get_total_profit;

    PROCEDURE print_rider_summary(p_rider_code IN VARCHAR2) IS
        l_rider_id       NUMBER;
        l_days           NUMBER;
        l_complete_days  NUMBER;
        l_distance       NUMBER;
        l_revenue        NUMBER;
        l_fuel           NUMBER;
        l_battery        NUMBER;
        l_maint          NUMBER;
        l_profit         NUMBER;

        CURSOR c_days IS
            SELECT source_group,
                   operating_date,
                   revenue_kes,
                   CASE
                       WHEN revenue_kes IS NOT NULL
                        AND maintenance_kes IS NOT NULL
                        AND ((source_group IN ('BASELINE_FUEL', 'TRANSITION_CONTROL_FUEL')
                              AND fuel_cost_kes IS NOT NULL)
                             OR (source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                                 AND battery_swap_cost_kes IS NOT NULL))
                       THEN revenue_kes - maintenance_kes
                            - CASE WHEN source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                                   THEN battery_swap_cost_kes
                                   ELSE fuel_cost_kes
                              END
                   END AS profit_kes
            FROM daily_operations
            WHERE rider_id = l_rider_id
            ORDER BY operating_date, source_group;

        TYPE t_day_row IS RECORD (
            source_group   daily_operations.source_group%TYPE,
            operating_date daily_operations.operating_date%TYPE,
            revenue_kes    daily_operations.revenue_kes%TYPE,
            profit_kes     NUMBER);
        r_day t_day_row;
    BEGIN
        l_rider_id := get_rider_id(p_rider_code);

        SELECT COUNT(*),
               COUNT(CASE
                   WHEN revenue_kes IS NOT NULL
                    AND maintenance_kes IS NOT NULL
                    AND ((source_group IN ('BASELINE_FUEL', 'TRANSITION_CONTROL_FUEL')
                          AND fuel_cost_kes IS NOT NULL)
                         OR (source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                             AND battery_swap_cost_kes IS NOT NULL))
                   THEN 1
               END),
               NVL(SUM(distance_km), 0),
               NVL(SUM(revenue_kes), 0),
               NVL(SUM(fuel_cost_kes), 0),
               NVL(SUM(battery_swap_cost_kes), 0),
               NVL(SUM(maintenance_kes), 0),
               SUM(
                   CASE
                       WHEN revenue_kes IS NOT NULL
                        AND maintenance_kes IS NOT NULL
                        AND ((source_group IN ('BASELINE_FUEL', 'TRANSITION_CONTROL_FUEL')
                              AND fuel_cost_kes IS NOT NULL)
                             OR (source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                                 AND battery_swap_cost_kes IS NOT NULL))
                       THEN revenue_kes - maintenance_kes
                            - CASE WHEN source_group = 'TRANSITION_TREATMENT_ELECTRIC'
                                   THEN battery_swap_cost_kes
                                   ELSE fuel_cost_kes
                              END
                   END)
        INTO l_days, l_complete_days, l_distance, l_revenue, l_fuel,
             l_battery, l_maint, l_profit
        FROM daily_operations
        WHERE rider_id = l_rider_id;

        DBMS_OUTPUT.PUT_LINE('Rider ' || p_rider_code);
        DBMS_OUTPUT.PUT_LINE('  Active days              : ' || l_days);
        DBMS_OUTPUT.PUT_LINE('  Financially complete days: ' || l_complete_days);
        DBMS_OUTPUT.PUT_LINE('  Distance km              : ' || l_distance);
        DBMS_OUTPUT.PUT_LINE('  Reported revenue KES     : ' || l_revenue);
        DBMS_OUTPUT.PUT_LINE('  Reported fuel cost KES   : ' || l_fuel);
        DBMS_OUTPUT.PUT_LINE('  Reported battery cost KES: ' || l_battery);
        DBMS_OUTPUT.PUT_LINE('  Reported maintenance KES : ' || l_maint);
        DBMS_OUTPUT.PUT_LINE('  Profit on complete days  : '
            || NVL(TO_CHAR(l_profit), 'NULL'));

        OPEN c_days;
        LOOP
            FETCH c_days INTO r_day;
            EXIT WHEN c_days%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('  ' || r_day.source_group || ' '
                || TO_CHAR(r_day.operating_date, 'YYYY-MM-DD')
                || ' revenue=' || NVL(TO_CHAR(r_day.revenue_kes), 'NULL')
                || ' profit=' || NVL(TO_CHAR(r_day.profit_kes), 'NULL'));
        END LOOP;
        CLOSE c_days;
    EXCEPTION
        WHEN e_rider_not_found THEN
            DBMS_OUTPUT.PUT_LINE('Rider ' || p_rider_code || ' not found.');
    END print_rider_summary;

END pkg_mototrack;
/

PROMPT MotoTrack package created.
