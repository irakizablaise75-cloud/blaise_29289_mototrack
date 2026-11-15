# Normalization Worksheet — Completed in Phase II

> This worksheet is the short working record. The full UNF → 1NF → 2NF → 3NF analysis with real rows and named dependencies is in `docs/design/normalization.md`.

## Unnormalized source structure

- **Source files:** six CSV files: baseline fuel daily, transition control fuel daily, transition treatment electric daily, and the matching three trip files.
- **Original columns:** daily files have 10 columns (fuel) or 9 columns (electric); trip files have 15 columns each. There are 23 unique raw field names in total.
- **Candidate keys:**
  - Daily: (`file`, `user_id`, `date`)
  - Trip: (`file`, `user_id`, `start_date` + `start_time`, `end_date` + `end_time`, `distance_km`)
- **Repeating groups or mixed concepts:** one unit-day contains many trips (a repeating group). The daily row mixes rider identity, cohort/phase/powertrain, daily aggregates and energy costs. The six files repeat the same structure for different cohorts.

## First Normal Form (1NF)

- **Atomic values:** every CSV cell is a single value; there are no lists or delimited multi-values inside a cell.
- **Primary key:** daily (`cohort_name`, `user_id`, `operating_date`); trip (`cohort_name`, `user_id`, `start_ts`, `end_ts`, `distance_km`).
- **Repeating group removed:** the trips inside a unit-day are stored one row per trip in `TRIPS`; the daily aggregate stays in `DAILY_OPERATIONS`.
- **Cohort added:** the cohort, phase and powertrain are derived from the file name so rows from different files are not confused.

## Second Normal Form (2NF)

- **Partial dependencies:** with the composite unit-day key, `powertrain_type` and `study_phase` depend only on `cohort_name`, not on the date. The unit descriptors also repeat on every daily and trip row.
- **Resolution:** create `RIDER_UNIT(unit_id, source_user_id, cohort_name)` with unique key (`source_user_id`, `cohort_name`). `DAILY_OPERATIONS` and `TRIPS` now reference `unit_id`.
- **Real-data reason:** 107 of 119 riders appear in more than one cohort, so `source_user_id` alone is not a unit key.

## Third Normal Form (3NF)

- **Transitive dependency 1:** `cohort_name → study_phase, powertrain_type`. Moved to `COHORT(cohort_name, study_phase, powertrain_type)`.
- **Transitive/conditional dependency 2:** the applicable fuel/electric cost group depends on the unit's powertrain. Split into `FUEL_DAILY_COSTS` and `ELECTRIC_DAILY_COSTS`, both one-to-one with `DAILY_OPERATIONS`.
- **Many-to-many:** riders participate in many cohorts and cohorts have many riders. Resolved with the `RIDER_UNIT` junction table; `RIDER` holds the rider and `COHORT` holds the study descriptors.
- **Derived attribute removed:** `source_group` is derivable from `COHORT`, so it is not stored in the 3NF child tables.

## Final tables and relationships

- **Tables:** `RIDER`, `COHORT`, `RIDER_UNIT`, `DAILY_OPERATIONS`, `FUEL_DAILY_COSTS`, `ELECTRIC_DAILY_COSTS`, `TRIPS`, `MAINTENANCE_EVENTS`, `AUDIT_LOG`.
- **Primary keys:** `rider_id`, `cohort_name`, `unit_id`, `daily_id`, `daily_id`, `daily_id`, `trip_id`, `maintenance_event_id`, `audit_id`.
- **Foreign keys:** `RIDER_UNIT.rider_id → RIDER`; `RIDER_UNIT.cohort_name → COHORT`; `DAILY_OPERATIONS.unit_id → RIDER_UNIT`; `TRIPS.unit_id → RIDER_UNIT`; `MAINTENANCE_EVENTS.unit_id → RIDER_UNIT`; `FUEL_DAILY_COSTS.daily_id → DAILY_OPERATIONS`; `ELECTRIC_DAILY_COSTS.daily_id → DAILY_OPERATIONS`.
- **Unique constraints:** `RIDER.source_user_id`; (`RIDER_UNIT.rider_id`, `RIDER_UNIT.cohort_name`); (`DAILY_OPERATIONS.unit_id`, `DAILY_OPERATIONS.operating_date`); (`TRIPS.unit_id`, `TRIPS.start_ts`, `TRIPS.end_ts`, `TRIPS.distance_km`); `FUEL_DAILY_COSTS.daily_id`; `ELECTRIC_DAILY_COSTS.daily_id`.
- **Assumptions and limitations:** the daily and trip files are separate facts without a shared trip identifier; revenue exists only at daily level; maintenance is a daily aggregate and `MAINTENANCE_EVENTS` has no source rows; missing values remain `NULL`; coordinates are optional; timestamps are UTC+3.
