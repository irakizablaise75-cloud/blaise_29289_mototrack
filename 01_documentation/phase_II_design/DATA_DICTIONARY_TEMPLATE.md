# MotoTrack Data Dictionary — Working Summary

> The complete data dictionary with every column, logical type, nullability, unique constraint, foreign key, raw-field mapping and business rule is in `docs/design/data_dictionary.md`. Oracle data types and sizes are deliberately deferred to Phase IV.

## Table inventory

| Table | Primary key | Unique key | Foreign keys | Expected rows |
|---|---|---|---|---:|
| `RIDER` | `rider_id` | `source_user_id` | — | 119 |
| `COHORT` | `cohort_name` | — | — | 3 |
| `RIDER_UNIT` | `unit_id` | (`rider_id`, `cohort_name`) | `rider_id` → `RIDER`; `cohort_name` → `COHORT` | 235 |
| `DAILY_OPERATIONS` | `daily_id` | (`unit_id`, `operating_date`) | `unit_id` → `RIDER_UNIT` | 2,718 |
| `FUEL_DAILY_COSTS` | `daily_id` | `daily_id` | `daily_id` → `DAILY_OPERATIONS` | 2,630 |
| `ELECTRIC_DAILY_COSTS` | `daily_id` | `daily_id` | `daily_id` → `DAILY_OPERATIONS` | 88 |
| `TRIPS` | `trip_id` | (`unit_id`, `start_ts`, `end_ts`, `distance_km`) | `unit_id` → `RIDER_UNIT` | 126,067 |
| `MAINTENANCE_EVENTS` | `maintenance_event_id` | — | `unit_id` → `RIDER_UNIT` | 0 |
| `AUDIT_LOG` | `audit_id` | — | None (standalone) | 0 initially |

## Source mapping summary

| Source fields | Target |
|---|---|
| `user_id` | `RIDER.source_user_id`; then link to `RIDER_UNIT` through the rider |
| Daily `date`, `distance_km`, `duration_min`, `idle_time_min`, `revenue_kes`, `maintenance_kes` | `DAILY_OPERATIONS` |
| Daily `fuel_cost_kes`, `fuel_unit_cost_kes_per_l`, `fuel_amount_l` | `FUEL_DAILY_COSTS` |
| Daily `battery_swap_cost_kes`, `kwh_charging` | `ELECTRIC_DAILY_COSTS` |
| Trip `start_date` + `start_time`, `end_date` + `end_time` | `TRIPS.start_ts`, `TRIPS.end_ts` |
| Trip `distance_km`, `duration_min`, `idle_time_min` | `TRIPS` |
| Trip `start_lat`, `start_lon`, `end_lat`, `end_lon` | `TRIPS` (optional coordinates) |
| Trip `avg_speed_kmh`, `avg_moving_speed_kmh`, `max_speed_kmh` | `TRIPS` |
| File name | `COHORT.cohort_name`, `COHORT.study_phase`, `COHORT.powertrain_type`, `RIDER_UNIT.cohort_name` |

## Key business rules

- `source_user_id` is not a unit key: 107 of 119 riders appear in more than one cohort. The unit is (`rider_id`, `cohort_name`).
- Blank CSV cells become `NULL`, never zero.
- `DAILY_OPERATIONS` is unique on (`unit_id`, `operating_date`); `TRIPS` is unique on (`unit_id`, `start_ts`, `end_ts`, `distance_km`).
- Fuel and electric costs are optional one-to-one children of `DAILY_OPERATIONS`.
- Coordinates are optional because the publisher removed first/last trip coordinates.
- `source_group` is derived from `COHORT` and is not stored in the 3NF child tables.
- `MAINTENANCE_EVENTS` is empty in the source; the daily `maintenance_kes` aggregate stays in `DAILY_OPERATIONS` to avoid double counting.
