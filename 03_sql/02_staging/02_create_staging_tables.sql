-- Import each matching CSV from data/raw/daily_data/ into its staging table.
-- baseline-fuel -> stg_daily_baseline_fuel
-- transition-control-fuel -> stg_daily_transition_fuel
-- transition-treatment-electric -> stg_daily_transition_electric
-- Map source user_id to rider_code and source date to operating_date.
-- Keep all imported values as text so blank cells remain NULL during conversion.

CREATE TABLE stg_daily_baseline_fuel (
    rider_code               VARCHAR2(50),
    operating_date           VARCHAR2(30),
    distance_km              VARCHAR2(50),
    duration_min             VARCHAR2(50),
    idle_time_min            VARCHAR2(50),
    revenue_kes              VARCHAR2(50),
    maintenance_kes          VARCHAR2(50),
    fuel_cost_kes            VARCHAR2(50),
    fuel_unit_cost_kes_per_l VARCHAR2(50),
    fuel_amount_l            VARCHAR2(50)
);

CREATE TABLE stg_daily_transition_fuel (
    rider_code               VARCHAR2(50),
    operating_date           VARCHAR2(30),
    distance_km              VARCHAR2(50),
    duration_min             VARCHAR2(50),
    idle_time_min            VARCHAR2(50),
    revenue_kes              VARCHAR2(50),
    maintenance_kes          VARCHAR2(50),
    fuel_cost_kes            VARCHAR2(50),
    fuel_unit_cost_kes_per_l VARCHAR2(50),
    fuel_amount_l            VARCHAR2(50)
);

CREATE TABLE stg_daily_transition_electric (
    rider_code              VARCHAR2(50),
    operating_date          VARCHAR2(30),
    distance_km             VARCHAR2(50),
    duration_min            VARCHAR2(50),
    idle_time_min           VARCHAR2(50),
    revenue_kes             VARCHAR2(50),
    maintenance_kes         VARCHAR2(50),
    battery_swap_cost_kes   VARCHAR2(50),
    kwh_charging            VARCHAR2(50)
);

PROMPT MotoTrack daily staging tables created.
